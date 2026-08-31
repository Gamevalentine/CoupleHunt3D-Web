class_name KheMayFloor1Builder
extends RefCounted

const MAIN_DOOR_W := 4.60

static func build(f: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(f, Vector3.ZERO, Vector2(40, 34), m.floor, "F1_Floor")
    k.ceiling(f, Vector3.ZERO, Vector2(40, 34), m.ceiling, "F1_Ceiling")

    k.wall_x_opening(f, 0, 17, 40, 0, MAIN_DOOR_W, 2.55, m.wall, "F1_North_MainDoor")
    k.double_door_x(f, 0, 17, MAIN_DOOR_W, "MainInnerDoor", "cửa sảnh", true)
    k.wall_x_opening(f, 0, -17, 40, -3.2, 1.65, k.DOOR_H, m.wall, "F1_South_StaffDoor")
    k.door_x(f, -3.2, -17, 1.65, "StaffRearDoor", "cửa sau")
    k.wall_z_with_windows(f, -20, -17, 17, [
        {"z": 11.5, "w": 2.6},
        {"z": 1.5, "w": 2.6},
        {"z": -11.5, "w": 1.6, "sill": 1.25, "h": 1.0}
    ], m.wall, "F1_West")
    k.wall_z(f, 20, 0, 34, m.wall, "F1_East")

    k.floor(f, Vector3(0, 0, 19.75), Vector2(9, 5.5), m.floor, "Entrance_Floor")
    k.ceiling(f, Vector3(0, 0, 19.75), Vector2(9, 5.5), m.ceiling, "Entrance_Ceiling")
    k.wall_z_with_windows(f, -4.5, 17, 22.5, [{"z": 19.75, "w": 2.15, "sill": 0.85, "h": 1.45}], m.wall, "Entrance_West")
    k.wall_z_with_windows(f, 4.5, 17, 22.5, [{"z": 19.75, "w": 2.15, "sill": 0.85, "h": 1.45}], m.wall, "Entrance_East")
    k.wall_x_opening(f, 0, 22.5, 9, 0, MAIN_DOOR_W, 2.60, m.wall, "Entrance_OuterDoor")
    k.double_door_x(f, 0, 22.5, MAIN_DOOR_W, "MainOuterDoor", "cửa chính", true)
    k.floor(f, Vector3(0, 0, 25), Vector2(6.5, 5), m.outdoor, "FrontApproach")

    for p in [Vector3(-19.85, 1.65, 16.85), Vector3(19.85, 1.65, 16.85), Vector3(-19.85, 1.65, -16.85), Vector3(19.85, 1.65, -16.85)]:
        k.collision_box(f, p, Vector3(0.90, k.WALL_H, 0.90), "CornerBackstop")

    k.wall_z_opening(f, -7, 11.5, 11, 11.5, 1.65, k.DOOR_H, m.wall, "Clinic_Door")
    k.door_z(f, -7, 11.5, 1.65, "ClinicDoor", "cửa phòng khám", -95.0)
    k.wall_x(f, -13.5, 6, 13, m.wall, "Clinic_South")
    k.wall_z_opening(f, -7, 1.5, 9, 1.5, 1.65, k.DOOR_H, m.wall, "Emergency_Door")
    k.door_z(f, -7, 1.5, 1.65, "EmergencyDoor", "cửa phòng cấp cứu", 95.0)
    k.wall_x(f, -13.5, -3, 13, m.wall, "Emergency_South")

    k.wall_x_opening(f, -17.5, -6, 5, -17.5, 1.25, k.DOOR_H, m.wall, "WCMale_Door")
    k.door_x(f, -17.5, -6, 1.25, "WCMaleDoor", "cửa WC Nam", 92.0)
    k.wall_x_opening(f, -12.5, -6, 5, -12.5, 1.25, k.DOOR_H, m.wall, "WCFemale_Door")
    k.door_x(f, -12.5, -6, 1.25, "WCFemaleDoor", "cửa WC Nữ", -92.0)
    k.wall_x_opening(f, -6.5, -6, 7, -6.5, 1.45, k.DOOR_H, m.wall, "Pharmacy_Door")
    k.door_x(f, -6.5, -6, 1.45, "PharmacyDoor", "cửa kho thuốc", 95.0)
    k.wall_z(f, -15, -11.5, 11, m.wall, "WC_Split")
    k.wall_z(f, -10, -11.5, 11, m.wall, "WC_Pharmacy_Split")
    k.wall_z(f, -3, -11.5, 11, m.wall, "Pharmacy_East")

    # Stair core: generous enough for a 1.65 m medical-building stair on each flight.
    k.wall_z(f, -4, 0.5, 11.0, m.wall, "Stair_West")
    k.wall_z(f, 2, 0.5, 11.0, m.wall, "Stair_East")
    _stairs(f, k)

    var room_z := [13.75, 7.5, 1.5, -4.75, -12.5]
    var room_lengths := [6.5, 6.0, 6.0, 6.5, 9.0]
    for i in range(5):
        k.wall_z_opening(f, 5, room_z[i], room_lengths[i], room_z[i], k.DOOR_W, k.DOOR_H, m.wall, "Room%02d_Door" % (i + 1))
        k.door_z(f, 5, room_z[i], k.DOOR_W, "Room%02dDoor" % (i + 1), "cửa Phòng %02d" % (i + 1), 95.0 if i % 2 == 0 else -95.0, false, "", false, i == 4)
    for split_z in [10.5, 4.5, -1.5, -8.0]:
        k.wall_x(f, 9.25, split_z, 8.5, m.wall, "WardSplit")

    k.wall_z_opening(f, 15, 6.5, 17, 12.5, k.DOOR_W, k.DOOR_H, m.wall, "OldStore_Door")
    k.door_z(f, 15, 12.5, k.DOOR_W, "OldStoreDoor", "cửa kho cũ", -95.0)
    k.wall_x(f, 17.5, 15, 5, m.wall, "OldStore_North")
    k.wall_x(f, 17.5, -2, 5, m.wall, "OldStore_South")
    k.solid_box(f, Vector3(14.25, k.WALL_H * 0.5, -12.5), Vector3(1.5, k.WALL_H, 9), m.fake_wall, "SealedWall_BehindRoom05")

    _furnish(f, k, room_z)
    _lights(f, k, room_z)

static func _furnish(f: Node3D, k: KheMayBuildKit, room_z: Array) -> void:
    k.reception_desk(f, Vector3(-1.2, 0, 12.2), 4.8, "ReceptionDesk")
    k.bench(f, Vector3(-4.0, 0, 9.8), 2.8, "WaitingBenchA")
    k.bench(f, Vector3(2.7, 0, 10.0), 2.4, "WaitingBenchB")

    k.bed(f, Vector3(-13, 0, 11), "ClinicExamBed")
    k.table(f, Vector3(-16.3, 0, 8.4), Vector2(1.5, 0.72), "ClinicDesk")
    k.chair(f, Vector3(-16.3, 0, 9.45), PI, "ClinicChair")
    k.cabinet(f, Vector3(-18.7, 0, 7.6), Vector3(1.5, 1.9, 0.50), "ClinicCabinet")
    k.sink(f, Vector3(-18.8, 0, 14.7), "ClinicSink")

    k.bed(f, Vector3(-15.2, 0, 1.3), "EmergencyBedA")
    k.bed(f, Vector3(-10.8, 0, 1.3), "EmergencyBedB")
    k.medical_cart(f, Vector3(-13, 0, -0.4), "EmergencyCart")
    k.cabinet(f, Vector3(-18.6, 0, -1.8), Vector3(1.5, 1.9, 0.50), "EmergencyCabinet")

    k.sink(f, Vector3(-18.4, 0, -14.8), "WCMaleSink")
    k.sink(f, Vector3(-13.0, 0, -14.8), "WCFemaleSink")

    k.shelf(f, Vector3(-6.4, 0, -10), Vector3(4.8, 2.0, 0.55), "PharmacyShelfA")
    k.shelf(f, Vector3(-6.4, 0, -14), Vector3(4.8, 2.0, 0.55), "PharmacyShelfB")
    k.cabinet(f, Vector3(-4.2, 0, -15.7), Vector3(1.35, 1.9, 0.50), "PharmacyCabinet")
    k.table(f, Vector3(-8.2, 0, -8.1), Vector2(1.5, 0.72), "PharmacyDesk")

    for i in range(5):
        k.bed(f, Vector3(9, 0, room_z[i]), "Bed%02d" % (i + 1))
        k.cabinet(f, Vector3(11.2, 0, room_z[i] + 1.25), Vector3(0.72, 0.82, 0.52), "Bedside%02d" % (i + 1))
        k.chair(f, Vector3(12.0, 0, room_z[i] - 1.2), PI * 0.5, "WardChair%02d" % (i + 1))

    k.shelf(f, Vector3(18.2, 0, 11.6), Vector3(2.4, 2.1, 0.60), "OldStoreShelfA")
    k.shelf(f, Vector3(18.2, 0, 6.8), Vector3(2.4, 2.1, 0.60), "OldStoreShelfB")
    k.cabinet(f, Vector3(18.3, 0, 2.2), Vector3(1.8, 2.0, 0.58), "OldStoreCabinet")

static func _lights(f: Node3D, k: KheMayBuildKit, room_z: Array) -> void:
    for p in [Vector3(0, 3.16, 14), Vector3(0, 3.16, 8.5), Vector3(-13.5, 3.16, 11.5), Vector3(-13.5, 3.16, 1.5), Vector3(-6.5, 3.16, -11.5)]:
        k.ceiling_light(f, p, 0.78, 6.0, "F1Light")
    for z in room_z:
        k.ceiling_light(f, Vector3(9.5, 3.16, z), 0.66, 5.0, "WardLight")

static func _stairs(f: Node3D, k: KheMayBuildKit) -> void:
    # Real-world proportions for a public/medical building stair.
    # Floor-to-floor = 3.75 m, 22 risers => 170.5 mm/riser.
    # Tread = 290 mm. 2R + G = 631 mm, a comfortable real stair proportion.
    # Clear flight width = 1.65 m. Landing depth = 1.65 m.
    var floor_height := 3.75
    var total_risers := 22
    var risers_per_flight := 11
    var riser := floor_height / float(total_risers)
    var tread := 0.29
    var flight_w := 1.65
    var landing_depth := 1.65
    var first_x := -1.925
    var second_x := -0.075
    var first_start_z := 4.45
    var landing_z := 0.60
    var landing_y := riser * float(risers_per_flight)
    var flight_run := tread * float(risers_per_flight)
    var slope_len := sqrt(flight_run * flight_run + landing_y * landing_y)
    var slope_angle := atan2(landing_y, flight_run)

    # Visual first flight. Mesh only: collision is one smooth hidden ramp below.
    for i in range(risers_per_flight):
        var top_y := riser * float(i + 1)
        var z := first_start_z - tread * float(i)
        k.mesh_box(
            f,
            Vector3(first_x, top_y * 0.5, z),
            Vector3(flight_w, top_y, tread),
            k.mats.metal,
            "StairA_%02d" % i
        )

    # Real-size landing between flights.
    k.mesh_box(
        f,
        Vector3(-1.0, landing_y - 0.09, landing_z),
        Vector3(3.70, 0.18, landing_depth),
        k.mats.metal,
        "StairLanding"
    )
    k.collision_box(
        f,
        Vector3(-1.0, landing_y - 0.09, landing_z),
        Vector3(3.70, 0.18, landing_depth),
        "StairLandingCollision"
    )

    # Visual return flight. Solid-looking concrete/metal mass, but still mesh-only.
    var second_start_z := landing_z + landing_depth * 0.5 + tread * 0.5
    for i in range(risers_per_flight):
        var rel_top := riser * float(i + 1)
        var z2 := second_start_z + tread * float(i)
        k.mesh_box(
            f,
            Vector3(second_x, landing_y + rel_top * 0.5, z2),
            Vector3(flight_w, rel_top, tread),
            k.mats.metal,
            "StairB_%02d" % i
        )

    # Smooth collision ramp for first flight: prevents CharacterBody3D catching on step noses.
    var ramp_a := StaticBody3D.new()
    ramp_a.name = "StairRampA"
    var shape_a := CollisionShape3D.new()
    var box_a := BoxShape3D.new()
    box_a.size = Vector3(flight_w - 0.08, 0.18, slope_len)
    shape_a.shape = box_a
    shape_a.rotation.x = slope_angle
    shape_a.position = Vector3(
        first_x,
        landing_y * 0.5 - 0.04,
        first_start_z - flight_run * 0.5 + tread * 0.5
    )
    ramp_a.add_child(shape_a)
    f.add_child(ramp_a)

    # Smooth collision ramp for return flight.
    var ramp_b := StaticBody3D.new()
    ramp_b.name = "StairRampB"
    var shape_b := CollisionShape3D.new()
    var box_b := BoxShape3D.new()
    box_b.size = Vector3(flight_w - 0.08, 0.18, slope_len)
    shape_b.shape = box_b
    shape_b.rotation.x = -slope_angle
    shape_b.position = Vector3(
        second_x,
        landing_y + landing_y * 0.5 - 0.04,
        second_start_z + flight_run * 0.5 - tread * 0.5
    )
    ramp_b.add_child(shape_b)
    f.add_child(ramp_b)

    # Top landing meets the second-floor slab exactly at y = 3.75 m.
    k.mesh_box(
        f,
        Vector3(second_x, floor_height - 0.09, 5.30),
        Vector3(flight_w, 0.18, 1.40),
        k.mats.metal,
        "StairTopLanding"
    )
    k.collision_box(
        f,
        Vector3(second_x, floor_height - 0.09, 5.30),
        Vector3(flight_w, 0.18, 1.40),
        "StairTopLandingCollision"
    )

    # 1.05 m handrails: realistic height, visual only so they do not snag movement.
    var rail_h := 1.05
    var first_mid_z := first_start_z - flight_run * 0.5 + tread * 0.5
    for x in [first_x - flight_w * 0.5, first_x + flight_w * 0.5]:
        var rail_a := k.mesh_box(
            f,
            Vector3(x, landing_y * 0.5 + rail_h, first_mid_z),
            Vector3(0.06, 0.06, slope_len),
            k.mats.metal,
            "HandrailA"
        )
        rail_a.rotation.x = slope_angle

    var second_mid_z := second_start_z + flight_run * 0.5 - tread * 0.5
    for x in [second_x - flight_w * 0.5, second_x + flight_w * 0.5]:
        var rail_b := k.mesh_box(
            f,
            Vector3(x, landing_y + landing_y * 0.5 + rail_h, second_mid_z),
            Vector3(0.06, 0.06, slope_len),
            k.mats.metal,
            "HandrailB"
        )
        rail_b.rotation.x = -slope_angle

    # Guard at the back of the landing, 1.05 m high.
    k.solid_box(
        f,
        Vector3(-1.0, landing_y + rail_h * 0.5, landing_z - landing_depth * 0.5),
        Vector3(3.70, rail_h, 0.08),
        k.mats.metal,
        "LandingGuard"
    )
