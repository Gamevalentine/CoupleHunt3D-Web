class_name KheMayFloor2Builder
extends RefCounted

static func build(f: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats

    # Real stairwell opening. The U-stair below occupies only the center, while
    # the surrounding floor remains safely guarded.
    k.floor(f, Vector3(-9.0, 0, 0), Vector2(10, 21), m.floor, "F2_LeftSlab")
    k.floor(f, Vector3(8.0, 0, 0), Vector2(12, 21), m.floor, "F2_RightSlab")
    k.floor(f, Vector3(-1.0, 0, 8.25), Vector2(6, 4.5), m.floor, "F2_NorthBridge")
    k.floor(f, Vector3(-1.0, 0, -7.5), Vector2(6, 6), m.floor, "F2_SouthBridge")
    k.ceiling(f, Vector3.ZERO, Vector2(28, 21), m.ceiling, "F2_Ceiling")

    k.wall_x_with_windows(f, 10.5, -14, 14, [
        {"x": -9.2, "w": 2.5},
        {"x": 0.0, "w": 2.5},
        {"x": 9.2, "w": 2.5}
    ], m.wall, "F2_North")
    k.wall_x_opening(f, 0, -10.5, 28, 0, 2, k.DOOR_H, m.wall, "F2_BalconyDoor")
    k.door_x(f, 0, -10.5, 2.0, "BalconyDoor", "cửa ban công", 95.0, false, "", false, true)
    k.wall_z_with_windows(f, -14, -10.5, 10.5, [{"z": -6.8, "w": 2.1}], m.wall, "F2_West")
    k.wall_z_with_windows(f, 14, -10.5, 10.5, [{"z": -6.8, "w": 2.1}], m.wall, "F2_East")

    k.wall_x(f, -9.25, 2.3, 9.5, m.wall, "Duty_South")
    k.wall_z_opening(f, -4.5, 6.4, 8.2, 5.8, 1.45, k.DOOR_H, m.wall, "Duty_Door")
    k.door_z(f, -4.5, 5.8, 1.45, "DutyDoor", "cửa phòng trực", 95.0)
    k.wall_x(f, 0, 2.3, 9, m.wall, "CCTV_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 5.8, 1.45, k.DOOR_H, m.wall, "CCTV_Door")
    k.door_z(f, 4.5, 5.8, 1.45, "CCTVDoor", "cửa phòng CCTV", -95.0)
    k.wall_x(f, 9.25, 2.3, 9.5, m.wall, "Archive_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 7, 1.45, k.DOOR_H, m.wall, "Archive_Door")
    k.door_z(f, 4.5, 7, 1.45, "ArchiveDoor", "cửa phòng hồ sơ", 95.0)

    # 1.10 m guard rails around the void. The north opening is only 1.85 m,
    # aligned with the 1.65 m second flight and its top landing.
    k.solid_box(f, Vector3(-3.82, 0.55, 0.75), Vector3(0.12, 1.10, 10.5), m.metal, "F2_StairRailWest")
    k.solid_box(f, Vector3(1.82, 0.55, 0.10), Vector3(0.12, 1.10, 9.2), m.metal, "F2_StairRailEast")
    k.solid_box(f, Vector3(-1.0, 0.55, -4.42), Vector3(5.7, 1.10, 0.12), m.metal, "F2_StairRailSouth")

    # Opening center is x=-0.075; clear width 1.85 m.
    k.solid_box(f, Vector3(-2.40, 0.55, 5.92), Vector3(2.80, 1.10, 0.12), m.metal, "F2_StairRailNorthLeft")
    k.solid_box(f, Vector3(1.335, 0.55, 5.92), Vector3(0.97, 1.10, 0.12), m.metal, "F2_StairRailNorthRight")

    k.wall_x(f, -8, -4, 12, m.wall, "F2_LeftLower_North")
    k.wall_z_opening(f, -2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_LeftLower_Door")
    k.door_z(f, -2, -6.3, 1.45, "F2LeftLowerDoor", "cửa khu vệ sinh", -95.0)
    k.wall_x(f, 8, -4, 12, m.wall, "F2_Rest_North")
    k.wall_z_opening(f, 2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_Rest_Door")
    k.door_z(f, 2, -6.3, 1.45, "RestDoor", "cửa phòng nghỉ", 95.0)

    k.floor(f, Vector3(0, 0, -12), Vector2(28, 3), m.utility, "F2_Balcony")
    k.solid_box(f, Vector3(0, 0.65, -13.4), Vector3(28, 1.3, 0.22), m.metal, "F2_BalconyRail")

    _furnish(f, k)
    _lights(f, k)

static func _furnish(f: Node3D, k: KheMayBuildKit) -> void:
    k.table(f, Vector3(-9.2, 0, 5.9), Vector2(2.0, 0.78), "DutyDesk")
    k.chair(f, Vector3(-9.2, 0, 4.8), PI, "DutyChair")
    k.bed(f, Vector3(-11.2, 0, 8.1), "DutyBed")
    k.cabinet(f, Vector3(-6.0, 0, 8.6), Vector3(1.4, 1.9, 0.55), "DutyLocker")

    k.table(f, Vector3(0, 0, 5.0), Vector2(2.5, 0.78), "CCTVDesk")
    k.chair(f, Vector3(0, 0, 3.95), PI, "CCTVChair")
    for x in [-1.8, 0.0, 1.8]:
        k.mesh_box(f, Vector3(x, 1.65, 8.9), Vector3(1.45, 0.86, 0.10), k.mats.glass, "CCTVMonitor")
        k.mesh_box(f, Vector3(x, 1.65, 8.96), Vector3(1.58, 0.98, 0.05), k.mats.window_frame, "CCTVFrame")

    k.cabinet(f, Vector3(9.4, 0, 8.7), Vector3(5.0, 2.0, 0.62), "ArchiveCabinet")
    k.table(f, Vector3(9.0, 0, 4.3), Vector2(1.7, 0.72), "ArchiveDesk")
    k.chair(f, Vector3(9.0, 0, 3.3), PI, "ArchiveChair")

    k.sink(f, Vector3(-11.8, 0, -8.9), "F2SinkA")
    k.sink(f, Vector3(-7.8, 0, -8.9), "F2SinkB")
    k.cabinet(f, Vector3(-4.4, 0, -8.8), Vector3(1.2, 1.8, 0.50), "F2LinenCabinet")

    k.bed(f, Vector3(8.4, 0, -7.0), "RestBedA")
    k.bed(f, Vector3(11.2, 0, -7.0), "RestBedB")
    k.cabinet(f, Vector3(5.0, 0, -8.8), Vector3(1.4, 1.9, 0.55), "RestLocker")
    k.table(f, Vector3(9.8, 0, -4.9), Vector2(1.25, 0.70), "RestTable")
    k.chair(f, Vector3(8.9, 0, -4.9), -PI * 0.5, "RestChairA")
    k.chair(f, Vector3(10.7, 0, -4.9), PI * 0.5, "RestChairB")

static func _lights(f: Node3D, k: KheMayBuildKit) -> void:
    for p in [
        Vector3(-9.2, 3.16, 6.7),
        Vector3(0, 3.16, 6.7),
        Vector3(9.2, 3.16, 6.7),
        Vector3(-8.0, 3.16, -7.0),
        Vector3(8.0, 3.16, -7.0),
        Vector3(-1.0, 3.16, -1.0)
    ]:
        k.ceiling_light(f, p, 0.68, 5.3, "F2Light")
