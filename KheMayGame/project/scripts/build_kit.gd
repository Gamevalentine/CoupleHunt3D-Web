class_name KheMayBuildKit
extends RefCounted

const WALL_H := 3.3
const WALL_T := 0.60
const DOOR_W := 1.55
const DOOR_H := 2.40
const FLOOR_T := 0.24
const DOOR_T := 0.10

var mats: Dictionary

func _init(materials: Dictionary) -> void:
    mats = materials

func mesh_box(parent: Node3D, pos: Vector3, size: Vector3, material: Material, name := "Mesh") -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.position = pos
    n.material_override = material
    parent.add_child(n)
    return n

func collision_box(parent: Node3D, pos: Vector3, size: Vector3, name := "Collision") -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = name
    body.position = pos
    body.collision_layer = 1
    body.collision_mask = 1
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    shape.shape = box
    body.add_child(shape)
    parent.add_child(body)
    return body

func solid_box(parent: Node3D, pos: Vector3, size: Vector3, material: Material, name := "Solid") -> void:
    mesh_box(parent, pos, size, material, name + "_Mesh")
    collision_box(parent, pos, size, name + "_Body")

func floor(parent: Node3D, center: Vector3, size_xz: Vector2, material: Material, name := "Floor") -> void:
    solid_box(parent, center + Vector3(0, -FLOOR_T * 0.5, 0), Vector3(size_xz.x, FLOOR_T, size_xz.y), material, name)

func ceiling(parent: Node3D, center: Vector3, size_xz: Vector2, material: Material, name := "Ceiling") -> void:
    mesh_box(parent, center + Vector3(0, WALL_H + 0.06, 0), Vector3(size_xz.x, 0.12, size_xz.y), material, name)

func wall_x(parent: Node3D, x: float, z: float, length: float, material: Material, name := "WallX") -> void:
    solid_box(parent, Vector3(x, WALL_H * 0.5, z), Vector3(length, WALL_H, WALL_T), material, name)
    baseboard_x(parent, x, z, length, name + "_Base")

func wall_z(parent: Node3D, x: float, z: float, length: float, material: Material, name := "WallZ") -> void:
    solid_box(parent, Vector3(x, WALL_H * 0.5, z), Vector3(WALL_T, WALL_H, length), material, name)
    baseboard_z(parent, x, z, length, name + "_Base")

func baseboard_x(parent: Node3D, x: float, z: float, length: float, name := "BaseboardX") -> void:
    if not mats.has("baseboard"):
        return
    mesh_box(parent, Vector3(x, 0.13, z - WALL_T * 0.52), Vector3(length, 0.26, 0.07), mats.baseboard, name)

func baseboard_z(parent: Node3D, x: float, z: float, length: float, name := "BaseboardZ") -> void:
    if not mats.has("baseboard"):
        return
    mesh_box(parent, Vector3(x - WALL_T * 0.52, 0.13, z), Vector3(0.07, 0.26, length), mats.baseboard, name)

func wall_x_opening(parent: Node3D, x: float, z: float, total: float, opening_x: float, opening_w: float, opening_h: float, material: Material, name := "WallOpenX") -> void:
    var min_x := x - total * 0.5
    var max_x := x + total * 0.5
    var left_len := opening_x - opening_w * 0.5 - min_x
    var right_len := max_x - (opening_x + opening_w * 0.5)
    if left_len > 0.02:
        wall_x(parent, min_x + left_len * 0.5, z, left_len, material, name + "_L")
    if right_len > 0.02:
        wall_x(parent, opening_x + opening_w * 0.5 + right_len * 0.5, z, right_len, material, name + "_R")
    var lintel_h := WALL_H - opening_h
    if lintel_h > 0.02:
        solid_box(parent, Vector3(opening_x, opening_h + lintel_h * 0.5, z), Vector3(opening_w, lintel_h, WALL_T), material, name + "_Lintel")

func wall_z_opening(parent: Node3D, x: float, z: float, total: float, opening_z: float, opening_w: float, opening_h: float, material: Material, name := "WallOpenZ") -> void:
    var min_z := z - total * 0.5
    var max_z := z + total * 0.5
    var near_len := opening_z - opening_w * 0.5 - min_z
    var far_len := max_z - (opening_z + opening_w * 0.5)
    if near_len > 0.02:
        wall_z(parent, x, min_z + near_len * 0.5, near_len, material, name + "_N")
    if far_len > 0.02:
        wall_z(parent, x, opening_z + opening_w * 0.5 + far_len * 0.5, far_len, material, name + "_F")
    var lintel_h := WALL_H - opening_h
    if lintel_h > 0.02:
        solid_box(parent, Vector3(x, opening_h + lintel_h * 0.5, opening_z), Vector3(WALL_T, lintel_h, opening_w), material, name + "_Lintel")

func wall_z_with_windows(parent: Node3D, x: float, z_min: float, z_max: float, windows: Array, material: Material, name := "WindowWallZ") -> void:
    var cursor := z_min
    for data in windows:
        var wz := float(data["z"])
        var ww := float(data["w"])
        var start := wz - ww * 0.5
        if start > cursor:
            wall_z(parent, x, (cursor + start) * 0.5, start - cursor, material, name + "_Segment")
        _window_section_z(parent, x, wz, ww, float(data.get("sill", 1.05)), float(data.get("h", 1.25)), material, name + "_Window")
        cursor = wz + ww * 0.5
    if cursor < z_max:
        wall_z(parent, x, (cursor + z_max) * 0.5, z_max - cursor, material, name + "_SegmentEnd")

func wall_x_with_windows(parent: Node3D, z: float, x_min: float, x_max: float, windows: Array, material: Material, name := "WindowWallX") -> void:
    var cursor := x_min
    for data in windows:
        var wx := float(data["x"])
        var ww := float(data["w"])
        var start := wx - ww * 0.5
        if start > cursor:
            wall_x(parent, (cursor + start) * 0.5, z, start - cursor, material, name + "_Segment")
        _window_section_x(parent, wx, z, ww, float(data.get("sill", 1.05)), float(data.get("h", 1.25)), material, name + "_Window")
        cursor = wx + ww * 0.5
    if cursor < x_max:
        wall_x(parent, (cursor + x_max) * 0.5, z, x_max - cursor, material, name + "_SegmentEnd")

func _window_section_z(parent: Node3D, x: float, z: float, width: float, sill: float, height: float, material: Material, name: String) -> void:
    solid_box(parent, Vector3(x, sill * 0.5, z), Vector3(WALL_T, sill, width), material, name + "_SillWall")
    var top_h := WALL_H - sill - height
    if top_h > 0.02:
        solid_box(parent, Vector3(x, sill + height + top_h * 0.5, z), Vector3(WALL_T, top_h, width), material, name + "_TopWall")
    solid_box(parent, Vector3(x, sill + height * 0.5, z), Vector3(0.08, height, max(0.15, width - 0.14)), mats.glass, name + "_Glass")
    mesh_box(parent, Vector3(x - 0.05, sill + height * 0.5, z - width * 0.5), Vector3(0.16, height + 0.12, 0.11), mats.window_frame, name + "_FrameA")
    mesh_box(parent, Vector3(x - 0.05, sill + height * 0.5, z + width * 0.5), Vector3(0.16, height + 0.12, 0.11), mats.window_frame, name + "_FrameB")
    mesh_box(parent, Vector3(x - 0.05, sill, z), Vector3(0.16, 0.11, width), mats.window_frame, name + "_FrameBottom")
    mesh_box(parent, Vector3(x - 0.05, sill + height, z), Vector3(0.16, 0.11, width), mats.window_frame, name + "_FrameTop")
    mesh_box(parent, Vector3(x - 0.05, sill + height * 0.5, z), Vector3(0.16, height, 0.07), mats.window_frame, name + "_Mullion")

func _window_section_x(parent: Node3D, x: float, z: float, width: float, sill: float, height: float, material: Material, name: String) -> void:
    solid_box(parent, Vector3(x, sill * 0.5, z), Vector3(width, sill, WALL_T), material, name + "_SillWall")
    var top_h := WALL_H - sill - height
    if top_h > 0.02:
        solid_box(parent, Vector3(x, sill + height + top_h * 0.5, z), Vector3(width, top_h, WALL_T), material, name + "_TopWall")
    solid_box(parent, Vector3(x, sill + height * 0.5, z), Vector3(max(0.15, width - 0.14), height, 0.08), mats.glass, name + "_Glass")
    mesh_box(parent, Vector3(x - width * 0.5, sill + height * 0.5, z - 0.05), Vector3(0.11, height + 0.12, 0.16), mats.window_frame, name + "_FrameA")
    mesh_box(parent, Vector3(x + width * 0.5, sill + height * 0.5, z - 0.05), Vector3(0.11, height + 0.12, 0.16), mats.window_frame, name + "_FrameB")
    mesh_box(parent, Vector3(x, sill, z - 0.05), Vector3(width, 0.11, 0.16), mats.window_frame, name + "_FrameBottom")
    mesh_box(parent, Vector3(x, sill + height, z - 0.05), Vector3(width, 0.11, 0.16), mats.window_frame, name + "_FrameTop")
    mesh_box(parent, Vector3(x, sill + height * 0.5, z - 0.05), Vector3(0.07, height, 0.16), mats.window_frame, name + "_Mullion")

func door_x(parent: Node3D, opening_x: float, z: float, width: float, door_id: String, display_name: String, open_degrees := 95.0, locked := false, key_id := "", story_locked := false, windowed := false) -> Node:
    return _door_leaf(parent, Vector3(opening_x - width * 0.5, 0, z), 0.0, width, door_id, display_name, open_degrees, locked, key_id, story_locked, windowed)

func door_z(parent: Node3D, x: float, opening_z: float, width: float, door_id: String, display_name: String, open_degrees := 95.0, locked := false, key_id := "", story_locked := false, windowed := false) -> Node:
    return _door_leaf(parent, Vector3(x, 0, opening_z - width * 0.5), -PI * 0.5, width, door_id, display_name, open_degrees, locked, key_id, story_locked, windowed)

func double_door_x(parent: Node3D, center_x: float, z: float, total_width: float, door_id: String, display_name: String, windowed := true) -> Array:
    var leaf_w := total_width * 0.5
    var left: Node = _door_leaf(parent, Vector3(center_x - total_width * 0.5, 0, z), 0.0, leaf_w, door_id + "_L", display_name, 102.0, false, "", false, windowed)
    var right: Node = _door_leaf(parent, Vector3(center_x + total_width * 0.5, 0, z), PI, leaf_w, door_id + "_R", display_name, -102.0, false, "", false, windowed)
    left.call("link_with", right)
    right.call("link_with", left)
    return [left, right]

func _door_leaf(parent: Node3D, hinge_pos: Vector3, base_rotation: float, width: float, door_id: String, display_name: String, open_degrees: float, locked: bool, key_id: String, story_locked: bool, windowed: bool) -> Node:
    var door := AnimatableBody3D.new()
    door.name = door_id
    door.position = hinge_pos
    door.rotation.y = base_rotation
    door.set_script(load("res://scripts/door.gd"))
    parent.add_child(door)
    door.call("configure", width, DOOR_H, DOOR_T, mats.door, mats.glass, door_id, display_name, open_degrees, locked, key_id, story_locked, windowed)
    return door

func bed(parent: Node3D, pos: Vector3, name: String) -> void:
    solid_box(parent, pos + Vector3(0, 0.25, 0), Vector3(2.10, 0.16, 0.92), mats.metal, name + "_Frame")
    mesh_box(parent, pos + Vector3(0, 0.42, 0), Vector3(2.02, 0.20, 0.86), mats.mattress, name + "_Mattress")
    mesh_box(parent, pos + Vector3(-0.72, 0.58, 0), Vector3(0.48, 0.13, 0.66), mats.fabric, name + "_Pillow")
    for dx in [-0.82, 0.82]:
        for dz in [-0.32, 0.32]:
            mesh_box(parent, pos + Vector3(dx, 0.11, dz), Vector3(0.08, 0.34, 0.08), mats.metal, name + "_Leg")

func table(parent: Node3D, pos: Vector3, size := Vector2(1.5, 0.75), name := "Table") -> void:
    solid_box(parent, pos + Vector3(0, 0.76, 0), Vector3(size.x, 0.10, size.y), mats.wood, name + "_Top")
    for dx in [-size.x * 0.42, size.x * 0.42]:
        for dz in [-size.y * 0.38, size.y * 0.38]:
            mesh_box(parent, pos + Vector3(dx, 0.38, dz), Vector3(0.08, 0.72, 0.08), mats.metal, name + "_Leg")

func chair(parent: Node3D, pos: Vector3, rotation_y := 0.0, name := "Chair") -> void:
    var root := Node3D.new()
    root.name = name
    root.position = pos
    root.rotation.y = rotation_y
    parent.add_child(root)
    solid_box(root, Vector3(0, 0.46, 0), Vector3(0.48, 0.10, 0.48), mats.plastic, name + "_Seat")
    mesh_box(root, Vector3(0, 0.83, 0.20), Vector3(0.48, 0.62, 0.08), mats.plastic, name + "_Back")
    for dx in [-0.18, 0.18]:
        for dz in [-0.18, 0.18]:
            mesh_box(root, Vector3(dx, 0.22, dz), Vector3(0.05, 0.45, 0.05), mats.metal, name + "_Leg")

func bench(parent: Node3D, pos: Vector3, length := 2.4, name := "Bench") -> void:
    solid_box(parent, pos + Vector3(0, 0.48, 0), Vector3(length, 0.12, 0.54), mats.plastic, name + "_Seat")
    mesh_box(parent, pos + Vector3(0, 0.87, 0.21), Vector3(length, 0.66, 0.09), mats.plastic, name + "_Back")
    for x in [-length * 0.38, length * 0.38]:
        mesh_box(parent, pos + Vector3(x, 0.23, 0), Vector3(0.08, 0.46, 0.40), mats.metal, name + "_Leg")

func cabinet(parent: Node3D, pos: Vector3, size := Vector3(1.8, 2.0, 0.55), name := "Cabinet") -> void:
    solid_box(parent, pos + Vector3(0, size.y * 0.5, 0), size, mats.cabinet, name + "_Body")
    mesh_box(parent, pos + Vector3(-0.03, size.y * 0.52, -size.z * 0.51), Vector3(0.04, size.y * 0.90, 0.04), mats.metal, name + "_Split")
    mesh_box(parent, pos + Vector3(-0.10, size.y * 0.55, -size.z * 0.54), Vector3(0.05, 0.16, 0.05), mats.metal, name + "_HandleA")
    mesh_box(parent, pos + Vector3(0.10, size.y * 0.55, -size.z * 0.54), Vector3(0.05, 0.16, 0.05), mats.metal, name + "_HandleB")

func shelf(parent: Node3D, pos: Vector3, size := Vector3(2.4, 2.0, 0.55), name := "Shelf") -> void:
    collision_box(parent, pos + Vector3(0, size.y * 0.5, 0), size, name + "_Body")
    for y in [0.10, size.y * 0.34, size.y * 0.66, size.y - 0.08]:
        mesh_box(parent, pos + Vector3(0, y, 0), Vector3(size.x, 0.08, size.z), mats.metal, name + "_Tier")
    for x in [-size.x * 0.48, size.x * 0.48]:
        mesh_box(parent, pos + Vector3(x, size.y * 0.5, 0), Vector3(0.07, size.y, 0.07), mats.metal, name + "_Post")

func sink(parent: Node3D, pos: Vector3, name := "Sink") -> void:
    solid_box(parent, pos + Vector3(0, 0.82, 0), Vector3(0.95, 0.18, 0.55), mats.ceramic, name + "_Basin")
    mesh_box(parent, pos + Vector3(0.30, 1.08, 0.05), Vector3(0.06, 0.38, 0.06), mats.metal, name + "_TapStem")
    mesh_box(parent, pos + Vector3(0.18, 1.24, 0.05), Vector3(0.28, 0.06, 0.06), mats.metal, name + "_TapArm")

func medical_cart(parent: Node3D, pos: Vector3, name := "Cart") -> void:
    solid_box(parent, pos + Vector3(0, 0.72, 0), Vector3(0.78, 0.62, 0.48), mats.cabinet, name + "_Body")
    mesh_box(parent, pos + Vector3(0, 1.08, 0), Vector3(0.88, 0.08, 0.55), mats.metal, name + "_Top")
    for x in [-0.30, 0.30]:
        for z in [-0.17, 0.17]:
            mesh_box(parent, pos + Vector3(x, 0.28, z), Vector3(0.08, 0.22, 0.08), mats.metal, name + "_Wheel")

func reception_desk(parent: Node3D, pos: Vector3, length := 4.8, name := "Reception") -> void:
    solid_box(parent, pos + Vector3(0, 0.52, 0), Vector3(length, 1.04, 0.68), mats.cabinet, name + "_Base")
    mesh_box(parent, pos + Vector3(0, 1.10, -0.05), Vector3(length + 0.18, 0.12, 0.88), mats.wood, name + "_Counter")
    mesh_box(parent, pos + Vector3(0, 0.58, -0.36), Vector3(length * 0.70, 0.58, 0.05), mats.wall_accent, name + "_FrontPanel")

func ceiling_light(parent: Node3D, pos: Vector3, energy := 0.78, range := 5.8, name := "CeilingLight") -> void:
    mesh_box(parent, pos, Vector3(1.15, 0.08, 0.28), mats.light_panel, name + "_Panel")
    var light := OmniLight3D.new()
    light.name = name + "_Omni"
    light.position = pos + Vector3(0, -0.08, 0)
    light.light_color = Color(0.91, 0.95, 0.92)
    light.light_energy = energy
    light.omni_range = range
    light.shadow_enabled = false
    parent.add_child(light)
