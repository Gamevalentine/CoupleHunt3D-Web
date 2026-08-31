extends CharacterBody3D

signal interaction_prompt_changed(text: String)
signal status_message_requested(text: String)

const WALK_SPEED := 4.2
const RUN_SPEED := 5.8
const MOUSE_SENS := 0.0022
const GRAVITY := 18.0
const CAMERA_DISTANCE := 3.2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay

var look_held := false
var inventory: Dictionary = {}
var _last_prompt := ""

func _ready() -> void:
    motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
    up_direction = Vector3.UP
    max_slides = 8
    floor_stop_on_slope = true
    floor_snap_length = 0.50
    floor_max_angle = deg_to_rad(46.0)
    safe_margin = 0.08
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _setup_third_person_camera()
    _build_placeholder_body()

func _setup_third_person_camera() -> void:
    # Reuse the existing camera/raycast, but put them behind a SpringArm3D.
    # The spring arm retracts automatically against ceilings and walls, so the
    # camera can no longer be trapped inside the stair structure.
    head.remove_child(camera)

    var spring := SpringArm3D.new()
    spring.name = "CameraSpring"
    spring.spring_length = CAMERA_DISTANCE
    spring.margin = 0.24
    spring.collision_mask = 1
    spring.position.x = 0.38
    spring.add_excluded_object(get_rid())
    head.add_child(spring)

    spring.add_child(camera)
    camera.position = Vector3.ZERO
    camera.rotation = Vector3.ZERO
    camera.fov = 68.0
    camera.current = true

    interaction_ray.target_position = Vector3(0, 0, -3.4)
    interaction_ray.enabled = true

func _build_placeholder_body() -> void:
    var body := Node3D.new()
    body.name = "VisualBody"
    add_child(body)

    var scrub_mat := StandardMaterial3D.new()
    scrub_mat.albedo_color = Color(0.12, 0.25, 0.25)
    scrub_mat.roughness = 0.92

    var skin_mat := StandardMaterial3D.new()
    skin_mat.albedo_color = Color(0.62, 0.48, 0.39)
    skin_mat.roughness = 0.94

    var shoe_mat := StandardMaterial3D.new()
    shoe_mat.albedo_color = Color(0.07, 0.08, 0.08)
    shoe_mat.roughness = 0.96

    _body_box(body, "Torso", Vector3(0, 1.18, 0), Vector3(0.56, 0.72, 0.30), scrub_mat)
    _body_box(body, "ArmL", Vector3(-0.38, 1.14, 0), Vector3(0.15, 0.66, 0.17), scrub_mat)
    _body_box(body, "ArmR", Vector3(0.38, 1.14, 0), Vector3(0.15, 0.66, 0.17), scrub_mat)
    _body_box(body, "LegL", Vector3(-0.16, 0.47, 0), Vector3(0.21, 0.72, 0.23), scrub_mat)
    _body_box(body, "LegR", Vector3(0.16, 0.47, 0), Vector3(0.21, 0.72, 0.23), scrub_mat)
    _body_box(body, "ShoeL", Vector3(-0.16, 0.10, -0.05), Vector3(0.23, 0.14, 0.38), shoe_mat)
    _body_box(body, "ShoeR", Vector3(0.16, 0.10, -0.05), Vector3(0.23, 0.14, 0.38), shoe_mat)

    var head_mesh := MeshInstance3D.new()
    head_mesh.name = "CharacterHead"
    var sphere := SphereMesh.new()
    sphere.radius = 0.20
    sphere.height = 0.40
    head_mesh.mesh = sphere
    head_mesh.position = Vector3(0, 1.68, 0)
    head_mesh.material_override = skin_mat
    body.add_child(head_mesh)

func _body_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        look_held = event.pressed
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if look_held else Input.MOUSE_MODE_VISIBLE
        get_viewport().set_input_as_handled()
        return

    if event is InputEventMouseMotion and look_held:
        rotate_y(-event.relative.x * MOUSE_SENS)
        head.rotation.x = clamp(
            head.rotation.x - event.relative.y * MOUSE_SENS,
            deg_to_rad(-55.0),
            deg_to_rad(55.0)
        )
        return

    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            look_held = false
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            return
        if event.keycode == KEY_E:
            _interact()
            return

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    else:
        velocity.y = 0.0

    var input := Vector2.ZERO
    if Input.is_key_pressed(KEY_A): input.x -= 1.0
    if Input.is_key_pressed(KEY_D): input.x += 1.0
    if Input.is_key_pressed(KEY_W): input.y -= 1.0
    if Input.is_key_pressed(KEY_S): input.y += 1.0
    input = input.normalized()

    var dir := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
    var speed := RUN_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    move_and_slide()
    _update_interaction_prompt()

func has_item(item_id: String) -> bool:
    return inventory.has(item_id)

func add_item(item_id: String) -> void:
    inventory[item_id] = true

func consume_item(item_id: String) -> bool:
    if not inventory.has(item_id):
        return false
    inventory.erase(item_id)
    return true

func notify(text: String) -> void:
    status_message_requested.emit(text)

func _target() -> Object:
    if not interaction_ray.is_colliding():
        return null
    return interaction_ray.get_collider()

func _interact() -> void:
    interaction_ray.force_raycast_update()
    var target := _target()
    if target and target.has_method("interact"):
        target.call("interact", self)
        _update_interaction_prompt(true)

func _update_interaction_prompt(force := false) -> void:
    var text := ""
    var target := _target()
    if target and target.has_method("get_interaction_text"):
        text = str(target.call("get_interaction_text", self))
    if force or text != _last_prompt:
        _last_prompt = text
        interaction_prompt_changed.emit(text)
