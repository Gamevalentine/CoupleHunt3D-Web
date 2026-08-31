extends AnimatableBody3D

var door_id := ""
var display_name := "Cửa"
var locked := false
var key_id := ""
var story_locked := false
var is_open := false
var open_angle := deg_to_rad(95.0)
var closed_rotation_y := 0.0
var linked_door: Node = null
var _tween: Tween
var _frame_material: Material

func configure(width: float, height: float, thickness: float, material: Material, glass_material: Material, p_id: String, p_name: String, p_open_degrees: float, p_locked: bool, p_key_id: String, p_story_locked: bool, windowed := false) -> void:
    door_id = p_id
    display_name = p_name
    locked = p_locked
    key_id = p_key_id
    story_locked = p_story_locked
    open_angle = deg_to_rad(p_open_degrees)
    closed_rotation_y = rotation.y
    _frame_material = material
    collision_layer = 1
    collision_mask = 1
    sync_to_physics = true

    if windowed:
        _build_full_glass_leaf(width, height, thickness, glass_material)
    else:
        _build_solid_leaf(width, height, thickness, material)

    _build_collision(width, height, thickness)
    _build_handle(width, height, thickness, material)

func _build_solid_leaf(width: float, height: float, thickness: float, material: Material) -> void:
    var leaf := MeshInstance3D.new()
    leaf.name = "Leaf"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(width, height, thickness)
    leaf.mesh = mesh
    leaf.position = Vector3(width * 0.5, height * 0.5, 0)
    leaf.material_override = material
    add_child(leaf)

func _build_full_glass_leaf(width: float, height: float, thickness: float, glass_material: Material) -> void:
    var frame_t := 0.075
    var glass_margin := frame_t * 1.10

    var pane := MeshInstance3D.new()
    pane.name = "GlassPane"
    var pane_mesh := BoxMesh.new()
    pane_mesh.size = Vector3(max(0.10, width - glass_margin * 2.0), max(0.10, height - glass_margin * 2.0), thickness * 0.60)
    pane.mesh = pane_mesh
    pane.position = Vector3(width * 0.5, height * 0.5, 0)
    pane.material_override = glass_material
    add_child(pane)

    _add_frame_piece("FrameTop", Vector3(width * 0.5, height - frame_t * 0.5, 0), Vector3(width, frame_t, thickness + 0.035))
    _add_frame_piece("FrameBottom", Vector3(width * 0.5, frame_t * 0.5, 0), Vector3(width, frame_t, thickness + 0.035))
    _add_frame_piece("FrameHinge", Vector3(frame_t * 0.5, height * 0.5, 0), Vector3(frame_t, height, thickness + 0.035))
    _add_frame_piece("FrameOuter", Vector3(width - frame_t * 0.5, height * 0.5, 0), Vector3(frame_t, height, thickness + 0.035))
    _add_frame_piece("FrameMid", Vector3(width * 0.5, 1.02, 0), Vector3(width, 0.055, thickness + 0.035))

func _add_frame_piece(piece_name: String, pos: Vector3, size: Vector3) -> void:
    var piece := MeshInstance3D.new()
    piece.name = piece_name
    var mesh := BoxMesh.new()
    mesh.size = size
    piece.mesh = mesh
    piece.position = pos
    piece.material_override = _frame_material
    add_child(piece)

func _build_collision(width: float, height: float, thickness: float) -> void:
    var collision := CollisionShape3D.new()
    collision.name = "DoorCollision"
    var box := BoxShape3D.new()
    box.size = Vector3(width, height, thickness)
    collision.shape = box
    collision.position = Vector3(width * 0.5, height * 0.5, 0)
    add_child(collision)

func _build_handle(width: float, height: float, thickness: float, material: Material) -> void:
    var handle := MeshInstance3D.new()
    handle.name = "Handle"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.16, 0.07, thickness + 0.08)
    handle.mesh = mesh
    handle.position = Vector3(width * 0.82, min(1.05, height * 0.48), -0.015)
    handle.material_override = material
    add_child(handle)

func link_with(other: Node) -> void:
    linked_door = other

func get_interaction_text(player: Node) -> String:
    if story_locked:
        return "E  •  %s [khóa]" % display_name
    if locked:
        if key_id != "" and player.has_method("has_item") and bool(player.call("has_item", key_id)):
            return "E  •  Mở khóa %s" % display_name
        return "E  •  %s [khóa]" % display_name
    return "E  •  %s %s" % ["Đóng" if is_open else "Mở", display_name]

func interact(player: Node) -> void:
    if story_locked:
        _notify(player, "Cửa đang bị khóa từ phía bên kia.")
        return
    if locked:
        if key_id == "" or not player.has_method("has_item") or not bool(player.call("has_item", key_id)):
            _notify(player, "Cần chìa khóa phù hợp.")
            return
        locked = false
        _notify(player, "Đã mở khóa %s." % display_name)
    var next_state := not is_open
    set_open(next_state)
    if is_instance_valid(linked_door) and linked_door.has_method("set_open"):
        linked_door.call("set_open", next_state)

func set_open(value: bool, instant := false) -> void:
    if is_open == value and not instant:
        return
    is_open = value
    var target := closed_rotation_y + (open_angle if is_open else 0.0)
    if _tween:
        _tween.kill()
    if instant:
        rotation.y = target
        return
    _tween = create_tween()
    _tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    _tween.tween_property(self, "rotation:y", target, 0.42)

func set_story_locked(value: bool) -> void:
    story_locked = value

func force_unlock() -> void:
    locked = false
    story_locked = false

func _notify(player: Node, text: String) -> void:
    if player.has_method("notify"):
        player.call("notify", text)
