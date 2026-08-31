extends "res://scripts/windowed_main.gd"

func _ready() -> void:
    super._ready()
    _brighten_materials()
    _brighten_environment()
    _apply_combined_layout_hotfix()
    _boost_existing_fixtures()
    _add_hallway_fill_lights()
    _add_front_door_lighting()
    if is_instance_valid(atmosphere):
        atmosphere.refresh_fluorescent_sources(self)

func _brighten_materials() -> void:
    var door_mat := mats.get("door") as StandardMaterial3D
    if door_mat:
        door_mat.albedo_color = Color(0.56, 0.42, 0.27)
        door_mat.roughness = 0.68

    var frame_mat := mats.get("window_frame") as StandardMaterial3D
    if frame_mat:
        frame_mat.albedo_color = Color(0.32, 0.35, 0.34)

    var glass_mat := mats.get("glass") as StandardMaterial3D
    if glass_mat:
        glass_mat.albedo_color = Color(0.26, 0.39, 0.40, 0.34)

    var wall_mat := mats.get("wall") as StandardMaterial3D
    if wall_mat:
        wall_mat.albedo_color = Color(0.76, 0.78, 0.74)

    var ceiling_mat := mats.get("ceiling") as StandardMaterial3D
    if ceiling_mat:
        ceiling_mat.albedo_color = Color(0.86, 0.87, 0.83)

func _brighten_environment() -> void:
    var env_node := find_child("WorldEnvironment", true, false) as WorldEnvironment
    if env_node and env_node.environment:
        env_node.environment.ambient_light_color = Color(0.34, 0.38, 0.38)
        env_node.environment.ambient_light_energy = 0.46

    if is_instance_valid(moon_light):
        moon_light.light_energy = 0.28

    var entrance := find_child("EntranceNightLight", true, false) as OmniLight3D
    if entrance:
        entrance.light_color = Color(0.88, 0.92, 0.84)
        entrance.light_energy = 1.90
        entrance.omni_range = 12.0

func _apply_combined_layout_hotfix() -> void:
    var floor1 := get_node_or_null("KheMayStation/Floor1") as Node3D
    var floor2 := get_node_or_null("KheMayStation/Floor2") as Node3D
    if floor1 == null or floor2 == null:
        return

    var kit := KheMayBuildKit.new(mats)

    # 1) Clear both side routes around reception.
    _remove_children_with_prefix(floor1, "WaitingBenchA")
    _remove_children_with_prefix(floor1, "WaitingBenchB")
    # Waiting seats now sit near the front corners, facing reception, while the
    # left and right circulation lanes around the counter remain completely open.
    kit.bench(floor1, Vector3(-3.25, 0, 14.75), 1.75, "WaitingBenchA")
    kit.bench(floor1, Vector3(3.25, 0, 14.75), 1.75, "WaitingBenchB")

    # 2) A real staff chair behind the reception desk.
    if floor1.get_node_or_null("ReceptionStaffChair") == null:
        kit.chair(floor1, Vector3(-1.20, 0, 11.15), PI, "ReceptionStaffChair")

    # 3) Cut a genuine stairwell opening through the first-floor ceiling.
    # The previous single ceiling mesh covered the stairwell even though floor 2
    # had a void, creating the low "roof" seen while climbing.
    var old_ceiling := floor1.get_node_or_null("F1_Ceiling")
    if old_ceiling:
        floor1.remove_child(old_ceiling)
        old_ceiling.queue_free()
    _remove_children_with_prefix(floor1, "F1CeilingHotfix")
    var ceiling_y := KheMayBuildKit.WALL_H + 0.06
    # Stair void: x -4.0..2.0, z -4.8..6.6.
    kit.mesh_box(floor1, Vector3(-12.0, ceiling_y, 0), Vector3(16.0, 0.12, 34.0), mats.ceiling, "F1CeilingHotfix_Left")
    kit.mesh_box(floor1, Vector3(11.0, ceiling_y, 0), Vector3(18.0, 0.12, 34.0), mats.ceiling, "F1CeilingHotfix_Right")
    kit.mesh_box(floor1, Vector3(-1.0, ceiling_y, 11.8), Vector3(6.0, 0.12, 10.4), mats.ceiling, "F1CeilingHotfix_North")
    kit.mesh_box(floor1, Vector3(-1.0, ceiling_y, -10.9), Vector3(6.0, 0.12, 12.2), mats.ceiling, "F1CeilingHotfix_South")

    # 4) The return flight used tall boxes whose bottoms all began at the landing,
    # making a huge hanging block over the first flight. Keep the existing smooth
    # collision ramp, but rebuild the visible return flight as real 17 cm risers
    # with 29 cm treads and a thin structural profile.
    _remove_children_with_prefix(floor1, "StairB_")
    var floor_height := 3.75
    var risers_per_flight := 11
    var riser := floor_height / 22.0
    var tread := 0.29
    var flight_w := 1.65
    var landing_y := riser * float(risers_per_flight)
    var second_x := -0.075
    var landing_z := 0.60
    var landing_depth := 1.65
    var second_start_z := landing_z + landing_depth * 0.5 + tread * 0.5
    for i in range(risers_per_flight):
        var top_y := landing_y + riser * float(i + 1)
        var z := second_start_z + tread * float(i)
        kit.mesh_box(
            floor1,
            Vector3(second_x, top_y - 0.07, z),
            Vector3(flight_w, 0.14, tread),
            mats.metal,
            "StairB_HotfixTread_%02d" % i
        )
        kit.mesh_box(
            floor1,
            Vector3(second_x, top_y - riser * 0.5, z - tread * 0.5 + 0.025),
            Vector3(flight_w, riser, 0.05),
            mats.metal,
            "StairB_HotfixRiser_%02d" % i
        )

    # Give the top landing extra clear space before the second-floor slab starts.
    _remove_child_if_exists(floor2, "F2_NorthBridge_Mesh")
    _remove_child_if_exists(floor2, "F2_NorthBridge_Body")
    kit.floor(floor2, Vector3(-1.0, 0, 8.85), Vector2(6.0, 3.30), mats.floor, "F2_NorthBridge")

    _make_main_door_material_visible(floor1)

func _make_main_door_material_visible(floor1: Node3D) -> void:
    var base := mats.get("door") as StandardMaterial3D
    if base == null:
        return
    var main_door_mat := base.duplicate() as StandardMaterial3D
    main_door_mat.albedo_color = Color(0.64, 0.49, 0.31)
    main_door_mat.roughness = 0.62
    main_door_mat.emission_enabled = true
    main_door_mat.emission = Color(0.13, 0.09, 0.055)
    main_door_mat.emission_energy_multiplier = 0.72
    for door_name in ["MainOuterDoor_L", "MainOuterDoor_R", "MainInnerDoor_L", "MainInnerDoor_R"]:
        var door := floor1.get_node_or_null(door_name)
        if door:
            var leaf := door.get_node_or_null("Leaf") as MeshInstance3D
            if leaf:
                leaf.material_override = main_door_mat

func _remove_children_with_prefix(parent: Node, prefix: String) -> void:
    var victims: Array[Node] = []
    for child in parent.get_children():
        if str(child.name).begins_with(prefix):
            victims.append(child)
    for child in victims:
        parent.remove_child(child)
        child.queue_free()

func _remove_child_if_exists(parent: Node, child_name: String) -> void:
    var child := parent.get_node_or_null(child_name)
    if child:
        parent.remove_child(child)
        child.queue_free()

func _boost_existing_fixtures() -> void:
    _boost_recursive(self)

func _boost_recursive(node: Node) -> void:
    for child in node.get_children():
        if child is OmniLight3D and str(child.name).contains("_Omni"):
            var light := child as OmniLight3D
            light.light_energy = max(light.light_energy * 2.15, 1.35)
            light.omni_range = max(light.omni_range, 7.4)
            light.light_color = Color(0.90, 0.95, 0.91)
        _boost_recursive(child)

func _add_front_door_lighting() -> void:
    # These two lights are deliberately not tagged *_Omni so the atmosphere
    # flicker system cannot turn the entrance into a black rectangle again.
    var exterior := OmniLight3D.new()
    exterior.name = "FrontDoorPermanentExteriorFill"
    exterior.position = Vector3(0, 2.25, 24.8)
    exterior.light_color = Color(0.96, 0.91, 0.80)
    exterior.light_energy = 2.55
    exterior.omni_range = 9.5
    exterior.shadow_enabled = false
    add_child(exterior)

    var vestibule := OmniLight3D.new()
    vestibule.name = "FrontDoorPermanentVestibuleFill"
    vestibule.position = Vector3(0, 2.35, 19.2)
    vestibule.light_color = Color(0.92, 0.96, 0.90)
    vestibule.light_energy = 2.10
    vestibule.omni_range = 8.5
    vestibule.shadow_enabled = false
    add_child(vestibule)

func _add_hallway_fill_lights() -> void:
    # Tầng 1: sảnh + hành lang trung tâm + dãy phòng 01-05.
    var floor1_points := [
        Vector3(0.0, 2.92, 20.2),
        Vector3(0.0, 2.92, 15.0),
        Vector3(2.6, 2.92, 11.8),
        Vector3(2.6, 2.92, 7.0),
        Vector3(2.6, 2.92, 2.0),
        Vector3(2.6, 2.92, -3.0),
        Vector3(2.6, 2.92, -8.0),
        Vector3(2.6, 2.92, -13.0),
        Vector3(-5.1, 2.92, 11.0),
        Vector3(-5.1, 2.92, 2.0),
        Vector3(-5.1, 2.92, -8.0)
    ]
    for i in range(floor1_points.size()):
        _make_fill_light(floor1_points[i], 1.65, 8.2, "F1HallFill_%02d_Omni" % i)

    # Tầng 2: hành lang quanh lõi cầu thang và các phòng trực/CCTV/hồ sơ/nghỉ.
    var y2 := F2_Y + 2.90
    var floor2_points := [
        Vector3(-8.5, y2, 6.8),
        Vector3(0.0, y2, 6.8),
        Vector3(8.5, y2, 6.8),
        Vector3(-8.0, y2, 0.0),
        Vector3(4.0, y2, 0.0),
        Vector3(-8.0, y2, -6.2),
        Vector3(8.0, y2, -6.2)
    ]
    for i in range(floor2_points.size()):
        _make_fill_light(floor2_points[i], 1.55, 8.0, "F2HallFill_%02d_Omni" % i)

    # Khu kỹ thuật phía sau vẫn sáng làm việc, nhưng yếu hơn khu khám chữa bệnh.
    _make_fill_light(Vector3(-7.0, 2.75, -23.8), 1.25, 7.0, "RearUtilityFill_Omni")

func _make_fill_light(pos: Vector3, energy: float, light_range: float, light_name: String) -> void:
    var light := OmniLight3D.new()
    light.name = light_name
    light.position = pos
    light.light_color = Color(0.90, 0.95, 0.91)
    light.light_energy = energy
    light.omni_range = light_range
    light.shadow_enabled = false
    add_child(light)
