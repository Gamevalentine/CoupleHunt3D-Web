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

func wall_z(parent: Node3D, x: float, z: float, length: float, material: Material, name := "WallZ") -> void:
    solid_box(parent, Vector3(x, WALL_H * 0.5, z), Vector3(WALL_T, WALL_H, length), material, name)

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
    var door = AnimatableBody3D.new()
    door.name = door_id
    door.position = hinge_pos
    door.rotation.y = base_rotation
    door.set_script(load("res://scripts/door.gd"))
    parent.add_child(door)
    door.call("configure", width, DOOR_H, DOOR_T, mats.door, mats.glass, door_id, display_name, open_degrees, locked, key_id, story_locked, windowed)
    return door

func bed(parent: Node3D, pos: Vector3, name: String) -> void:
    solid_box(parent, pos, Vector3(2.1, 0.38, 0.9), mats.room, name)
    solid_box(parent, pos + Vector3(-0.76, 0.27, 0), Vector3(0.44, 0.14, 0.70), mats.wall, name + "_Pillow")
