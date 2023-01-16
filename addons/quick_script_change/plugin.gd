@tool
extends EditorPlugin


const scene_input: PackedScene = preload("res://addons/quick_script_change/QuickChangePopup.tscn")

var popup: Popup
var text_edit: LineEdit
var scroll_container: Control

var last_time_shift_pressed: int
var shift_was_pressed: bool = false

var editor_interface := get_editor_interface()
var script_editor := editor_interface.get_script_editor()


func _enter_tree() -> void:
	popup = scene_input.instantiate()
	text_edit = popup.get_child(0).get_child(1) as LineEdit
	scroll_container = popup.get_child(0).get_child(2).get_child(0) as Control

	text_edit.text_changed.connect(_on_change_text)
	text_edit.text_submitted.connect(_on_text_setted)

	get_editor_interface().get_base_control().add_child(popup)
	popup.hide()



func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_SHIFT and key_event.is_pressed():
			if shift_was_pressed and (Time.get_ticks_msec() - last_time_shift_pressed) < 200:
				shift_was_pressed = false
				show_popup()
			else:
				shift_was_pressed = true
				last_time_shift_pressed = Time.get_ticks_msec()


func show_popup():
	popup.show()
	text_edit.grab_focus()





func _exit_tree() -> void:
	popup.hide()
	popup.queue_free()


func get_filelist(scan_dir : String, filter_exts : Array = []) -> Array[String]:
	var my_files : Array[String] = []
	var dir := DirAccess.open(scan_dir)
	if not dir:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin() != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name, filter_exts)
		else:
			if filter_exts.size() == 0:
				my_files.append(dir.get_current_dir() + "/" + file_name)
			else:
				for ext in filter_exts:
					if file_name.get_extension() == ext:
						my_files.append(dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()
	return my_files


func _on_change_text(txt):
	if popup == null or not popup.visible:
		return

	for child in scroll_container.get_children():
		child.queue_free()

	var text := text_edit.text
	if text == "":
		return


	var all_paths := get_filelist("res://", ["gd"])
	var filtered = []
	for path in all_paths:
		if path.contains(text):
			var btn = Button.new()
			scroll_container.add_child(btn)
			btn.text = path
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(func(): on_click_btn(path))



func _on_text_setted(txt):
	text_edit.release_focus()
	scroll_container.grab_focus()


func on_click_btn(path):
	editor_interface.set_main_screen_editor("Script")
	var load_script := load(path)
	if load_script != null:
		editor_interface.edit_script(load_script)
		popup.hide()

