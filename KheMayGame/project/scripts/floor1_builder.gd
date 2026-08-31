class_name KheMayFloor1Builder
extends RefCounted

const MAIN_DOOR_W := 4.60

static func build(f: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(f, Vector3.ZERO, Vector2(40, 34), m.floor, "F1_Floor")
    k.ceiling(f, Vector3.ZERO, Vector2(40, 34), m.wall, "F1_Ceiling")

    k.wall_x_opening(f, 0, 17, 40, 0, MAIN_DOOR_W, 2.55, m.wall, "F1_North_MainDoor")
    k.double_door_x(f, 0, 17, MAIN_DOOR_W, "MainInnerDoor", "cửa sảnh", true)
    k.wall_x_opening(f, 0, -17, 40, -3.2, 1.65, k.DOOR_H, m.wall, "F1_South_StaffDoor")
    k.door_x(f, -3.2, -17, 1.65, "StaffRearDoor", "cửa sau")
    k.wall_z(f, -20, 0, 34, m.wall, "F1_West")
    k.wall_z(f, 20, 0, 34, m.wall, "F1_East")

    k.floor(f, Vector3(0, 0, 19.75), Vector2(9, 5.5), m.floor, "Entrance_Floor")
    k.ceiling(f, Vector3(0, 0, 19.75), Vector2(9, 5.5), m.wall, "Entrance_Ceiling")
    k.wall_z(f, -4.5, 19.75, 5.5, m.wall, "Entrance_West")
    k.wall_z(f, 4.5, 19.75, 5.5, m.wall, "Entrance_East")
    k.wall_x_opening(f, 0, 22.5, 9, 0, MAIN_DOOR_W, 2.60, m.wall, "Entrance_OuterDoor")
    k.double_door_x(f, 0, 22.5, MAIN_DOOR_W, "MainOuterDoor", "cửa chính", true)
    k.floor(f, Vector3(0, 0, 25), Vector2(6.5, 5), m.floor, "FrontApproach")

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

    k.wall_z(f, -3, 1.5, 9, m.wall, "Stair_West")
    k.wall_z(f, 1, 1.5, 9, m.wall, "Stair_East")
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

    k.solid_box(f, Vector3(-1.2, 0.55, 12.2), Vector3(4.8, 1.1, 1), m.utility, "ReceptionDesk")
    for x in [-4.8, -3.1, -1.4]:
        k.solid_box(f, Vector3(x, 0.42, 9.8), Vector3(1.05, 0.84, 1), m.utility, "WaitingSeat")
    k.bed(f, Vector3(-13, 0.45, 11), "ClinicExamBed")
    k.bed(f, Vector3(-15.2, 0.45, 1.3), "EmergencyBedA")
    k.bed(f, Vector3(-10.8, 0.45, 1.3), "EmergencyBedB")
    k.solid_box(f, Vector3(-6.4, 1, -10), Vector3(4.8, 2, 0.7), m.utility, "PharmacyShelfA")
    k.solid_box(f, Vector3(-6.4, 1, -14), Vector3(4.8, 2, 0.7), m.utility, "PharmacyShelfB")
    for i in range(5):
        k.bed(f, Vector3(9, 0.45, room_z[i]), "Bed%02d" % (i + 1))

static func _stairs(f: Node3D, k: KheMayBuildKit) -> void:
    var start_z := 5.4
    var rise := 0.205
    var run := 0.50
    var steps := 18
    for i in range(steps):
        k.mesh_box(f, Vector3(-1, (i + 1) * rise * 0.5, start_z - i * run), Vector3(3.35, (i + 1) * rise, run), k.mats.utility, "Stair_%02d" % i)
    var total_run := float(steps) * run
    var total_rise := float(steps) * rise
    var body := StaticBody3D.new()
    body.name = "StairCollisionRamp"
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(3.1, 0.24, sqrt(total_run * total_run + total_rise * total_rise))
    shape.shape = box
    shape.rotation.x = atan2(total_rise, total_run)
    shape.position = Vector3(-1, total_rise * 0.5 - 0.08, start_z - total_run * 0.5)
    body.add_child(shape)
    f.add_child(body)
