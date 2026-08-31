extends "res://scripts/windowed_main.gd"

func _ready() -> void:
    super._ready()
    _brighten_materials()
    _brighten_environment()
    _boost_existing_fixtures()
    _add_hallway_fill_lights()
    _add_front_door_lighting()
    if is_instance_valid(atmosphere):
        atmosphere.refresh_fluorescent_sources(self)

func _brighten_materials() -> void:
    # Door material doubles as the frame material for full-glass doors.
    # Use neutral aluminium instead of brown wood so glass doors read correctly.
    var door_mat := mats.get("door") as StandardMaterial3D
    if door_mat:
        door_mat.albedo_color = Color(0.20, 0.23, 0.24)
        door_mat.roughness = 0.46
        door_mat.metallic = 0.68

    var frame_mat := mats.get("window_frame") as StandardMaterial3D
    if frame_mat:
        frame_mat.albedo_color = Color(0.24, 0.27, 0.28)
        frame_mat.roughness = 0.44
        frame_mat.metallic = 0.72

    var glass_mat := mats.get("glass") as StandardMaterial3D
    if glass_mat:
        glass_mat.albedo_color = Color(0.34, 0.48, 0.49, 0.26)
        glass_mat.roughness = 0.12

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
    # Permanent entrance fill. Atmosphere flicker does not control these lights.
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
