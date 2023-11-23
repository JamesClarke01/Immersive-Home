extends Object

var label: Label3D

var text: String = ""
var width: float = 0.2
var gap_offsets = null
var overflow_index: int = -1
var char_offset: int = 0
var caret_position: int = 3:
	set(value):
		caret_position = clampi(value, 0, text.length())

func set_width(value: float):
	width = value

func set_text(value: String, insert: bool = false):
	var old_text = text
	text = value

	if label == null:
		return

	gap_offsets = _calculate_text_gaps()
	if insert == false:
		caret_position += text.length() - old_text.length()
	else:
		caret_position = 0

	overflow_index = _calculate_overflow_index()
	focus_caret()

func get_display_text():
	# In case all chars fit, return the whole text.
	if overflow_index == -1:
		return text.substr(char_offset)
	return text.substr(char_offset, overflow_index - char_offset)

func focus_caret():
	if overflow_index == -1:
		char_offset = 0
		return

	while caret_position > overflow_index:
		char_offset += caret_position - overflow_index
		overflow_index = _calculate_overflow_index()

	while caret_position < char_offset:
		char_offset = caret_position#
		overflow_index = _calculate_overflow_index()

func get_caret_position():
	return gap_offsets[caret_position] - gap_offsets[char_offset]

func update_caret_position(click_pos_x: float):
	caret_position = _calculate_caret_position(click_pos_x)
	print("caret_position: ", caret_position)

func _calculate_caret_position(click_pos_x: float):
	for i in range(1, gap_offsets.size()):
		var left = gap_offsets[i] - gap_offsets[char_offset]
		
		if click_pos_x < left:
			return  i - 1

	return gap_offsets.size() - 1

func _calculate_text_gaps():
	var font = label.get_font()
	var offsets = [0.0]
	var offset = 0.0

	for i in range(text.length()):
		var character = text[i]
		var size = font.get_string_size(character, HORIZONTAL_ALIGNMENT_CENTER, -1, label.font_size)

		offset += size.x * label.pixel_size
		offsets.append(offset)

	return offsets

## Returns the index of the last character that fits in the width.
## If all characters fit, returns -1.
func _calculate_overflow_index():
	
	for i in range(char_offset, gap_offsets.size()):
		if gap_offsets[i] - gap_offsets[char_offset] >= width:
			return i - 1
	return -1
