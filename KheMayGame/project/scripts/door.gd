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

func configure(width: float, height: float, thickness: float, material: Material, glass_material: Material, p_id: String, p_name: String, p_open_degrees: float, p_locked: bool, p_key_id: String, p_story_locked: bool, windowed := false) -> void:
    door_id = p_id
    display_name = p_name
    locked = p_locked
    key_id = p_key_id
    story_locked = p_story_locked
    open_angle = deg_to_rad(p_open_degrees)
    closed_rotation_y = rotation.y
    collision_layer = 1
    collision_mask = 1
    sync_to_physics = true

    var leaf := MeshInstance3D.new()
    leaf.name = "Leaf"
    var leaf_mesh := BoxMesh.new()
    leaf_mesh.size = Vector3(width, height, thickness)
    leaf.mesh = leaf_mesh
    leaf.position = Vector3(width * 0.5, height * 0.5, 0)
    leaf.material_override = material
    add_child(leaf)

    var collision := CollisionShape3D.new()
    collision.name = "DoorCollision"
    var box := BoxShape3D.new()
    box.size = Vector3(width, height, thickness)
    collision.shape = box
    collision.position = leaf.position
    add_child(collision)

    var handle := MeshInstance3D.new()
    handle.name = "Handle"
    var handle_mesh := BoxMesh.new()
    handle_mesh.size = Vector3(0.16, 0.07, thickness + 0.08)
    handle.mesh = handle_mesh
    handle.position = Vector3(width * 0.82, min(1.05, height * 0.48), -0.015)
    handle.material_override = glass_material
    add_child(handle)

    if windowed:
        var pane := MeshInstance3D.new()
        pane.name = "Window"
        var pane_mesh := BoxMesh.new()
        pane_mesh.size = Vector3(width * 0.34, 0.48, thickness + 0.015)
        pane.mesh = pane_mesh
        pane.position = Vector3(width * 0.62, height * 0.66, 0)
        pane.material_override = glass_material
        add_child(pane)

func link_with(other: Node) -> void:
    linked_door = other

func get_interaction_text(player: Node) -> String:
    if story_locked:
        return "E  •  %s [khóa]" % display_name
    if locked:
        if key_id != "" and player.has_method("has_item") and player.has_item(key_id):
            return "E  •  Mở khóa %s" % display_name
        return "E  •  %s [khóa]" % display_name
    return "E  •  %s %s" % ["Đóng" if is_open else "Mở", display_name]

func interact(player: Node) -> void:
    if story_locked:
        _notify(player, "Cửa đang bị khóa từ phía bên kia.")
        return
    if locked:
        if key_id == "" or not player.has_method("has_item") or not player.has_item(key_id):
            _notify(player, "Cần chìa khóa phù hợp.")
            return
        locked = false
        _notify(player, "Đã mở khóa %s." % display_name)
    var next_state := not is_open
    set_open(next_state)
    if is_instance_valid(linked_door) and linked_door.has_method("set_open"):
        linked_door.set_open(next_state)

func set_open(value: bool, instant := false) -> void:
    if is_open == value and not instant:
        return
    is_open = value
    var target := closed_rotation_y + (open_angle if is_open else 0.0)
    if _tween and _tween.is_valid():
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
        player.notify(text)
