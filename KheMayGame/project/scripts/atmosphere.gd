class_name KheMayAtmosphere
extends Node

var fluorescent_lights: Array[OmniLight3D] = []
var fluorescent_panels: Array[MeshInstance3D] = []
var base_energy: Dictionary = {}
var emergency_lights: Array[OmniLight3D] = []
var moon: DirectionalLight3D
var station_power := true
var busy := false
var next_flicker_ms := 0
var next_brownout_ms := 0

func setup(root: Node, moon_light: DirectionalLight3D) -> void:
    moon = moon_light
    refresh_fluorescent_sources(root)
    _create_emergency_light(Vector3(2.8, 2.45, -6.0), 6.0)
    _create_emergency_light(Vector3(15.7, 2.35, -8.5), 5.5)
    _create_emergency_light(Vector3(-6.2, 2.35, -24.0), 5.2)
    _create_emergency_light(Vector3(0.0, 6.05, -5.5), 5.2)
    var now := Time.get_ticks_msec()
    next_flicker_ms = now + randi_range(8000, 15000)
    next_brownout_ms = now + randi_range(45000, 70000)
    set_process(true)

func refresh_fluorescent_sources(root: Node) -> void:
    fluorescent_lights.clear()
    fluorescent_panels.clear()
    base_energy.clear()
    _collect(root)
    for light in fluorescent_lights:
        base_energy[light] = light.light_energy
        light.light_color = Color(0.89 + randf_range(-0.015, 0.015), 0.95 + randf_range(-0.015, 0.01), 0.91 + randf_range(-0.015, 0.015))

func _process(_delta: float) -> void:
    if not station_power or busy:
        return
    var now := Time.get_ticks_msec()
    if now >= next_brownout_ms:
        _brownout()
        next_brownout_ms = now + randi_range(52000, 85000)
    elif now >= next_flicker_ms:
        _flicker_one()
        next_flicker_ms = now + randi_range(9000, 18000)

func set_station_power(enabled: bool) -> void:
    station_power = enabled
    if not enabled:
        for light in fluorescent_lights:
            light.light_energy = 0.0
        for panel in fluorescent_panels:
            panel.visible = false
        _set_emergency(0.58)
    else:
        _restore_fluorescents()
        _set_emergency(0.0)

func _flicker_one() -> void:
    if fluorescent_lights.is_empty():
        return
    busy = true
    var light := fluorescent_lights[randi() % fluorescent_lights.size()]
    var original := float(base_energy.get(light, light.light_energy))
    var blinks := randi_range(1, 2)
    for i in range(blinks):
        # Horror nhẹ: đèn chớp nhưng hành lang vẫn đọc được không gian.
        light.light_energy = original * randf_range(0.58, 0.72)
        await get_tree().create_timer(randf_range(0.035, 0.070)).timeout
        light.light_energy = original * randf_range(0.94, 1.0)
        if i < blinks - 1:
            await get_tree().create_timer(randf_range(0.045, 0.09)).timeout
    light.light_energy = original
    busy = false

func _brownout() -> void:
    busy = true
    # Sụt điện chỉ tối vừa phải. Tắt điện thật mới đưa đèn về 0.
    for light in fluorescent_lights:
        light.light_energy = float(base_energy.get(light, 1.0)) * 0.38
    _set_emergency(0.24)
    await get_tree().create_timer(randf_range(0.10, 0.16)).timeout
    _restore_fluorescents()
    _set_emergency(0.0)
    await get_tree().create_timer(randf_range(0.07, 0.11)).timeout
    if randf() < 0.40:
        for light in fluorescent_lights:
            light.light_energy = float(base_energy.get(light, 1.0)) * 0.52
        _set_emergency(0.16)
        await get_tree().create_timer(randf_range(0.045, 0.08)).timeout
        _restore_fluorescents()
        _set_emergency(0.0)
    busy = false

func _restore_fluorescents() -> void:
    if not station_power:
        return
    for light in fluorescent_lights:
        light.light_energy = float(base_energy.get(light, 1.0))
    for panel in fluorescent_panels:
        panel.visible = true

func _set_emergency(energy: float) -> void:
    for light in emergency_lights:
        light.light_energy = energy

func _create_emergency_light(pos: Vector3, range_value: float) -> void:
    var light := OmniLight3D.new()
    light.name = "EmergencyRed"
    light.position = pos
    light.light_color = Color(0.78, 0.045, 0.025)
    light.light_energy = 0.0
    light.omni_range = range_value
    light.shadow_enabled = false
    get_parent().add_child(light)
    emergency_lights.append(light)

func _collect(node: Node) -> void:
    for child in node.get_children():
        var node_name := str(child.name)
        if child is OmniLight3D and node_name.contains("_Omni"):
            fluorescent_lights.append(child as OmniLight3D)
        elif child is MeshInstance3D and node_name.contains("_Panel"):
            fluorescent_panels.append(child as MeshInstance3D)
        _collect(child)
