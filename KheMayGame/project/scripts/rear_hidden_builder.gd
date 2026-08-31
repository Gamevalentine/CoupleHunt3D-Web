class_name KheMayRearHiddenBuilder
extends RefCounted

static func build_rear(r: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(r, Vector3(-3.2, 0, -18.8), Vector2(2, 3.6), m.floor, "RearConnector")
    k.floor(r, Vector3(-7.5, 0, -24), Vector2(15, 9), m.floor, "RearUtilityFloor")
    k.ceiling(r, Vector3(-7.5, 0, -24), Vector2(15, 9), m.utility, "RearUtilityCeiling")
    k.wall_x_opening(r, -7.5, -19.5, 15, -3.2, 1.65, k.DOOR_H, m.utility, "Rear_NorthDoor")
    k.door_x(r, -3.2, -19.5, 1.65, "RearUtilityDoor", "cửa khu máy phát", 95.0)
    k.wall_x_opening(r, -7.5, -28.5, 15, -1.5, 1.45, k.DOOR_H, m.utility, "Rear_SouthDoor")
    k.door_x(r, -1.5, -28.5, 1.45, "RearServiceDoor", "cửa kỹ thuật", -95.0)
    k.wall_z(r, -15, -24, 9, m.utility, "Rear_West")
    k.wall_z(r, 0, -24, 9, m.utility, "Rear_East")
    k.wall_z(r, -2.5, -24, 9, m.utility, "Rear_TechCorridor")
    k.solid_box(r, Vector3(-9, 0.85, -23.5), Vector3(4.6, 1.7, 2.2), m.utility, "Generator")
    k.solid_box(r, Vector3(-4.8, 1, -22.8), Vector3(2.8, 2, 0.8), m.utility, "SupplyRack")

static func build_hidden(h: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(h, Vector3(14.25, 0, -8.5), Vector2(1.5, 17), m.secret, "HiddenCorridorFloor")
    k.ceiling(h, Vector3(14.25, 0, -8.5), Vector2(1.5, 17), m.secret_wall, "HiddenCorridorCeiling")
    k.wall_z(h, 13.5, -8.5, 17, m.secret_wall, "HiddenCorridor_West")
    k.wall_z(h, 15, -8.5, 17, m.secret_wall, "HiddenCorridor_East")

    k.floor(h, Vector3(17.5, 0, -10), Vector2(5, 14), m.secret, "Room06Floor")
    k.ceiling(h, Vector3(17.5, 0, -10), Vector2(5, 14), m.secret_wall, "Room06Ceiling")
    k.wall_x(h, 17.5, -17, 5, m.secret_wall, "Room06_South")
    k.wall_z(h, 20, -10, 14, m.secret_wall, "Room06_East")
    k.wall_x(h, 17.5, -3, 5, m.secret_wall, "Room06_North")
    k.wall_z_opening(h, 15, -10, 14, -8, 1.45, k.DOOR_H, m.secret_wall, "Room06_Door")
    k.door_z(h, 15, -8, 1.45, "Room06Door", "cửa Phòng 06", 95.0, true, "room06_key", true, true)
    k.bed(h, Vector3(17.8, 0.45, -11.5), "Room06Bed")
