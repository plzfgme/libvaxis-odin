package libvaxis

import "base:runtime"
import "core:c"
import "core:mem"
import "core:sync"

Error :: enum c.int {
	None          = 0,
	Invalid       = -1,
	Out_Of_Memory = -2,
	Invalid_UTF8  = -3,
	IO            = -4,
	Unsupported   = -5,
	Range         = -6,
	State         = -7,
}

@(private = "package")
_error_from_allocator :: #force_inline proc(err: mem.Allocator_Error) -> Error {
	switch err {
	case .None:
		return nil
	case .Out_Of_Memory:
		return .Out_Of_Memory
	case .Invalid_Pointer, .Invalid_Argument, .Mode_Not_Implemented:
		return .Invalid
	}
	return .Invalid
}

Env_Var :: struct {
	key:   string,
	value: string,
}

RGB :: struct {
	r, g, b: u8,
}

Winsize :: struct {
	rows, cols, x_pixel, y_pixel: u16,
}

Winsize_Callback :: vaxis_winsize_callback

Color_Type :: enum c.int {
	Default = 0,
	Indexed = 1,
	RGB     = 2,
}

Color :: struct {
	type:    Color_Type,
	index:   u8,
	r, g, b: u8,
}

Underline_Style :: enum u8 {
	Off    = 0,
	Single = 1,
	Double = 2,
	Curly  = 3,
	Dotted = 4,
	Dashed = 5,
}

Style_Attribute :: enum u8 {
	Bold          = 0,
	Dim           = 1,
	Italic        = 2,
	Blink         = 3,
	Reverse       = 4,
	Invisible     = 5,
	Strikethrough = 6,
}

Style_Attributes :: distinct bit_set[Style_Attribute; u8]

Style :: struct {
	fg, bg, ul: Color,
	underline:  Underline_Style,
	attrs:      Style_Attributes,
}

Cell :: struct {
	grapheme: string,
	width:    u8,
	style:    Style,
}

Segment :: struct {
	text:  string,
	style: Style,
}

@(private = "package")
_Allocator_State :: struct {
	allocator:  mem.Allocator,
	references: int,
}

@(private = "package")
_allocator_state_new :: proc(allocator: mem.Allocator) -> (state: ^_Allocator_State, err: Error) {
	allocated_state, allocator_err := mem.new(_Allocator_State, allocator)
	if allocator_err != nil {
		return nil, _error_from_allocator(allocator_err)
	}
	state = allocated_state
	state^ = {
		allocator  = allocator,
		references = 1,
	}
	return state, nil
}

@(private = "package")
_allocator_state_retain :: #force_inline proc(state: ^_Allocator_State) {
	sync.atomic_add(&state.references, 1)
}

@(private = "package")
_allocator_state_release :: proc(state: ^_Allocator_State) {
	if sync.atomic_sub(&state.references, 1) != 1 {
		return
	}
	allocator := state.allocator
	_ = mem.free_with_size(state, size_of(_Allocator_State), allocator)
}

@(private = "package")
_allocator_alloc :: proc "c" (
	ctx: rawptr,
	length: c.size_t,
	alignment: u8,
	_: c.uintptr_t,
) -> rawptr {
	state := cast(^_Allocator_State)ctx
	context = runtime.default_context()
	size := int(length)
	data, err := state.allocator.procedure(
		state.allocator.data,
		.Alloc_Non_Zeroed,
		size,
		int(alignment),
		nil,
		0,
	)
	if err == .Mode_Not_Implemented {
		data, err = state.allocator.procedure(
			state.allocator.data,
			.Alloc,
			size,
			int(alignment),
			nil,
			0,
		)
	}
	if err != nil {
		return nil
	}
	return raw_data(data)
}

@(private = "package")
_allocator_resize :: proc "c" (
	_, _: rawptr,
	_: c.size_t,
	_: u8,
	_: c.size_t,
	_: c.uintptr_t,
) -> bool {
	return false
}

@(private = "package")
_allocator_remap :: proc "c" (
	ctx, memory: rawptr,
	memory_len: c.size_t,
	alignment: u8,
	new_len: c.size_t,
	_: c.uintptr_t,
) -> rawptr {
	state := cast(^_Allocator_State)ctx
	context = runtime.default_context()
	data, err := state.allocator.procedure(
		state.allocator.data,
		.Resize_Non_Zeroed,
		int(new_len),
		int(alignment),
		memory,
		int(memory_len),
	)
	if err != nil {
		return nil
	}
	return raw_data(data)
}

@(private = "package")
_allocator_free :: proc "c" (ctx, memory: rawptr, memory_len: c.size_t, _: u8, _: c.uintptr_t) {
	state := cast(^_Allocator_State)ctx
	context = runtime.default_context()
	_, _ = state.allocator.procedure(state.allocator.data, .Free, 0, 0, memory, int(memory_len))
}

@(private = "package")
_odin_allocator_vtable := vaxis_allocator_vtable {
	alloc  = _allocator_alloc,
	resize = _allocator_resize,
	remap  = _allocator_remap,
	free   = _allocator_free,
}

@(private = "package")
_raw_allocator :: #force_inline proc(state: ^_Allocator_State) -> vaxis_allocator {
	return {ctx = state, vtable = &_odin_allocator_vtable}
}

Unicode_Width_Mode :: enum u8 {
	WCWidth = 0,
	Unicode = 1,
	No_ZWJ  = 2,
}

Capabilities :: struct {
	kitty_keyboard, kitty_graphics, no_color, rgb, sgr_pixels:       bool,
	color_scheme_updates, explicit_width, scaled_text, multi_cursor: bool,
	unicode_width:                                                   Unicode_Width_Mode,
}

capabilities_default :: proc() -> Capabilities {
	return transmute(Capabilities)(vaxis_capabilities_default())
}

Screen :: struct {
	raw:       ^vaxis_screen,
	allocator: ^_Allocator_State,
}

screen_init :: proc(
	screen: ^Screen,
	size: Winsize,
	allocator: mem.Allocator = context.allocator,
) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_screen: ^vaxis_screen
	err := Error(
		vaxis_screen_new_with_allocator(
			&raw_allocator,
			cast(vaxis_winsize)size,
			&raw_screen,
		),
	)
	if err != nil {
		_allocator_state_release(state)
		return err
	}
	screen^ = {
		raw       = raw_screen,
		allocator = state,
	}
	return nil
}

screen_deinit :: proc(screen: ^Screen) {
	vaxis_screen_free(screen.raw)
	_allocator_state_release(screen.allocator)
	screen^ = {}
}

screen_resize :: proc(screen: ^Screen, size: Winsize) -> Error {
	return Error(vaxis_screen_resize(screen.raw, cast(vaxis_winsize)size))
}

screen_window :: proc(screen: ^Screen) -> Window {
	return vaxis_screen_window(screen.raw)
}

screen_read_cell :: proc(screen: ^Screen, col, row: u16) -> (cell: Cell, err: Error) {
	raw_cell: vaxis_cell
	err = Error(vaxis_screen_read_cell(screen.raw, col, row, &raw_cell))
	cell = transmute(Cell)(raw_cell)
	return
}

Wrap :: enum c.int {
	Grapheme = 0,
	Word     = 1,
	None     = 2,
}

Print_Options :: struct {
	row_offset, col_offset: u16,
	wrap:                   Wrap,
	commit:                 bool,
}

DEFAULT_PRINT_OPTIONS :: Print_Options {
	commit = true,
}

Print_Result :: struct {
	col, row: u16,
	overflow: bool,
}

Border_Side :: enum u8 {
	Top    = 0,
	Right  = 1,
	Bottom = 2,
	Left   = 3,
}

Border_Sides :: distinct bit_set[Border_Side; u8]

Cursor_Shape :: enum u8 {
	Default         = 0,
	Block_Blink     = 1,
	Block           = 2,
	Underline_Blink = 3,
	Underline       = 4,
	Beam_Blink      = 5,
	Beam            = 6,
}

Window_Options :: struct {
	x, y:          i32,
	width, height: u16,
	border:        Border_Sides,
	border_style:  Style,
}

Window :: ^vaxis_window

window_free :: proc(window: Window) {
	vaxis_window_free(window)
}

window_child :: proc(parent: Window, options: Window_Options) -> Window {
	return vaxis_window_child(parent, transmute(vaxis_window_options)(options))
}

window_width :: proc(window: Window) -> u16 {
	return vaxis_window_width(window)
}

window_height :: proc(window: Window) -> u16 {
	return vaxis_window_height(window)
}

window_clear :: proc(window: Window) {
	vaxis_window_clear(window)
}

window_fill :: proc(window: Window, cell: Cell) -> Error {
	raw_cell := transmute(vaxis_cell)(cell)
	return Error(vaxis_window_fill(window, &raw_cell))
}

window_write_cell :: proc(window: Window, col, row: u16, cell: Cell) -> Error {
	raw_cell := transmute(vaxis_cell)(cell)
	return Error(vaxis_window_write_cell(window, col, row, &raw_cell))
}

window_read_cell :: proc(window: Window, col, row: u16) -> (cell: Cell, err: Error) {
	raw_cell: vaxis_cell
	err = Error(vaxis_window_read_cell(window, col, row, &raw_cell))
	cell = transmute(Cell)(raw_cell)
	return
}

window_grapheme_width :: proc(window: Window, text: string) -> u16 {
	raw_text := transmute(vaxis_string)(text)
	return vaxis_window_grapheme_width(window, raw_text.ptr, raw_text.len)
}

window_hide_cursor :: proc(window: Window) {
	vaxis_window_hide_cursor(window)
}

window_show_cursor :: proc(window: Window, col, row: u16) {
	vaxis_window_show_cursor(window, col, row)
}

window_set_cursor_shape :: proc(window: Window, shape: Cursor_Shape) {
	vaxis_window_set_cursor_shape(window, u8(shape))
}

window_print :: proc(
	window: Window,
	segments: []Segment,
	options: Print_Options = DEFAULT_PRINT_OPTIONS,
) -> (
	print_result: Print_Result,
	err: Error,
) {
	raw_result: vaxis_print_result
	err = Error(
		vaxis_window_print(
			window,
			cast([^]vaxis_segment)raw_data(segments),
			c.size_t(len(segments)),
			transmute(vaxis_print_options)(options),
			&raw_result,
		),
	)
	print_result = cast(Print_Result)raw_result
	return
}

window_scroll :: proc(window: Window, rows: u16) {
	vaxis_window_scroll(window, rows)
}

Text_Input :: struct {
	raw:       ^vaxis_text_input,
	allocator: ^_Allocator_State,
}

text_input_init :: proc(
	input: ^Text_Input,
	allocator: mem.Allocator = context.allocator,
) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_input: ^vaxis_text_input
	err := Error(vaxis_text_input_new_with_allocator(&raw_allocator, &raw_input))
	if err != nil {
		_allocator_state_release(state)
		return err
	}
	input^ = {
		raw       = raw_input,
		allocator = state,
	}
	return nil
}

text_input_deinit :: proc(input: ^Text_Input) {
	vaxis_text_input_free(input.raw)
	_allocator_state_release(input.allocator)
	input^ = {}
}

text_input_insert :: proc(input: ^Text_Input, text: string) -> Error {
	raw_text := transmute(vaxis_string)(text)
	return Error(vaxis_text_input_insert(input.raw, raw_text.ptr, raw_text.len))
}

text_input_update_key :: proc(input: ^Text_Input, event: Event) -> Error {
	return Error(vaxis_text_input_update_key(input.raw, event))
}

text_input_get_text :: proc(input: ^Text_Input) -> (text: string, err: Error) {
	raw_text: vaxis_string
	err = Error(vaxis_text_input_get_text(input.raw, &raw_text))
	text = transmute(string)(raw_text)
	return
}

text_input_reset :: proc(input: ^Text_Input) {
	vaxis_text_input_reset(input.raw)
}

text_input_cursor_left :: proc(input: ^Text_Input) {
	vaxis_text_input_cursor_left(input.raw)
}

text_input_cursor_right :: proc(input: ^Text_Input) {
	vaxis_text_input_cursor_right(input.raw)
}

text_input_draw :: proc(input: ^Text_Input, window: Window, style: Style) -> Error {
	raw_style := transmute(vaxis_style)(style)
	return Error(vaxis_text_input_draw(input.raw, window, &raw_style))
}

when ODIN_OS == .Linux {
	Terminal_Event_Type :: enum c.int {
		None   = 0,
		Exited = 1,
		Redraw = 2,
		Bell   = 3,
		Title  = 4,
		PWD    = 5,
	}

	Terminal_Event :: struct {
		type: Terminal_Event_Type,
		text: string,
	}

	Terminal_Options :: struct {
		scrollback_size:   u16,
		size:              Winsize,
		working_directory: string,
		environment:       []Env_Var,
	}

	Terminal :: struct {
		raw:       ^vaxis_terminal,
		allocator: ^_Allocator_State,
	}

	terminal_init :: proc(
		terminal: ^Terminal,
		argv: []string,
		options: Terminal_Options,
		allocator: mem.Allocator = context.allocator,
	) -> Error {
		state := _allocator_state_new(allocator) or_return
		raw_allocator := _raw_allocator(state)
		raw_options := vaxis_terminal_options {
			scrollback_size   = options.scrollback_size,
			size              = cast(vaxis_winsize)options.size,
			working_directory = transmute(vaxis_string)(options.working_directory),
			environment       = cast([^]vaxis_env_var)raw_data(options.environment),
			environment_count = c.size_t(len(options.environment)),
		}
		raw_argv := cast([^]vaxis_string)raw_data(argv)
		raw_terminal: ^vaxis_terminal
		err := Error(
			vaxis_terminal_new_with_allocator(
				&raw_allocator,
				raw_argv,
				c.size_t(len(argv)),
				&raw_options,
				&raw_terminal,
			),
		)
		if err != nil {
			_allocator_state_release(state)
			return err
		}
		terminal^ = {
			raw       = raw_terminal,
			allocator = state,
		}
		return nil
	}

	terminal_deinit :: proc(terminal: ^Terminal) {
		vaxis_terminal_free(terminal.raw)
		_allocator_state_release(terminal.allocator)
		terminal^ = {}
	}

	terminal_spawn :: proc(terminal: ^Terminal) -> Error {
		return Error(vaxis_terminal_spawn(terminal.raw))
	}

	terminal_resize :: proc(terminal: ^Terminal, size: Winsize) -> Error {
		return Error(vaxis_terminal_resize(terminal.raw, cast(vaxis_winsize)size))
	}

	terminal_draw :: proc(terminal: ^Terminal, window: Window) -> Error {
		return Error(vaxis_terminal_draw(terminal.raw, window))
	}

	terminal_update_key :: proc(terminal: ^Terminal, event: Event) -> Error {
		return Error(vaxis_terminal_update_key(terminal.raw, event))
	}

	terminal_try_event :: proc(
		terminal: ^Terminal,
	) -> (
		event: Terminal_Event,
		available: bool,
		err: Error,
	) {
		raw_event: vaxis_terminal_event
		err = Error(vaxis_terminal_try_event(terminal.raw, &raw_event, &available))
		event = transmute(Terminal_Event)(raw_event)
		return
	}
}

Image_Scale :: enum c.int {
	None    = 0,
	Fill    = 1,
	Fit     = 2,
	Contain = 3,
}

Image_Format :: enum c.int {
	RGB  = 0,
	RGBA = 1,
	PNG  = 2,
}

Image_Medium :: enum c.int {
	File          = 0,
	Temp_File     = 1,
	Shared_Memory = 2,
}

Image_Draw_Options :: struct {
	scale:       Image_Scale,
	z_index:     i32,
	has_z_index: bool,
}

Image :: struct {
	raw:       ^vaxis_image,
	allocator: ^_Allocator_State,
}

image_init :: proc(
	image: ^Image,
	id: u32,
	pixel_width, pixel_height: u16,
	allocator: mem.Allocator = context.allocator,
) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_image: ^vaxis_image
	err := Error(
		vaxis_image_new_with_allocator(&raw_allocator, id, pixel_width, pixel_height, &raw_image),
	)
	if err != nil {
		_allocator_state_release(state)
		return err
	}
	image^ = {
		raw       = raw_image,
		allocator = state,
	}
	return nil
}

image_deinit :: proc(image: ^Image) {
	vaxis_image_free(image.raw)
	_allocator_state_release(image.allocator)
	image^ = {}
}

image_id :: proc(image: ^Image) -> u32 {
	return vaxis_image_id(image.raw)
}

image_draw :: proc(image: ^Image, window: Window, options: Image_Draw_Options = {}) -> Error {
	raw_options := vaxis_image_draw_options {
		scale       = i32(options.scale),
		z_index     = options.z_index,
		has_z_index = options.has_z_index,
	}
	return Error(vaxis_image_draw(image.raw, window, raw_options))
}

image_cell_size :: proc(image: ^Image, window: Window) -> (cols, rows: u16, err: Error) {
	err = Error(vaxis_image_cell_size(image.raw, window, &cols, &rows))
	return
}

TTY :: struct {
	raw:       ^vaxis_tty,
	allocator: ^_Allocator_State,
}

tty_init :: proc(tty: ^TTY, allocator: mem.Allocator = context.allocator) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_tty: ^vaxis_tty
	err := Error(vaxis_tty_new_with_allocator(&raw_allocator, &raw_tty))
	if err != nil {
		_allocator_state_release(state)
		return err
	}
	tty^ = {
		raw       = raw_tty,
		allocator = state,
	}
	return nil
}

tty_deinit :: proc(tty: ^TTY) {
	vaxis_tty_free(tty.raw)
	_allocator_state_release(tty.allocator)
	tty^ = {}
}

tty_winsize :: proc(tty: ^TTY) -> (size: Winsize, err: Error) {
	raw_size: vaxis_winsize
	err = Error(vaxis_tty_winsize(tty.raw, &raw_size))
	size = cast(Winsize)raw_size
	return
}

when ODIN_OS == .Windows {
	tty_next_event :: proc(tty: ^TTY, parser: ^Parser) -> (event: Event, err: Error) {
		err = Error(vaxis_tty_next_event(tty.raw, parser.raw, &event))
		return
	}
} else {
	tty_notify_winsize :: proc(tty: ^TTY, callback: Winsize_Callback, ctx: rawptr = nil) -> Error {
		return Error(vaxis_tty_notify_winsize(tty.raw, callback, ctx))
	}

	tty_remove_winsize_notify :: proc(tty: ^TTY, callback: Winsize_Callback, ctx: rawptr = nil) -> Error {
		return Error(vaxis_tty_remove_winsize_notify(tty.raw, callback, ctx))
	}

	tty_read :: proc(tty: ^TTY, buffer: []u8) -> (length: int, err: Error) {
		raw_length: c.size_t
		err = Error(vaxis_tty_read(tty.raw, raw_data(buffer), c.size_t(len(buffer)), &raw_length))
		length = int(raw_length)
		return
	}
}

Runtime_Options :: struct {
	environment: []Env_Var,
}

Runtime :: struct {
	raw:       ^vaxis_runtime,
	allocator: ^_Allocator_State,
}

runtime_init :: proc(
	runtime: ^Runtime,
	tty: ^TTY,
	options: Runtime_Options = {},
	allocator: mem.Allocator = context.allocator,
) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_options := vaxis_runtime_options {
		environment       = cast([^]vaxis_env_var)raw_data(options.environment),
		environment_count = c.size_t(len(options.environment)),
	}
	raw_runtime: ^vaxis_runtime
	err := Error(
		vaxis_runtime_new_with_allocator(&raw_allocator, tty.raw, &raw_options, &raw_runtime),
	)
	if err != nil {
		_allocator_state_release(state)
		return err
	}
	runtime^ = {
		raw       = raw_runtime,
		allocator = state,
	}
	return nil
}

runtime_deinit :: proc(runtime: ^Runtime) {
	vaxis_runtime_free(runtime.raw)
	_allocator_state_release(runtime.allocator)
	runtime^ = {}
}

runtime_resize :: proc(runtime: ^Runtime, size: Winsize) -> Error {
	return Error(vaxis_runtime_resize(runtime.raw, cast(vaxis_winsize)size))
}

runtime_window :: proc(runtime: ^Runtime) -> Window {
	return vaxis_runtime_window(runtime.raw)
}

runtime_render :: proc(runtime: ^Runtime) -> Error {
	return Error(vaxis_runtime_render(runtime.raw))
}

runtime_enter_alt_screen :: proc(runtime: ^Runtime) -> Error {
	return Error(vaxis_runtime_enter_alt_screen(runtime.raw))
}

runtime_exit_alt_screen :: proc(runtime: ^Runtime) -> Error {
	return Error(vaxis_runtime_exit_alt_screen(runtime.raw))
}

runtime_query_terminal :: proc(runtime: ^Runtime, timeout_ns: u64) -> Error {
	return Error(vaxis_runtime_query_terminal(runtime.raw, timeout_ns))
}

runtime_query_terminal_send :: proc(runtime: ^Runtime) -> Error {
	return Error(vaxis_runtime_query_terminal_send(runtime.raw))
}

runtime_query_terminal_finish :: proc(runtime: ^Runtime) -> Error {
	return Error(vaxis_runtime_query_terminal_finish(runtime.raw))
}

runtime_handle_event :: proc(runtime: ^Runtime, event: Event) -> Error {
	return Error(vaxis_runtime_handle_event(runtime.raw, event))
}

runtime_queue_refresh :: proc(runtime: ^Runtime) {
	vaxis_runtime_queue_refresh(runtime.raw)
}

runtime_capabilities :: proc(runtime: ^Runtime) -> Capabilities {
	return transmute(Capabilities)(vaxis_runtime_capabilities(runtime.raw))
}

runtime_set_mouse_mode :: proc(runtime: ^Runtime, enabled: bool) -> Error {
	return Error(vaxis_runtime_set_mouse_mode(runtime.raw, enabled))
}

runtime_set_bracketed_paste :: proc(runtime: ^Runtime, enabled: bool) -> Error {
	return Error(vaxis_runtime_set_bracketed_paste(runtime.raw, enabled))
}

runtime_set_title :: proc(runtime: ^Runtime, title: string) -> Error {
	raw_title := transmute(vaxis_string)(title)
	return Error(vaxis_runtime_set_title(runtime.raw, raw_title.ptr, raw_title.len))
}

runtime_load_image_memory :: proc(runtime: ^Runtime, image: ^Image, data: []u8) -> Error {
	raw_image: ^vaxis_image
	err := Error(
		vaxis_runtime_load_image_memory(
			runtime.raw,
			raw_data(data),
			c.size_t(len(data)),
			&raw_image,
		),
	)
	if err == nil {
		_allocator_state_retain(runtime.allocator)
		image^ = {
			raw       = raw_image,
			allocator = runtime.allocator,
		}
	}
	return err
}

runtime_transmit_image_path :: proc(
	runtime: ^Runtime,
	image: ^Image,
	path: string,
	width, height: u16,
	medium: Image_Medium,
	format: Image_Format,
) -> Error {
	raw_path := transmute(vaxis_string)(path)
	raw_image: ^vaxis_image
	err := Error(
		vaxis_runtime_transmit_image_path(
			runtime.raw,
			raw_path.ptr,
			raw_path.len,
			width,
			height,
			i32(medium),
			i32(format),
			&raw_image,
		),
	)
	if err == nil {
		_allocator_state_retain(runtime.allocator)
		image^ = {
			raw       = raw_image,
			allocator = runtime.allocator,
		}
	}
	return err
}

runtime_transmit_image_base64 :: proc(
	runtime: ^Runtime,
	image: ^Image,
	data: []u8,
	width, height: u16,
	format: Image_Format,
) -> Error {
	raw_image: ^vaxis_image
	err := Error(
		vaxis_runtime_transmit_image_base64(
			runtime.raw,
			raw_data(data),
			c.size_t(len(data)),
			width,
			height,
			i32(format),
			&raw_image,
		),
	)
	if err == nil {
		_allocator_state_retain(runtime.allocator)
		image^ = {
			raw       = raw_image,
			allocator = runtime.allocator,
		}
	}
	return err
}

runtime_free_transmitted_image :: proc(runtime: ^Runtime, image_id: u32) {
	vaxis_runtime_free_transmitted_image(runtime.raw, image_id)
}

Event_Type :: enum c.int {
	None                     = 0,
	Key_Press                = 1,
	Key_Release              = 2,
	Mouse                    = 3,
	Mouse_Leave              = 4,
	Focus_In                 = 5,
	Focus_Out                = 6,
	Paste_Start              = 7,
	Paste_End                = 8,
	Paste                    = 9,
	Color_Report             = 10,
	Color_Scheme             = 11,
	Winsize                  = 12,
	Cap_Kitty_Keyboard       = 13,
	Cap_Kitty_Graphics       = 14,
	Cap_RGB                  = 15,
	Cap_SGR_Pixels           = 16,
	Cap_Unicode              = 17,
	Cap_DA1                  = 18,
	Cap_Color_Scheme_Updates = 19,
	Cap_Multi_Cursor         = 20,
}

Key_Modifier :: enum u8 {
	Shift     = 0,
	Alt       = 1,
	Ctrl      = 2,
	Super     = 3,
	Hyper     = 4,
	Meta      = 5,
	Caps_Lock = 6,
	Num_Lock  = 7,
}

Key_Modifiers :: distinct bit_set[Key_Modifier; u8]

Mouse_Button :: enum u8 {
	Left        = 0,
	Middle      = 1,
	Right       = 2,
	None        = 3,
	Wheel_Up    = 64,
	Wheel_Down  = 65,
	Wheel_Right = 66,
	Wheel_Left  = 67,
	Button_8    = 128,
	Button_9    = 129,
	Button_10   = 130,
	Button_11   = 131,
}

Mouse_Modifier :: enum u8 {
	Shift = 0,
	Alt   = 1,
	Ctrl  = 2,
}

Mouse_Modifiers :: distinct bit_set[Mouse_Modifier; u8]

Mouse_Event_Type :: enum u8 {
	Press   = 0,
	Release = 1,
	Motion  = 2,
	Drag    = 3,
}

Color_Report_Kind :: enum u8 {
	Foreground = 0,
	Background = 1,
	Cursor     = 2,
	Index      = 3,
}

Color_Scheme :: enum u8 {
	Dark  = 0,
	Light = 1,
}

Event :: ^vaxis_event

event_get_type :: proc(event: Event) -> Event_Type {
	return Event_Type(vaxis_event_get_type(event))
}

event_key_codepoint :: proc(event: Event) -> u32 {
	return vaxis_event_key_codepoint(event)
}

event_key_shifted_codepoint :: proc(event: Event) -> u32 {
	return vaxis_event_key_shifted_codepoint(event)
}

event_key_base_layout_codepoint :: proc(event: Event) -> u32 {
	return vaxis_event_key_base_layout_codepoint(event)
}

event_key_mods :: proc(event: Event) -> Key_Modifiers {
	return transmute(Key_Modifiers)(vaxis_event_key_mods(event))
}

event_key_text :: proc(event: Event) -> string {
	return transmute(string)(vaxis_event_key_text(event))
}

event_key_matches :: proc(event: Event, codepoint: u32, mods: Key_Modifiers) -> bool {
	return vaxis_event_key_matches(event, codepoint, transmute(u8)(mods))
}

event_mouse_col :: proc(event: Event) -> i16 {
	return vaxis_event_mouse_col(event)
}

event_mouse_row :: proc(event: Event) -> i16 {
	return vaxis_event_mouse_row(event)
}

event_mouse_button :: proc(event: Event) -> Mouse_Button {
	return Mouse_Button(vaxis_event_mouse_button(event))
}

event_mouse_mods :: proc(event: Event) -> Mouse_Modifiers {
	return transmute(Mouse_Modifiers)(vaxis_event_mouse_mods(event))
}

event_mouse_type :: proc(event: Event) -> Mouse_Event_Type {
	return Mouse_Event_Type(vaxis_event_mouse_type(event))
}

event_paste_text :: proc(event: Event) -> string {
	return transmute(string)(vaxis_event_paste_text(event))
}

event_color_report_kind :: proc(event: Event) -> Color_Report_Kind {
	return Color_Report_Kind(vaxis_event_color_report_kind(event))
}

event_color_report_index :: proc(event: Event) -> u8 {
	return vaxis_event_color_report_index(event)
}

event_color_report_rgb :: proc(event: Event) -> RGB {
	value := vaxis_event_color_report_rgb(event)
	return {r = value.r, g = value.g, b = value.b}
}

event_color_scheme :: proc(event: Event) -> Color_Scheme {
	return Color_Scheme(vaxis_event_color_scheme(event))
}

event_winsize_rows :: proc(event: Event) -> u16 {
	return vaxis_event_winsize_rows(event)
}

event_winsize_cols :: proc(event: Event) -> u16 {
	return vaxis_event_winsize_cols(event)
}

event_winsize_x_pixel :: proc(event: Event) -> u16 {
	return vaxis_event_winsize_x_pixel(event)
}

event_winsize_y_pixel :: proc(event: Event) -> u16 {
	return vaxis_event_winsize_y_pixel(event)
}

Parser :: struct {
	raw:       ^vaxis_parser,
	allocator: ^_Allocator_State,
}

parser_init :: proc(parser: ^Parser, allocator: mem.Allocator = context.allocator) -> Error {
	state := _allocator_state_new(allocator) or_return
	raw_allocator := _raw_allocator(state)
	raw_parser := vaxis_parser_new_with_allocator(&raw_allocator)
	if raw_parser == nil {
		_allocator_state_release(state)
		return .Out_Of_Memory
	}
	parser^ = {
		raw       = raw_parser,
		allocator = state,
	}
	return nil
}

parser_deinit :: proc(parser: ^Parser) {
	vaxis_parser_free(parser.raw)
	_allocator_state_release(parser.allocator)
	parser^ = {}
}

parser_parse :: proc(parser: ^Parser, input: []u8) -> (event: Event, consumed: int, err: Error) {
	raw_consumed: c.size_t
	err = Error(
		vaxis_parser_parse(
			parser.raw,
			raw_data(input),
			c.size_t(len(input)),
			&event,
			&raw_consumed,
		),
	)
	consumed = int(raw_consumed)
	return
}

key_from_name :: proc(name: string) -> u32 {
	raw_name := transmute(vaxis_string)(name)
	return vaxis_key_from_name(raw_name.ptr, raw_name.len)
}

version :: proc() -> string {
	return string(vaxis_version())
}
