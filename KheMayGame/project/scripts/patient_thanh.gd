extends StaticBody3D

var case_manager: Node
var bandage_visual: MeshInstance3D

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    _build_collision()
    _build_visual()

func configure(manager: Node) -> void:
    case_manager = manager

func get_interaction_text(_player: Node) -> String:
    if not is_instance_valid(case_manager):
        return ""
    var state := int(case_manager.call("get_state"))
    match state:
        0:
            return "E  •  Nói chuyện với Thành"
        1:
            return "E  •  Khám vết thương"
        2:
            return "E  •  Nói chuyện với Thành"
        3:
            return "E  •  Băng vết thương cho Thành"
        4:
            return "E  •  Nói chuyện với Thành"
    return ""

func interact(player: Node) -> void:
    if is_instance_valid(case_manager) and case_manager.has_method("patient_interact"):
        case_manager.call("patient_interact", player)

func set_treated() -> void:
    if is_instance_valid(bandage_visual):
        bandage_visual.visible = true

func _build_collision() -> void:
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.34
    capsule.height = 1.72
    shape.shape = capsule
    shape.position.y = 0.86
    add_child(shape)

func _build_visual() -> void:
    var skin := _material(Color(0.48, 0.34, 0.27))
    var shirt := _material(Color(0.16, 0.29, 0.31))
    var pants := _material(Color(0.13, 0.15, 0.16))
    var shoes := _material(Color(0.07, 0.07, 0.07))
    var bandage := _material(Color(0.82, 0.82, 0.76))

    _box(Vector3(0, 1.12, 0), Vector3(0.62, 0.78, 0.34), shirt, "Torso")
    _sphere(Vector3(0, 1.74, 0), 0.23, skin, "Head")
    _box(Vector3(-0.39, 1.11, 0), Vector3(0.18, 0.72, 0.18), skin, "LeftArm")
    _box(Vector3(0.39, 1.11, 0), Vector3(0.18, 0.72, 0.18), skin, "RightArm")
    _box(Vector3(-0.18, 0.44, 0), Vector3(0.23, 0.80, 0.25), pants, "LeftLeg")
    _box(Vector3(0.18, 0.44, 0), Vector3(0.23, 0.80, 0.25), pants, "RightLeg")
    _box(Vector3(-0.18, 0.08, -0.05), Vector3(0.25, 0.13, 0.40), shoes, "LeftShoe")
    _box(Vector3(0.18, 0.08, -0.05), Vector3(0.25, 0.13, 0.40), shoes, "RightShoe")

    bandage_visual = _box(Vector3(-0.39, 1.06, 0), Vector3(0.215, 0.19, 0.215), bandage, "ArmBandage")
    bandage_visual.visible = false

func _material(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.92
    return m

func _box(pos: Vector3, size: Vector3, material: Material, name: String) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = material
    add_child(node)
    return node

func _sphere(pos: Vector3, radius: float, material: Material, name: String) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    node.mesh = mesh
    node.position = pos
    node.material_override = material
    add_child(node)
    return node
