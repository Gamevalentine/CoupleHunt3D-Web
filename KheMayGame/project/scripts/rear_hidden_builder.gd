class_name KheMayRearHiddenBuilder
extends RefCounted

static func build_rear(r: Node3D, k: KheMayBuildKit) -> void:
    var m := k.mats
    k.floor(r, Vector3(-3.2, 0, -18.8), Vector2(2, 3.6), m.floor, "RearConnector")
    k.floor(r, Vector3(-7.5, 0, -24), Vector2(15, 9), m.utility, "RearUtilityFloor")
    k.ceiling(r, Vector3(-7.5, 0, -24), Vector2(15, 9), m.ceiling, "RearUtilityCeiling")
    k.wall_x_opening(r, -7.5, -19.5, 15, -3.2, 1.65, k.DOOR_H, m.utility, "Rear_NorthDoor")
    k.door_x(r, -3.2, -19.5, 1.65, "RearUtilityDoor", "cửa khu máy phát", 95.0)
    k.wall_x_opening(r, -7.5, -28.5, 15, -1.5, 1.45, k.DOOR_H, m.utility, "Rear_SouthDoor")
    k.door_x(r, -1.5, -28.5, 1.45, "RearServiceDoor", "cửa kỹ thuật", -95.0)
    k.wall_z(r, -15, -24, 9, m.utility, "Rear_West")
    k.wall_z(r, 0, -24, 9, m.utility, "Rear_East")
    k.wall_z(r, -2.5, -24, 9, m.utility, "Rear_TechCorridor")

    k.solid_box(r, Vector3(-9, 0.85, -23.5), Vector3(4.6, 1.7, 2.2), m.metal, "Generator")
    k.mesh_box(r, Vector3(-9, 1.55, -22.35), Vector3(3.5, 0.22, 0.08), m.wall_accent, "GeneratorPanel")
    k.mesh_box(r, Vector3(-10.5, 1.58, -22.28), Vector3(0.20, 0.20, 0.05), m.light_panel, "GeneratorLamp")
    k.shelf(r, Vector3(-4.8, 0, -22.8), Vector3(2.8, 2.0, 0.70), "SupplyRack")
    k.shelf(r, Vector3(-12.8, 0, -26.8), Vector3(2.4, 2.0, 0.70), "ToolRack")
    k.cabinet(r, Vector3(-4.4, 0, -26.8), Vector3(1.7, 1.9, 0.58), "UtilityCabinet")
    k.mesh_box(r, Vector3(-1.9, 2.55, -24), Vector3(0.14, 0.14, 7.3), m.metal, "ServicePipe")
    k.ceiling_light(r, Vector3(-8.8, 3.16, -24), 0.52, 5.0, "RearLight")
    k.ceiling_light(r, Vector3(-3.8, 3.16, -24), 0.42, 4.2, "TechLight")

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

    k.bed(h, Vector3(17.8, 0, -11.5), "Room06Bed")
    k.cabinet(h, Vector3(18.7, 0, -15.5), Vector3(1.1, 1.65, 0.48), "Room06Cabinet")
    k.mesh_box(h, Vector3(19.75, 2.55, -10), Vector3(0.12, 0.12, 10.5), m.metal, "Room06Pipe")
    k.ceiling_light(h, Vector3(17.4, 3.05, -7.2), 0.18, 3.5, "Room06WeakLight")
