extends Node3D

const F2_Y := 3.75
var mats: Dictionary = {}

func _ready() -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    _make_materials()
    var kit := KheMayBuildKit.new(mats)
    _build_station(kit)
    _build_player()
    _build_lighting()
    _build_ui()

func _material(color: Color, transparent := false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.88
    if transparent:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m

func _make_materials() -> void:
    mats.floor = _material(Color(0.25, 0.27, 0.28))
    mats.wall = _material(Color(0.58, 0.61, 0.59))
    mats.room = _material(Color(0.43, 0.50, 0.47))
    mats.utility = _material(Color(0.31, 0.35, 0.33))
    mats.secret = _material(Color(0.30, 0.08, 0.07))
    mats.secret_wall = _material(Color(0.23, 0.24, 0.23))
    mats.outdoor = _material(Color(0.14, 0.18, 0.14))
    mats.fake_wall = _material(Color(0.53, 0.54, 0.51))
    mats.glass = _material(Color(0.18, 0.25, 0.27, 0.34), true)

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
    cam.current = true
    cam.fov = 70.0
    head.add_child(cam)
    add_child(player)

func _build_lighting() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.016, 0.022, 0.028)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.25, 0.29, 0.32)
    e.ambient_light_energy = 0.48
    env.environment = e
    add_child(env)
    var moon := DirectionalLight3D.new()
    moon.rotation_degrees = Vector3(-50, -25, 0)
    moon.light_energy = 0.34
    moon.shadow_enabled = true
    add_child(moon)
    for p in [Vector3(0,2.75,14),Vector3(0,2.75,8),Vector3(-13,2.75,11),Vector3(-13,2.75,1),Vector3(9,2.75,13),Vector3(9,2.75,6),Vector3(9,2.75,0),Vector3(9,2.75,-6),Vector3(9,2.75,-13),Vector3(-8,2.7,-24)]:
        var light := OmniLight3D.new()
        light.position = p
        light.omni_range = 7.0
        light.light_energy = 0.92
        light.shadow_enabled = true
        add_child(light)
    var red := OmniLight3D.new()
    red.position = Vector3(17.3, 2.4, -9)
    red.light_color = Color(0.74, 0.07, 0.045)
    red.light_energy = 1.15
    red.omni_range = 8.0
    red.shadow_enabled = true
    add_child(red)

func _build_ui() -> void:
    var ui := CanvasLayer.new()
    var hint := Label.new()
    hint.text = "WASD di chuyển  •  Shift chạy  •  Giữ chuột trái để nhìn  •  Esc thả chuột"
    hint.position = Vector2(14, 12)
    hint.add_theme_font_size_override("font_size", 14)
    hint.modulate = Color(0.88, 0.90, 0.88, 0.82)
    ui.add_child(hint)
    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-5, -10)
    crosshair.add_theme_font_size_override("font_size", 18)
    crosshair.modulate = Color(0.88, 0.90, 0.88, 0.65)
    ui.add_child(crosshair)
    add_child(ui)
