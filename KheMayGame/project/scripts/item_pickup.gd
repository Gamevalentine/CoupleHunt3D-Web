extends StaticBody3D

var case_manager: Node
var item_id := ""
var display_name := "vật phẩm"

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    _build_visual()
    _build_collision()

func configure(manager: Node, p_item_id: String, p_display_name: String) -> void:
    case_manager = manager
    item_id = p_item_id
    display_name = p_display_name

func get_interaction_text(_player: Node) -> String:
    if not is_instance_valid(case_manager):
        return ""
    if case_manager.has_method("can_take_bandage") and bool(case_manager.call("can_take_bandage")):
        return "E  •  Lấy %s" % display_name
    return ""

func interact(player: Node) -> void:
    if not is_instance_valid(case_manager):
        return
    if case_manager.has_method("bandage_taken") and bool(case_manager.call("bandage_taken", player)):
        queue_free()

func _build_visual() -> void:
    var pack := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.34, 0.12, 0.26)
    pack.mesh = mesh
    pack.position.y = 0.06
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.84, 0.84, 0.80)
    mat.roughness = 0.85
    pack.material_override = mat
    add_child(pack)

    var stripe := MeshInstance3D.new()
    var stripe_mesh := BoxMesh.new()
    stripe_mesh.size = Vector3(0.08, 0.125, 0.27)
    stripe.mesh = stripe_mesh
    stripe.position = Vector3(0, 0.061, 0)
    var stripe_mat := StandardMaterial3D.new()
    stripe_mat.albedo_color = Color(0.20, 0.43, 0.36)
    stripe_mat.roughness = 0.78
    stripe.material_override = stripe_mat
    add_child(stripe)

func _build_collision() -> void:
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(0.40, 0.18, 0.32)
    shape.shape = box
    shape.position.y = 0.09
    add_child(shape)
