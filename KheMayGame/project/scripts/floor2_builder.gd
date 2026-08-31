class_name KheMayFloor2Builder
extends RefCounted

const STAIR_CENTER_X := -1.0
const STAIR_OPEN_MIN_X := -2.15
const STAIR_OPEN_MAX_X := 0.15
const STAIR_OPEN_MIN_Z := -2.45
const STAIR_OPEN_MAX_Z := 2.55

static func build(f: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    _build_floor_around_stair_opening(f, k)
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
    k.door_z(f, -4.5, 5.8, 1.45, "DutyDoor", "cửa phòng trực", 95.0, false, "", false, true)
    k.wall_x(f, 0, 2.3, 9, m.wall, "CCTV_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 5.8, 1.45, k.DOOR_H, m.wall, "CCTV_Door")
    k.door_z(f, 4.5, 5.8, 1.45, "CCTVDoor", "cửa phòng CCTV", -95.0, false, "", false, true)
    k.wall_x(f, 9.25, 2.3, 9.5, m.wall, "Archive_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 7, 1.45, k.DOOR_H, m.wall, "Archive_Door")
    k.door_z(f, 4.5, 7, 1.45, "ArchiveDoor", "cửa phòng hồ sơ", 95.0, false, "", false, true)

    _build_stair_guard(f, k)

    k.wall_x(f, -8, -4, 12, m.wall, "F2_LeftLower_North")
    k.wall_z_opening(f, -2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_LeftLower_Door")
    k.door_z(f, -2, -6.3, 1.45, "F2LeftLowerDoor", "cửa khu vệ sinh", -95.0)
    k.wall_x(f, 8, -4, 12, m.wall, "F2_Rest_North")
    k.wall_z_opening(f, 2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_Rest_Door")
    k.door_z(f, 2, -6.3, 1.45, "RestDoor", "cửa phòng nghỉ", 95.0, false, "", false, true)

    k.floor(f, Vector3(0, 0, -12), Vector2(28, 3), m.utility, "F2_Balcony")
    k.solid_box(f, Vector3(0, 0.65, -13.4), Vector3(28, 1.3, 0.22), m.metal, "F2_BalconyRail")

    _furnish(f, k)
    _lights(f, k)

static func _build_floor_around_stair_opening(f: Node3D, k: KheMayBuildKit) -> void:
    # Compact opening only where the player's head needs clearance on the upper stair.
    var left_w := STAIR_OPEN_MIN_X + 14.0
    var right_w := 14.0 - STAIR_OPEN_MAX_X
    var north_d := 10.5 - STAIR_OPEN_MAX_Z
    var south_d := STAIR_OPEN_MIN_Z + 10.5
    k.floor(f, Vector3(-14.0 + left_w * 0.5, 0, 0), Vector2(left_w, 21), k.mats.floor, "F2_LeftSlab")
    k.floor(f, Vector3(STAIR_OPEN_MAX_X + right_w * 0.5, 0, 0), Vector2(right_w, 21), k.mats.floor, "F2_RightSlab")
    k.floor(f, Vector3(STAIR_CENTER_X, 0, STAIR_OPEN_MAX_Z + north_d * 0.5), Vector2(STAIR_OPEN_MAX_X - STAIR_OPEN_MIN_X, north_d), k.mats.floor, "F2_NorthBridge")
    k.floor(f, Vector3(STAIR_CENTER_X, 0, -10.5 + south_d * 0.5), Vector2(STAIR_OPEN_MAX_X - STAIR_OPEN_MIN_X, south_d), k.mats.floor, "F2_SouthBridge")

static func _build_stair_guard(f: Node3D, k: KheMayBuildKit) -> void:
    var rail_h := 1.10
    var rail_t := 0.07
    var void_depth := STAIR_OPEN_MAX_Z - STAIR_OPEN_MIN_Z
    var void_width := STAIR_OPEN_MAX_X - STAIR_OPEN_MIN_X

    # Three clean sides; the south side is the direct stair exit.
    k.solid_box(f, Vector3(STAIR_OPEN_MIN_X, rail_h * 0.5, (STAIR_OPEN_MIN_Z + STAIR_OPEN_MAX_Z) * 0.5), Vector3(rail_t, rail_h, void_depth), k.mats.metal, "F2_StairGuardWest")
    k.solid_box(f, Vector3(STAIR_OPEN_MAX_X, rail_h * 0.5, (STAIR_OPEN_MIN_Z + STAIR_OPEN_MAX_Z) * 0.5), Vector3(rail_t, rail_h, void_depth), k.mats.metal, "F2_StairGuardEast")
    k.solid_box(f, Vector3(STAIR_CENTER_X, rail_h * 0.5, STAIR_OPEN_MAX_Z), Vector3(void_width, rail_h, rail_t), k.mats.metal, "F2_StairGuardNorth")

    var exit_w := 1.95
    var side_w := (void_width - exit_w) * 0.5
    if side_w > 0.02:
        k.solid_box(f, Vector3(STAIR_OPEN_MIN_X + side_w * 0.5, rail_h * 0.5, STAIR_OPEN_MIN_Z), Vector3(side_w, rail_h, rail_t), k.mats.metal, "F2_StairGuardSouthLeft")
        k.solid_box(f, Vector3(STAIR_OPEN_MAX_X - side_w * 0.5, rail_h * 0.5, STAIR_OPEN_MIN_Z), Vector3(side_w, rail_h, rail_t), k.mats.metal, "F2_StairGuardSouthRight")

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
