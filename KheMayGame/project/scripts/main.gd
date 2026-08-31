extends Node3D

const F2_Y := 3.75
var mats: Dictionary = {}
var interaction_label: Label
var status_label: Label
var status_timer: Timer

func _ready() -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    _make_materials()
    var kit := KheMayBuildKit.new(mats)
    _build_station(kit)
    _build_lighting()
    _build_ui()
    _build_player()

func _material(color: Color, roughness := 0.85, metallic := 0.0, transparent := false, emission := Color(0, 0, 0, 1)) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    if transparent:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    if emission.r + emission.g + emission.b > 0.01:
        m.emission_enabled = true
        m.emission = emission
        m.emission_energy_multiplier = 1.35
    return m

func _tile_material(base_color: Color, grout_color: Color, count := 26.0) -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = """
shader_type spatial;
uniform vec4 base_color : source_color;
uniform vec4 grout_color : source_color;
uniform float tile_count = 26.0;
void fragment() {
    vec2 p = fract(UV * tile_count);
    vec2 edge = min(p, vec2(1.0) - p);
    float grout = 1.0 - smoothstep(0.018, 0.045, min(edge.x, edge.y));
    ALBEDO = mix(base_color.rgb, grout_color.rgb, grout);
    ROUGHNESS = 0.80;
}
"""
    var m := ShaderMaterial.new()
    m.shader = shader
    m.set_shader_parameter("base_color", base_color)
    m.set_shader_parameter("grout_color", grout_color)
    m.set_shader_parameter("tile_count", count)
    return m

func _make_materials() -> void:
    mats.floor = _tile_material(Color(0.40, 0.43, 0.41), Color(0.19, 0.21, 0.20), 30.0)
    mats.wall = _material(Color(0.73, 0.75, 0.70), 0.92)
    mats.wall_accent = _material(Color(0.27, 0.42, 0.36), 0.88)
    mats.baseboard = _material(Color(0.18, 0.29, 0.26), 0.82)
    mats.ceiling = _material(Color(0.82, 0.83, 0.78), 0.96)
    mats.room = _material(Color(0.50, 0.55, 0.52), 0.88)
    mats.utility = _material(Color(0.29, 0.33, 0.31), 0.92)
    mats.secret = _material(Color(0.24, 0.075, 0.06), 0.92)
    mats.secret_wall = _material(Color(0.22, 0.23, 0.21), 0.95)
    mats.outdoor = _material(Color(0.11, 0.15, 0.11), 0.98)
    mats.fake_wall = _material(Color(0.66, 0.67, 0.62), 0.96)
    mats.glass = _material(Color(0.20, 0.31, 0.32, 0.30), 0.18, 0.05, true)
    mats.window_frame = _material(Color(0.22, 0.25, 0.24), 0.50, 0.65)
    mats.door = _material(Color(0.30, 0.22, 0.15), 0.76)
    mats.metal = _material(Color(0.39, 0.42, 0.41), 0.38, 0.72)
    mats.mattress = _material(Color(0.68, 0.72, 0.69), 0.96)
    mats.fabric = _material(Color(0.79, 0.79, 0.71), 1.0)
    mats.wood = _material(Color(0.37, 0.27, 0.18), 0.76)
    mats.plastic = _material(Color(0.24, 0.41, 0.37), 0.72)
    mats.cabinet = _material(Color(0.37, 0.44, 0.41), 0.70, 0.12)
    mats.ceramic = _material(Color(0.84, 0.85, 0.80), 0.30)
    mats.light_panel = _material(Color(0.85, 0.88, 0.82), 0.30, 0.0, false, Color(0.78, 0.88, 0.80))

func _build_station(k: KheMayBuildKit) -> void:
    var world := Node3D.new()
    world.name = "KheMayStation"
    add_child(world)
    k.floor(world, Vector3(0, 0, -2), Vector2(72, 72), mats.outdoor, "Terrain")

    var floor1 := Node3D.new()
    floor1.name = "Floor1"
    world.add_child(floor1)
    KheMayFloor1Builder.build(floor1, k)

    var floor2 := Node3D.new()
    floor2.name = "Floor2"
    floor2.position.y = F2_Y
    world.add_child(floor2)
    KheMayFloor2Builder.build(floor2, k)

    var rear := Node3D.new()
    rear.name = "RearUtility"
    world.add_child(rear)
    KheMayRearHiddenBuilder.build_rear(rear, k)

    var hidden := Node3D.new()
    hidden.name = "HiddenCorridorAndRoom06"
    world.add_child(hidden)
    KheMayRearHiddenBuilder.build_hidden(hidden, k)

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 0.10, 27)
    player.collision_layer = 1
    player.collision_mask = 1
    player.floor_snap_length = 0.45
    player.safe_margin = 0.08
    player.set_script(load("res://scripts/player.gd"))

    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.40
    capsule.height = 1.80
    collider.shape = capsule
    collider.position.y = 0.92
    player.add_child(collider)

    var head := Node3D.new()
    head.name = "Head"
    head.position.y = 1.66
    player.add_child(head)

    var cam := Camera3D.new()
    cam.name = "Camera3D"
    cam.current = true
    cam.fov = 70.0
    head.add_child(cam)

    var ray := RayCast3D.new()
    ray.name = "InteractionRay"
    ray.target_position = Vector3(0, 0, -2.8)
    ray.collision_mask = 1
    ray.collide_with_bodies = true
    ray.enabled = true
    cam.add_child(ray)

    add_child(player)
    player.connect("interaction_prompt_changed", Callable(self, "_on_interaction_prompt_changed"))
    player.connect("status_message_requested", Callable(self, "_on_status_message_requested"))

func _build_lighting() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.012, 0.018, 0.024)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.20, 0.24, 0.25)
    e.ambient_light_energy = 0.34
    env.environment = e
    add_child(env)

    var moon := DirectionalLight3D.new()
    moon.rotation_degrees = Vector3(-50, -25, 0)
    moon.light_color = Color(0.52, 0.62, 0.70)
    moon.light_energy = 0.28
    moon.shadow_enabled = true
    add_child(moon)

    var entrance := OmniLight3D.new()
    entrance.position = Vector3(0, 2.8, 21)
    entrance.light_color = Color(0.78, 0.84, 0.76)
    entrance.light_energy = 0.72
    entrance.omni_range = 7.0
    entrance.shadow_enabled = false
    add_child(entrance)

    var red := OmniLight3D.new()
    red.position = Vector3(17.3, 2.4, -9)
    red.light_color = Color(0.65, 0.055, 0.035)
    red.light_energy = 0.55
    red.omni_range = 6.0
    red.shadow_enabled = false
    add_child(red)

func _build_ui() -> void:
    var ui := CanvasLayer.new()
    var hint := Label.new()
    hint.text = "WASD di chuyển  •  Shift chạy  •  Giữ chuột trái để nhìn  •  E tương tác  •  Esc thả chuột"
    hint.position = Vector2(14, 12)
    hint.add_theme_font_size_override("font_size", 14)
    hint.modulate = Color(0.88, 0.90, 0.88, 0.78)
    ui.add_child(hint)

    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-5, -10)
    crosshair.add_theme_font_size_override("font_size", 18)
    crosshair.modulate = Color(0.88, 0.90, 0.88, 0.65)
    ui.add_child(crosshair)

    interaction_label = Label.new()
    interaction_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    interaction_label.position = Vector2(-145, -92)
    interaction_label.size = Vector2(290, 34)
    interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_label.add_theme_font_size_override("font_size", 17)
    interaction_label.visible = false
    ui.add_child(interaction_label)

    status_label = Label.new()
    status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    status_label.position = Vector2(-200, -140)
    status_label.size = Vector2(400, 34)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 16)
    status_label.visible = false
    ui.add_child(status_label)

    status_timer = Timer.new()
    status_timer.one_shot = true
    status_timer.wait_time = 2.2
    status_timer.timeout.connect(_hide_status)
    ui.add_child(status_timer)
    add_child(ui)

func _on_interaction_prompt_changed(text: String) -> void:
    interaction_label.text = text
    interaction_label.visible = not text.is_empty()

func _on_status_message_requested(text: String) -> void:
    status_label.text = text
    status_label.visible = true
    status_timer.start()

func _hide_status() -> void:
    status_label.visible = false
