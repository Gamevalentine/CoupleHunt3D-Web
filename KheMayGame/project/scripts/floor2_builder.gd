class_name KheMayFloor2Builder
extends RefCounted

static func build(f: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(f, Vector3(-8.5, 0, 0), Vector2(11, 21), m.floor, "F2_LeftSlab")
    k.floor(f, Vector3(7.5, 0, 0), Vector2(13, 21), m.floor, "F2_RightSlab")
    k.floor(f, Vector3(-1, 0, 8.25), Vector2(4, 4.5), m.floor, "F2_NorthBridge")
    k.floor(f, Vector3(-1, 0, -7.5), Vector2(4, 6), m.floor, "F2_SouthBridge")
    k.ceiling(f, Vector3.ZERO, Vector2(28, 21), m.wall, "F2_Ceiling")

    k.wall_x(f, 0, 10.5, 28, m.wall, "F2_North")
    k.wall_x_opening(f, 0, -10.5, 28, 0, 2, k.DOOR_H, m.wall, "F2_BalconyDoor")
    k.wall_z(f, -14, 0, 21, m.wall, "F2_West")
    k.wall_z(f, 14, 0, 21, m.wall, "F2_East")

    k.wall_x(f, -9.25, 2.3, 9.5, m.wall, "Duty_South")
    k.wall_z_opening(f, -4.5, 6.4, 8.2, 5.8, 1.45, k.DOOR_H, m.wall, "Duty_Door")
    k.wall_x(f, 0, 2.3, 9, m.wall, "CCTV_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 5.8, 1.45, k.DOOR_H, m.wall, "CCTV_Door")
    k.wall_x(f, 9.25, 2.3, 9.5, m.wall, "Archive_South")
    k.wall_z_opening(f, 4.5, 6.4, 8.2, 7, 1.45, k.DOOR_H, m.wall, "Archive_Door")

    k.wall_z(f, -3, 0.75, 10.5, m.wall, "F2_Stair_West")
    k.wall_z(f, 1, 0.75, 10.5, m.wall, "F2_Stair_East")
    k.wall_x(f, -8, -4, 12, m.wall, "F2_LeftLower_North")
    k.wall_z_opening(f, -2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_LeftLower_Door")
    k.wall_x(f, 8, -4, 12, m.wall, "F2_Rest_North")
    k.wall_z_opening(f, 2, -6.9, 5, -6.3, 1.45, k.DOOR_H, m.wall, "F2_Rest_Door")

    k.floor(f, Vector3(0, 0, -12), Vector2(28, 3), m.utility, "F2_Balcony")
    k.solid_box(f, Vector3(0, 0.65, -13.4), Vector3(28, 1.3, 0.22), m.utility, "F2_BalconyRail")
    k.solid_box(f, Vector3(-9, 0.55, 6.2), Vector3(3, 1.1, 0.9), m.utility, "DutyDesk")
    k.bed(f, Vector3(-11.2, 0.45, 8), "DutyBed")
    k.solid_box(f, Vector3(0, 1.15, 8), Vector3(5.8, 2.3, 0.35), m.glass, "CCTVMonitorWall")
    k.solid_box(f, Vector3(9.5, 1, 7.4), Vector3(5, 2, 0.8), m.utility, "ArchiveCabinet")
    k.bed(f, Vector3(8.4, 0.45, -7), "RestBed")
