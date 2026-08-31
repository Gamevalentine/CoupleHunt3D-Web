class_name KheMayFirstCase
extends Node

signal objective_changed(text: String)
signal message_requested(text: String)
signal case_completed

const BANDAGE_ID := "clean_bandage"

var state := 0
var player: Node
var floor1: Node3D
var patient: Node
var bandage_pickup: Node

func setup(p_floor1: Node3D, p_player: Node) -> void:
    floor1 = p_floor1
    player = p_player
    _spawn_patient()
    _spawn_bandage()
    _set_objective("Tới Phòng khám và tiếp nhận anh Thành.")

func get_state() -> int:
    return state

func can_take_bandage() -> bool:
    return state == 2

func patient_interact(p_player: Node) -> void:
    match state:
        0:
            state = 1
            _message("Thành: Tôi bị tấm tôn cứa vào cẳng tay, máu vẫn còn rỉ.")
            _set_objective("Khám vết thương ở cẳng tay của Thành.")
        1:
            state = 2
            _message("Khám: vết rách nông ở cẳng tay, chảy máu ít. Cần băng sạch.")
            _set_objective("Tới Kho thuốc lấy băng sạch.")
        2:
            _message("Bạn cần lấy băng sạch trong Kho thuốc.")
        3:
            if not p_player.has_method("has_item") or not bool(p_player.call("has_item", BANDAGE_ID)):
                _message("Bạn chưa có băng sạch.")
                return
            if p_player.has_method("consume_item"):
                p_player.call("consume_item", BANDAGE_ID)
            state = 4
            if is_instance_valid(patient) and patient.has_method("set_treated"):
                patient.call("set_treated")
            _message("Đã băng vết thương. Thành ổn định và không còn chảy máu.")
            _set_objective("Ca đầu tiên hoàn thành.")
            case_completed.emit()
        4:
            _message("Thành: Cảm ơn nhé, giờ tôi thấy ổn hơn nhiều rồi.")

func bandage_taken(p_player: Node) -> bool:
    if state != 2:
        return false
    if p_player.has_method("add_item"):
        p_player.call("add_item", BANDAGE_ID)
    state = 3
    _message("Đã lấy băng sạch.")
    _set_objective("Quay lại Phòng khám và băng vết thương cho Thành.")
    return true

func _spawn_patient() -> void:
    patient = StaticBody3D.new()
    patient.name = "Patient_Thanh"
    patient.position = Vector3(-9.55, 0.0, 11.45)
    patient.rotation.y = -PI * 0.5
    patient.set_script(load("res://scripts/patient_thanh.gd"))
    floor1.add_child(patient)
    patient.call("configure", self)

func _spawn_bandage() -> void:
    bandage_pickup = StaticBody3D.new()
    bandage_pickup.name = "Pickup_CleanBandage"
    bandage_pickup.position = Vector3(-8.2, 0.90, -8.1)
    bandage_pickup.set_script(load("res://scripts/item_pickup.gd"))
    floor1.add_child(bandage_pickup)
    bandage_pickup.call("configure", self, BANDAGE_ID, "băng sạch")

func _set_objective(text: String) -> void:
    objective_changed.emit(text)

func _message(text: String) -> void:
    message_requested.emit(text)
