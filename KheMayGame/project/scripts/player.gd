extends CharacterBody3D

signal interaction_prompt_changed(text: String)
signal status_message_requested(text: String)

const WALK_SPEED := 4.2
const RUN_SPEED := 5.8
const MOUSE_SENS := 0.0022
const GRAVITY := 18.0

@onready var head: Node3D = $Head
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay

var look_held := false
var inventory: Dictionary = {}
var _last_prompt := ""

func _ready() -> void:
    motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
    max_slides = 8
    floor_stop_on_slope = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        look_held = event.pressed
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if look_held else Input.MOUSE_MODE_VISIBLE
        get_viewport().set_input_as_handled()
        return
    if event is InputEventMouseMotion and look_held:
        rotate_y(-event.relative.x * MOUSE_SENS)
        head.rotation.x = clamp(head.rotation.x - event.relative.y * MOUSE_SENS, deg_to_rad(-85.0), deg_to_rad(85.0))
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
        target.interact(self)
        _update_interaction_prompt(true)

func _update_interaction_prompt(force := false) -> void:
    var text := ""
    var target := _target()
    if target and target.has_method("get_interaction_text"):
        text = target.get_interaction_text(self)
    if force or text != _last_prompt:
        _last_prompt = text
        interaction_prompt_changed.emit(text)
