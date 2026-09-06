package libvaxis

import "core:c"

// Direct binding to the stable C ABI declared by libvaxis/include/vaxis.h.
// Handles are opaque. Strings and event data are borrowed unless the C API
// explicitly transfers ownership.

when ODIN_OS == .Windows {
	foreign import vaxis_lib "libvaxis/zig-out/lib/vaxis-static.lib"
} else {
	foreign import vaxis_lib "libvaxis/zig-out/lib/libvaxis.a"
}

VAXIS_ENUM_MAX_VALUE :: max(c.int)

vaxis_result :: enum c.int {
	VAXIS_OK               =  0,
	VAXIS_ERR_INVALID      = -1,
	VAXIS_ERR_OOM          = -2,
	VAXIS_ERR_INVALID_UTF8 = -3,
	VAXIS_ERR_IO           = -4,
	VAXIS_ERR_UNSUPPORTED  = -5,
	VAXIS_ERR_RANGE        = -6,
	VAXIS_ERR_STATE        = -7,

	VAXIS_RESULT_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_OK               :: vaxis_result.VAXIS_OK
VAXIS_ERR_INVALID      :: vaxis_result.VAXIS_ERR_INVALID
VAXIS_ERR_OOM          :: vaxis_result.VAXIS_ERR_OOM
VAXIS_ERR_INVALID_UTF8 :: vaxis_result.VAXIS_ERR_INVALID_UTF8
VAXIS_ERR_IO           :: vaxis_result.VAXIS_ERR_IO
VAXIS_ERR_UNSUPPORTED  :: vaxis_result.VAXIS_ERR_UNSUPPORTED
VAXIS_ERR_RANGE        :: vaxis_result.VAXIS_ERR_RANGE
VAXIS_ERR_STATE        :: vaxis_result.VAXIS_ERR_STATE
VAXIS_RESULT_MAX_VALUE :: vaxis_result.VAXIS_RESULT_MAX_VALUE

vaxis_event_type :: enum c.int {
	VAXIS_EVENT_NONE                     =  0,
	VAXIS_EVENT_KEY_PRESS                =  1,
	VAXIS_EVENT_KEY_RELEASE              =  2,
	VAXIS_EVENT_MOUSE                    =  3,
	VAXIS_EVENT_MOUSE_LEAVE              =  4,
	VAXIS_EVENT_FOCUS_IN                 =  5,
	VAXIS_EVENT_FOCUS_OUT                =  6,
	VAXIS_EVENT_PASTE_START              =  7,
	VAXIS_EVENT_PASTE_END                =  8,
	VAXIS_EVENT_PASTE                    =  9,
	VAXIS_EVENT_COLOR_REPORT             = 10,
	VAXIS_EVENT_COLOR_SCHEME             = 11,
	VAXIS_EVENT_WINSIZE                  = 12,
	VAXIS_EVENT_CAP_KITTY_KEYBOARD       = 13,
	VAXIS_EVENT_CAP_KITTY_GRAPHICS       = 14,
	VAXIS_EVENT_CAP_RGB                  = 15,
	VAXIS_EVENT_CAP_SGR_PIXELS           = 16,
	VAXIS_EVENT_CAP_UNICODE              = 17,
	VAXIS_EVENT_CAP_DA1                  = 18,
	VAXIS_EVENT_CAP_COLOR_SCHEME_UPDATES = 19,
	VAXIS_EVENT_CAP_MULTI_CURSOR         = 20,

	VAXIS_EVENT_TYPE_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_EVENT_NONE                     :: vaxis_event_type.VAXIS_EVENT_NONE
VAXIS_EVENT_KEY_PRESS                :: vaxis_event_type.VAXIS_EVENT_KEY_PRESS
VAXIS_EVENT_KEY_RELEASE              :: vaxis_event_type.VAXIS_EVENT_KEY_RELEASE
VAXIS_EVENT_MOUSE                    :: vaxis_event_type.VAXIS_EVENT_MOUSE
VAXIS_EVENT_MOUSE_LEAVE              :: vaxis_event_type.VAXIS_EVENT_MOUSE_LEAVE
VAXIS_EVENT_FOCUS_IN                 :: vaxis_event_type.VAXIS_EVENT_FOCUS_IN
VAXIS_EVENT_FOCUS_OUT                :: vaxis_event_type.VAXIS_EVENT_FOCUS_OUT
VAXIS_EVENT_PASTE_START              :: vaxis_event_type.VAXIS_EVENT_PASTE_START
VAXIS_EVENT_PASTE_END                :: vaxis_event_type.VAXIS_EVENT_PASTE_END
VAXIS_EVENT_PASTE                    :: vaxis_event_type.VAXIS_EVENT_PASTE
VAXIS_EVENT_COLOR_REPORT             :: vaxis_event_type.VAXIS_EVENT_COLOR_REPORT
VAXIS_EVENT_COLOR_SCHEME             :: vaxis_event_type.VAXIS_EVENT_COLOR_SCHEME
VAXIS_EVENT_WINSIZE                  :: vaxis_event_type.VAXIS_EVENT_WINSIZE
VAXIS_EVENT_CAP_KITTY_KEYBOARD       :: vaxis_event_type.VAXIS_EVENT_CAP_KITTY_KEYBOARD
VAXIS_EVENT_CAP_KITTY_GRAPHICS       :: vaxis_event_type.VAXIS_EVENT_CAP_KITTY_GRAPHICS
VAXIS_EVENT_CAP_RGB                  :: vaxis_event_type.VAXIS_EVENT_CAP_RGB
VAXIS_EVENT_CAP_SGR_PIXELS           :: vaxis_event_type.VAXIS_EVENT_CAP_SGR_PIXELS
VAXIS_EVENT_CAP_UNICODE              :: vaxis_event_type.VAXIS_EVENT_CAP_UNICODE
VAXIS_EVENT_CAP_DA1                  :: vaxis_event_type.VAXIS_EVENT_CAP_DA1
VAXIS_EVENT_CAP_COLOR_SCHEME_UPDATES :: vaxis_event_type.VAXIS_EVENT_CAP_COLOR_SCHEME_UPDATES
VAXIS_EVENT_CAP_MULTI_CURSOR         :: vaxis_event_type.VAXIS_EVENT_CAP_MULTI_CURSOR
VAXIS_EVENT_TYPE_MAX_VALUE           :: vaxis_event_type.VAXIS_EVENT_TYPE_MAX_VALUE

VAXIS_MOD_SHIFT     :: 1 << 0
VAXIS_MOD_ALT       :: 1 << 1
VAXIS_MOD_CTRL      :: 1 << 2
VAXIS_MOD_SUPER     :: 1 << 3
VAXIS_MOD_HYPER     :: 1 << 4
VAXIS_MOD_META      :: 1 << 5
VAXIS_MOD_CAPS_LOCK :: 1 << 6
VAXIS_MOD_NUM_LOCK  :: 1 << 7

VAXIS_MOUSE_LEFT        :: 0
VAXIS_MOUSE_MIDDLE      :: 1
VAXIS_MOUSE_RIGHT       :: 2
VAXIS_MOUSE_NONE        :: 3
VAXIS_MOUSE_WHEEL_UP    :: 64
VAXIS_MOUSE_WHEEL_DOWN  :: 65
VAXIS_MOUSE_WHEEL_RIGHT :: 66
VAXIS_MOUSE_WHEEL_LEFT  :: 67
VAXIS_MOUSE_BUTTON_8    :: 128
VAXIS_MOUSE_BUTTON_9    :: 129
VAXIS_MOUSE_BUTTON_10   :: 130
VAXIS_MOUSE_BUTTON_11   :: 131

VAXIS_MOUSE_PRESS   :: 0
VAXIS_MOUSE_RELEASE :: 1
VAXIS_MOUSE_MOTION  :: 2
VAXIS_MOUSE_DRAG    :: 3

VAXIS_MOUSE_MOD_SHIFT :: 1 << 0
VAXIS_MOUSE_MOD_ALT   :: 1 << 1
VAXIS_MOUSE_MOD_CTRL  :: 1 << 2

VAXIS_COLOR_FG     :: 0
VAXIS_COLOR_BG     :: 1
VAXIS_COLOR_CURSOR :: 2
VAXIS_COLOR_INDEX  :: 3

VAXIS_COLOR_SCHEME_DARK  :: 0
VAXIS_COLOR_SCHEME_LIGHT :: 1

vaxis_string :: struct {
	ptr: [^]u8,
	len: c.size_t,
}

vaxis_allocator_vtable :: struct {
	alloc:  proc "c" (ctx: rawptr, len: c.size_t, alignment: u8, return_address: c.uintptr_t) -> rawptr,
	resize: proc "c" (ctx, memory: rawptr, memory_len: c.size_t, alignment: u8, new_len: c.size_t, return_address: c.uintptr_t) -> bool,
	remap:  proc "c" (ctx, memory: rawptr, memory_len: c.size_t, alignment: u8, new_len: c.size_t, return_address: c.uintptr_t) -> rawptr,
	free:   proc "c" (ctx, memory: rawptr, memory_len: c.size_t, alignment: u8, return_address: c.uintptr_t),
}

vaxis_allocator :: struct {
	ctx:    rawptr,
	vtable: ^vaxis_allocator_vtable,
}

vaxis_env_var :: struct {
	key:   vaxis_string,
	value: vaxis_string,
}

vaxis_rgb :: struct {
	r, g, b: u8,
}

vaxis_parser     :: struct {}
vaxis_event      :: struct {}
vaxis_screen     :: struct {}
vaxis_window     :: struct {}
vaxis_text_input :: struct {}
vaxis_terminal   :: struct {}
vaxis_image      :: struct {}
vaxis_tty        :: struct {}
vaxis_runtime    :: struct {}

vaxis_winsize :: struct {
	rows, cols, x_pixel, y_pixel: u16,
}

vaxis_color_type :: enum c.int {
	VAXIS_COLOR_DEFAULT = 0,
	VAXIS_COLOR_INDEXED = 1,
	VAXIS_COLOR_RGB     = 2,

	VAXIS_COLOR_TYPE_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_COLOR_DEFAULT        :: vaxis_color_type.VAXIS_COLOR_DEFAULT
VAXIS_COLOR_INDEXED        :: vaxis_color_type.VAXIS_COLOR_INDEXED
VAXIS_COLOR_RGB            :: vaxis_color_type.VAXIS_COLOR_RGB
VAXIS_COLOR_TYPE_MAX_VALUE :: vaxis_color_type.VAXIS_COLOR_TYPE_MAX_VALUE

vaxis_color :: struct {
	type:       i32,
	index:      u8,
	r, g, b:    u8,
}

vaxis_style :: struct {
	fg, bg, ul: vaxis_color,
	underline:  u8,
	attrs:      u8,
}

vaxis_cell :: struct {
	grapheme: vaxis_string,
	width:    u8,
	style:    vaxis_style,
}

vaxis_segment :: struct {
	text:  vaxis_string,
	style: vaxis_style,
}

vaxis_print_result :: struct {
	col, row: u16,
	overflow: bool,
}

vaxis_wrap :: enum c.int {
	VAXIS_WRAP_GRAPHEME = 0,
	VAXIS_WRAP_WORD     = 1,
	VAXIS_WRAP_NONE     = 2,

	VAXIS_WRAP_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_WRAP_GRAPHEME :: vaxis_wrap.VAXIS_WRAP_GRAPHEME
VAXIS_WRAP_WORD     :: vaxis_wrap.VAXIS_WRAP_WORD
VAXIS_WRAP_NONE     :: vaxis_wrap.VAXIS_WRAP_NONE
VAXIS_WRAP_MAX_VALUE :: vaxis_wrap.VAXIS_WRAP_MAX_VALUE

vaxis_print_options :: struct {
	row_offset, col_offset: u16,
	wrap:                   i32,
	commit:                 bool,
}

vaxis_window_options :: struct {
	x, y:         i32,
	width, height: u16,
	border:        u8,
	border_style:  vaxis_style,
}

vaxis_capabilities :: struct {
	kitty_keyboard, kitty_graphics, no_color, rgb, sgr_pixels: bool,
	color_scheme_updates, explicit_width, scaled_text, multi_cursor: bool,
	unicode_width: u8,
}

vaxis_terminal_event_type :: enum c.int {
	VAXIS_TERMINAL_EVENT_NONE   = 0,
	VAXIS_TERMINAL_EVENT_EXITED = 1,
	VAXIS_TERMINAL_EVENT_REDRAW = 2,
	VAXIS_TERMINAL_EVENT_BELL   = 3,
	VAXIS_TERMINAL_EVENT_TITLE  = 4,
	VAXIS_TERMINAL_EVENT_PWD    = 5,

	VAXIS_TERMINAL_EVENT_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_TERMINAL_EVENT_NONE      :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_NONE
VAXIS_TERMINAL_EVENT_EXITED    :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_EXITED
VAXIS_TERMINAL_EVENT_REDRAW    :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_REDRAW
VAXIS_TERMINAL_EVENT_BELL      :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_BELL
VAXIS_TERMINAL_EVENT_TITLE     :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_TITLE
VAXIS_TERMINAL_EVENT_PWD       :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_PWD
VAXIS_TERMINAL_EVENT_MAX_VALUE :: vaxis_terminal_event_type.VAXIS_TERMINAL_EVENT_MAX_VALUE

vaxis_terminal_event :: struct {
	type: i32,
	text: vaxis_string,
}

vaxis_terminal_options :: struct {
	scrollback_size:    u16,
	size:               vaxis_winsize,
	working_directory:  vaxis_string,
	environment:        [^]vaxis_env_var,
	environment_count:  c.size_t,
}

vaxis_image_scale :: enum c.int {
	VAXIS_IMAGE_SCALE_NONE    = 0,
	VAXIS_IMAGE_SCALE_FILL    = 1,
	VAXIS_IMAGE_SCALE_FIT     = 2,
	VAXIS_IMAGE_SCALE_CONTAIN = 3,

	VAXIS_IMAGE_SCALE_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_IMAGE_SCALE_NONE      :: vaxis_image_scale.VAXIS_IMAGE_SCALE_NONE
VAXIS_IMAGE_SCALE_FILL      :: vaxis_image_scale.VAXIS_IMAGE_SCALE_FILL
VAXIS_IMAGE_SCALE_FIT       :: vaxis_image_scale.VAXIS_IMAGE_SCALE_FIT
VAXIS_IMAGE_SCALE_CONTAIN   :: vaxis_image_scale.VAXIS_IMAGE_SCALE_CONTAIN
VAXIS_IMAGE_SCALE_MAX_VALUE :: vaxis_image_scale.VAXIS_IMAGE_SCALE_MAX_VALUE

vaxis_image_format :: enum c.int {
	VAXIS_IMAGE_RGB  = 0,
	VAXIS_IMAGE_RGBA = 1,
	VAXIS_IMAGE_PNG  = 2,

	VAXIS_IMAGE_FORMAT_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_IMAGE_RGB              :: vaxis_image_format.VAXIS_IMAGE_RGB
VAXIS_IMAGE_RGBA             :: vaxis_image_format.VAXIS_IMAGE_RGBA
VAXIS_IMAGE_PNG              :: vaxis_image_format.VAXIS_IMAGE_PNG
VAXIS_IMAGE_FORMAT_MAX_VALUE :: vaxis_image_format.VAXIS_IMAGE_FORMAT_MAX_VALUE

vaxis_image_medium :: enum c.int {
	VAXIS_IMAGE_FILE          = 0,
	VAXIS_IMAGE_TEMP_FILE     = 1,
	VAXIS_IMAGE_SHARED_MEMORY = 2,

	VAXIS_IMAGE_MEDIUM_MAX_VALUE = VAXIS_ENUM_MAX_VALUE,
}

VAXIS_IMAGE_FILE             :: vaxis_image_medium.VAXIS_IMAGE_FILE
VAXIS_IMAGE_TEMP_FILE        :: vaxis_image_medium.VAXIS_IMAGE_TEMP_FILE
VAXIS_IMAGE_SHARED_MEMORY    :: vaxis_image_medium.VAXIS_IMAGE_SHARED_MEMORY
VAXIS_IMAGE_MEDIUM_MAX_VALUE :: vaxis_image_medium.VAXIS_IMAGE_MEDIUM_MAX_VALUE

vaxis_image_draw_options :: struct {
	scale:       i32,
	z_index:     i32,
	has_z_index: bool,
}

vaxis_runtime_options :: struct {
	environment:       [^]vaxis_env_var,
	environment_count: c.size_t,
}

VAXIS_KEY_TAB        :: 0x09
VAXIS_KEY_ENTER      :: 0x0d
VAXIS_KEY_ESCAPE     :: 0x1b
VAXIS_KEY_SPACE      :: 0x20
VAXIS_KEY_BACKSPACE  :: 0x7f
VAXIS_KEY_MULTICODEPOINT :: 1114113
VAXIS_KEY_INSERT     :: 57348
VAXIS_KEY_DELETE     :: 57349
VAXIS_KEY_LEFT       :: 57350
VAXIS_KEY_RIGHT      :: 57351
VAXIS_KEY_UP         :: 57352
VAXIS_KEY_DOWN       :: 57353
VAXIS_KEY_PAGE_UP    :: 57354
VAXIS_KEY_PAGE_DOWN  :: 57355
VAXIS_KEY_HOME       :: 57356
VAXIS_KEY_END        :: 57357
VAXIS_KEY_CAPS_LOCK  :: 57358
VAXIS_KEY_SCROLL_LOCK :: 57359
VAXIS_KEY_NUM_LOCK   :: 57360
VAXIS_KEY_PRINT_SCREEN :: 57361
VAXIS_KEY_PAUSE      :: 57362
VAXIS_KEY_MENU       :: 57363
VAXIS_KEY_F1         :: 57364
VAXIS_KEY_F2         :: 57365
VAXIS_KEY_F3         :: 57366
VAXIS_KEY_F4         :: 57367
VAXIS_KEY_F5         :: 57368
VAXIS_KEY_F6         :: 57369
VAXIS_KEY_F7         :: 57370
VAXIS_KEY_F8         :: 57371
VAXIS_KEY_F9         :: 57372
VAXIS_KEY_F10        :: 57373
VAXIS_KEY_F11        :: 57374
VAXIS_KEY_F12        :: 57375
VAXIS_KEY_F13        :: 57376
VAXIS_KEY_F14        :: 57377
VAXIS_KEY_F15        :: 57378
VAXIS_KEY_F16        :: 57379
VAXIS_KEY_F17        :: 57380
VAXIS_KEY_F18        :: 57381
VAXIS_KEY_F19        :: 57382
VAXIS_KEY_F20        :: 57383
VAXIS_KEY_F21        :: 57384
VAXIS_KEY_F22        :: 57385
VAXIS_KEY_F23        :: 57386
VAXIS_KEY_F24        :: 57387
VAXIS_KEY_F25        :: 57388
VAXIS_KEY_F26        :: 57389
VAXIS_KEY_F27        :: 57390
VAXIS_KEY_F28        :: 57391
VAXIS_KEY_F29        :: 57392
VAXIS_KEY_F30        :: 57393
VAXIS_KEY_F31        :: 57394
VAXIS_KEY_F32        :: 57395
VAXIS_KEY_F33        :: 57396
VAXIS_KEY_F34        :: 57397
VAXIS_KEY_F35        :: 57398
VAXIS_KEY_KP_0       :: 57399
VAXIS_KEY_KP_1       :: 57400
VAXIS_KEY_KP_2       :: 57401
VAXIS_KEY_KP_3       :: 57402
VAXIS_KEY_KP_4       :: 57403
VAXIS_KEY_KP_5       :: 57404
VAXIS_KEY_KP_6       :: 57405
VAXIS_KEY_KP_7       :: 57406
VAXIS_KEY_KP_8       :: 57407
VAXIS_KEY_KP_9       :: 57408
VAXIS_KEY_KP_DECIMAL :: 57409
VAXIS_KEY_KP_DIVIDE  :: 57410
VAXIS_KEY_KP_MULTIPLY :: 57411
VAXIS_KEY_KP_SUBTRACT :: 57412
VAXIS_KEY_KP_ADD     :: 57413
VAXIS_KEY_KP_ENTER   :: 57414
VAXIS_KEY_KP_EQUAL   :: 57415
VAXIS_KEY_KP_SEPARATOR :: 57416
VAXIS_KEY_KP_LEFT    :: 57417
VAXIS_KEY_KP_RIGHT   :: 57418
VAXIS_KEY_KP_UP      :: 57419
VAXIS_KEY_KP_DOWN    :: 57420
VAXIS_KEY_KP_PAGE_UP :: 57421
VAXIS_KEY_KP_PAGE_DOWN :: 57422
VAXIS_KEY_KP_HOME    :: 57423
VAXIS_KEY_KP_END     :: 57424
VAXIS_KEY_KP_INSERT  :: 57425
VAXIS_KEY_KP_DELETE  :: 57426
VAXIS_KEY_KP_BEGIN   :: 57427
VAXIS_KEY_MEDIA_PLAY :: 57428
VAXIS_KEY_MEDIA_PAUSE :: 57429
VAXIS_KEY_MEDIA_PLAY_PAUSE :: 57430
VAXIS_KEY_MEDIA_REVERSE :: 57431
VAXIS_KEY_MEDIA_STOP :: 57432
VAXIS_KEY_MEDIA_FAST_FORWARD :: 57433
VAXIS_KEY_MEDIA_REWIND :: 57434
VAXIS_KEY_MEDIA_TRACK_NEXT :: 57435
VAXIS_KEY_MEDIA_TRACK_PREVIOUS :: 57436
VAXIS_KEY_MEDIA_RECORD :: 57437
VAXIS_KEY_LOWER_VOLUME :: 57438
VAXIS_KEY_RAISE_VOLUME :: 57439
VAXIS_KEY_MUTE_VOLUME :: 57440
VAXIS_KEY_LEFT_SHIFT :: 57441
VAXIS_KEY_LEFT_CONTROL :: 57442
VAXIS_KEY_LEFT_ALT :: 57443
VAXIS_KEY_LEFT_SUPER :: 57444
VAXIS_KEY_LEFT_HYPER :: 57445
VAXIS_KEY_LEFT_META :: 57446
VAXIS_KEY_RIGHT_SHIFT :: 57447
VAXIS_KEY_RIGHT_CONTROL :: 57448
VAXIS_KEY_RIGHT_ALT :: 57449
VAXIS_KEY_RIGHT_SUPER :: 57450
VAXIS_KEY_RIGHT_HYPER :: 57451
VAXIS_KEY_RIGHT_META :: 57452
VAXIS_KEY_ISO_LEVEL_3_SHIFT :: 57453
VAXIS_KEY_ISO_LEVEL_5_SHIFT :: 57454

@(default_calling_convention="c")
foreign vaxis_lib {
	vaxis_alloc :: proc(allocator: ^vaxis_allocator, len: c.size_t) -> [^]u8 ---
	vaxis_free  :: proc(allocator: ^vaxis_allocator, ptr: [^]u8, len: c.size_t) ---

	vaxis_screen_new                :: proc(size: vaxis_winsize, screen: ^^vaxis_screen) -> vaxis_result ---
	vaxis_screen_new_with_allocator :: proc(allocator: ^vaxis_allocator, size: vaxis_winsize, screen: ^^vaxis_screen) -> vaxis_result ---
	vaxis_screen_free               :: proc(screen: ^vaxis_screen) ---
	vaxis_screen_resize             :: proc(screen: ^vaxis_screen, size: vaxis_winsize) -> vaxis_result ---
	vaxis_screen_window             :: proc(screen: ^vaxis_screen) -> ^vaxis_window ---
	vaxis_screen_read_cell          :: proc(screen: ^vaxis_screen, col, row: u16, cell: ^vaxis_cell) -> vaxis_result ---

	vaxis_window_free           :: proc(window: ^vaxis_window) ---
	vaxis_window_child          :: proc(parent: ^vaxis_window, options: vaxis_window_options) -> ^vaxis_window ---
	vaxis_window_width          :: proc(window: ^vaxis_window) -> u16 ---
	vaxis_window_height         :: proc(window: ^vaxis_window) -> u16 ---
	vaxis_window_clear          :: proc(window: ^vaxis_window) ---
	vaxis_window_fill           :: proc(window: ^vaxis_window, cell: ^vaxis_cell) -> vaxis_result ---
	vaxis_window_write_cell     :: proc(window: ^vaxis_window, col, row: u16, cell: ^vaxis_cell) -> vaxis_result ---
	vaxis_window_read_cell      :: proc(window: ^vaxis_window, col, row: u16, cell: ^vaxis_cell) -> vaxis_result ---
	vaxis_window_grapheme_width :: proc(window: ^vaxis_window, text: [^]u8, len: c.size_t) -> u16 ---
	vaxis_window_hide_cursor    :: proc(window: ^vaxis_window) ---
	vaxis_window_show_cursor    :: proc(window: ^vaxis_window, col, row: u16) ---
	vaxis_window_set_cursor_shape :: proc(window: ^vaxis_window, shape: u8) ---
	vaxis_window_print          :: proc(window: ^vaxis_window, segments: [^]vaxis_segment, count: c.size_t, options: vaxis_print_options, result: ^vaxis_print_result) -> vaxis_result ---
	vaxis_window_scroll         :: proc(window: ^vaxis_window, rows: u16) ---

	vaxis_capabilities_default :: proc() -> vaxis_capabilities ---

	vaxis_text_input_new                :: proc(input: ^^vaxis_text_input) -> vaxis_result ---
	vaxis_text_input_new_with_allocator :: proc(allocator: ^vaxis_allocator, input: ^^vaxis_text_input) -> vaxis_result ---
	vaxis_text_input_free               :: proc(input: ^vaxis_text_input) ---
	vaxis_text_input_insert             :: proc(input: ^vaxis_text_input, text: [^]u8, len: c.size_t) -> vaxis_result ---
	vaxis_text_input_update_key         :: proc(input: ^vaxis_text_input, event: ^vaxis_event) -> vaxis_result ---
	vaxis_text_input_get_text           :: proc(input: ^vaxis_text_input, text: ^vaxis_string) -> vaxis_result ---
	vaxis_text_input_reset              :: proc(input: ^vaxis_text_input) ---
	vaxis_text_input_cursor_left        :: proc(input: ^vaxis_text_input) ---
	vaxis_text_input_cursor_right       :: proc(input: ^vaxis_text_input) ---
	vaxis_text_input_draw               :: proc(input: ^vaxis_text_input, window: ^vaxis_window, style: ^vaxis_style) -> vaxis_result ---

	vaxis_terminal_new                :: proc(argv: [^]vaxis_string, argc: c.size_t, options: ^vaxis_terminal_options, terminal: ^^vaxis_terminal) -> vaxis_result ---
	vaxis_terminal_new_with_allocator :: proc(allocator: ^vaxis_allocator, argv: [^]vaxis_string, argc: c.size_t, options: ^vaxis_terminal_options, terminal: ^^vaxis_terminal) -> vaxis_result ---
	vaxis_terminal_free               :: proc(terminal: ^vaxis_terminal) ---
	vaxis_terminal_spawn              :: proc(terminal: ^vaxis_terminal) -> vaxis_result ---
	vaxis_terminal_resize             :: proc(terminal: ^vaxis_terminal, size: vaxis_winsize) -> vaxis_result ---
	vaxis_terminal_draw               :: proc(terminal: ^vaxis_terminal, window: ^vaxis_window) -> vaxis_result ---
	vaxis_terminal_update_key         :: proc(terminal: ^vaxis_terminal, event: ^vaxis_event) -> vaxis_result ---
	vaxis_terminal_try_event          :: proc(terminal: ^vaxis_terminal, event: ^vaxis_terminal_event, available: ^bool) -> vaxis_result ---

	vaxis_image_new                :: proc(id: u32, pixel_width, pixel_height: u16, image: ^^vaxis_image) -> vaxis_result ---
	vaxis_image_new_with_allocator :: proc(allocator: ^vaxis_allocator, id: u32, pixel_width, pixel_height: u16, image: ^^vaxis_image) -> vaxis_result ---
	vaxis_image_free               :: proc(image: ^vaxis_image) ---
	vaxis_image_id                 :: proc(image: ^vaxis_image) -> u32 ---
	vaxis_image_draw               :: proc(image: ^vaxis_image, window: ^vaxis_window, options: vaxis_image_draw_options) -> vaxis_result ---
	vaxis_image_cell_size          :: proc(image: ^vaxis_image, window: ^vaxis_window, cols, rows: ^u16) -> vaxis_result ---

	vaxis_tty_new                :: proc(tty: ^^vaxis_tty) -> vaxis_result ---
	vaxis_tty_new_with_allocator :: proc(allocator: ^vaxis_allocator, tty: ^^vaxis_tty) -> vaxis_result ---
	vaxis_tty_free               :: proc(tty: ^vaxis_tty) ---
	vaxis_tty_winsize            :: proc(tty: ^vaxis_tty, size: ^vaxis_winsize) -> vaxis_result ---
	vaxis_tty_read               :: proc(tty: ^vaxis_tty, buffer: [^]u8, capacity: c.size_t, length: ^c.size_t) -> vaxis_result ---
	vaxis_tty_next_event         :: proc(tty: ^vaxis_tty, parser: ^vaxis_parser, event: ^^vaxis_event) -> vaxis_result ---

	vaxis_runtime_new                :: proc(tty: ^vaxis_tty, options: ^vaxis_runtime_options, runtime: ^^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_new_with_allocator :: proc(allocator: ^vaxis_allocator, tty: ^vaxis_tty, options: ^vaxis_runtime_options, runtime: ^^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_free               :: proc(runtime: ^vaxis_runtime) ---
	vaxis_runtime_resize             :: proc(runtime: ^vaxis_runtime, size: vaxis_winsize) -> vaxis_result ---
	vaxis_runtime_window             :: proc(runtime: ^vaxis_runtime) -> ^vaxis_window ---
	vaxis_runtime_render             :: proc(runtime: ^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_enter_alt_screen   :: proc(runtime: ^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_exit_alt_screen    :: proc(runtime: ^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_query_terminal     :: proc(runtime: ^vaxis_runtime, timeout_ns: u64) -> vaxis_result ---
	vaxis_runtime_query_terminal_send :: proc(runtime: ^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_query_terminal_finish :: proc(runtime: ^vaxis_runtime) -> vaxis_result ---
	vaxis_runtime_handle_event       :: proc(runtime: ^vaxis_runtime, event: ^vaxis_event) -> vaxis_result ---
	vaxis_runtime_queue_refresh      :: proc(runtime: ^vaxis_runtime) ---
	vaxis_runtime_capabilities       :: proc(runtime: ^vaxis_runtime) -> vaxis_capabilities ---
	vaxis_runtime_set_mouse_mode     :: proc(runtime: ^vaxis_runtime, enabled: bool) -> vaxis_result ---
	vaxis_runtime_set_bracketed_paste :: proc(runtime: ^vaxis_runtime, enabled: bool) -> vaxis_result ---
	vaxis_runtime_set_title          :: proc(runtime: ^vaxis_runtime, title: [^]u8, length: c.size_t) -> vaxis_result ---
	vaxis_runtime_load_image_memory  :: proc(runtime: ^vaxis_runtime, data: [^]u8, length: c.size_t, image: ^^vaxis_image) -> vaxis_result ---
	vaxis_runtime_transmit_image_path :: proc(runtime: ^vaxis_runtime, path: [^]u8, length: c.size_t, width, height: u16, medium, format: i32, image: ^^vaxis_image) -> vaxis_result ---
	vaxis_runtime_transmit_image_base64 :: proc(runtime: ^vaxis_runtime, data: [^]u8, length: c.size_t, width, height: u16, format: i32, image: ^^vaxis_image) -> vaxis_result ---
	vaxis_runtime_free_transmitted_image :: proc(runtime: ^vaxis_runtime, image_id: u32) ---

	vaxis_parser_new                :: proc() -> ^vaxis_parser ---
	vaxis_parser_new_with_allocator :: proc(allocator: ^vaxis_allocator) -> ^vaxis_parser ---
	vaxis_parser_free               :: proc(parser: ^vaxis_parser) ---
	vaxis_parser_parse              :: proc(parser: ^vaxis_parser, input: [^]u8, input_len: c.size_t, event: ^^vaxis_event, consumed: ^c.size_t) -> vaxis_result ---

	vaxis_event_get_type                  :: proc(event: ^vaxis_event) -> vaxis_event_type ---
	vaxis_event_key_codepoint             :: proc(event: ^vaxis_event) -> u32 ---
	vaxis_event_key_shifted_codepoint     :: proc(event: ^vaxis_event) -> u32 ---
	vaxis_event_key_base_layout_codepoint :: proc(event: ^vaxis_event) -> u32 ---
	vaxis_event_key_mods                  :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_key_text                  :: proc(event: ^vaxis_event) -> vaxis_string ---
	vaxis_event_key_matches               :: proc(event: ^vaxis_event, codepoint: u32, mods: u8) -> bool ---
	vaxis_event_mouse_col                 :: proc(event: ^vaxis_event) -> i16 ---
	vaxis_event_mouse_row                 :: proc(event: ^vaxis_event) -> i16 ---
	vaxis_event_mouse_button              :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_mouse_mods                :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_mouse_type                :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_paste_text                :: proc(event: ^vaxis_event) -> vaxis_string ---
	vaxis_event_color_report_kind         :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_color_report_index        :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_color_report_rgb          :: proc(event: ^vaxis_event) -> vaxis_rgb ---
	vaxis_event_color_scheme              :: proc(event: ^vaxis_event) -> u8 ---
	vaxis_event_winsize_rows              :: proc(event: ^vaxis_event) -> u16 ---
	vaxis_event_winsize_cols              :: proc(event: ^vaxis_event) -> u16 ---
	vaxis_event_winsize_x_pixel           :: proc(event: ^vaxis_event) -> u16 ---
	vaxis_event_winsize_y_pixel           :: proc(event: ^vaxis_event) -> u16 ---

	vaxis_key_from_name :: proc(name: [^]u8, name_len: c.size_t) -> u32 ---
	vaxis_version       :: proc() -> cstring ---
}
