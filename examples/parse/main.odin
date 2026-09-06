// Odin port of ../../libvaxis/examples/c/parse.c.

package main

import "core:fmt"
import vaxis "../.."

parse :: proc(parser: ^vaxis.Parser, input: string) -> (vaxis.Event, int, vaxis.Error) {
	return vaxis.parser_parse(parser, transmute([]u8)(input))
}

main :: proc() {
	parser: vaxis.Parser
	assert(vaxis.parser_init(&parser) == nil)
	defer vaxis.parser_deinit(&parser)

	event, consumed, err := parse(&parser, "a")
	assert(err == nil)
	assert(consumed == 1)
	assert(vaxis.event_get_type(event) == .Key_Press)
	assert(vaxis.event_key_codepoint(event) == 'a')
	assert(vaxis.event_key_text(event) == "a")
	assert(vaxis.event_key_matches(event, 'a', {}))

	event, consumed, err = parse(&parser, "\x1b[A")
	assert(err == nil)
	assert(consumed == 3)
	assert(vaxis.event_get_type(event) == .Key_Press)
	assert(vaxis.event_key_codepoint(event) == vaxis.VAXIS_KEY_UP)

	event, _, err = parse(&parser, "\x1b[97:65;2u")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Key_Press)
	assert(vaxis.event_key_codepoint(event) == 'a')
	assert(vaxis.event_key_shifted_codepoint(event) == 'A')
	assert(.Shift in vaxis.event_key_mods(event))
	assert(vaxis.event_key_matches(event, 'a', {.Shift}))

	event, _, err = parse(&parser, "\x1b[<35;1;1m")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Mouse)
	assert(vaxis.event_mouse_col(event) == 0)
	assert(vaxis.event_mouse_row(event) == 0)
	assert(vaxis.event_mouse_button(event) == .None)
	assert(vaxis.event_mouse_type(event) == .Motion)
	assert(vaxis.event_key_codepoint(event) == 0)
	assert(vaxis.event_key_text(event) == "")

	event, _, err = parse(&parser, "\x1b[48;24;80;480;1440t")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Winsize)
	assert(vaxis.event_winsize_rows(event) == 24)
	assert(vaxis.event_winsize_cols(event) == 80)
	assert(vaxis.event_winsize_x_pixel(event) == 1440)
	assert(vaxis.event_winsize_y_pixel(event) == 480)

	event, _, err = parse(&parser, "\x1b]11;rgb:ffff/8080/0000\x1b\\")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Color_Report)
	assert(vaxis.event_color_report_kind(event) == .Background)
	assert(vaxis.event_color_report_rgb(event) == vaxis.RGB{r = 0xff, g = 0x80, b = 0})

	event, _, err = parse(&parser, "\x1b]52;c;b3NjNTIgcGFzdGU=\x1b\\")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Paste)
	assert(vaxis.event_paste_text(event) == "osc52 paste")

	event, _, err = parse(&parser, "\x1b[I")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Focus_In)
	event, _, err = parse(&parser, "\x1b[O")
	assert(err == nil)
	assert(vaxis.event_get_type(event) == .Focus_Out)

	event, consumed, err = parse(&parser, "\x1b[")
	assert(err == nil)
	assert(event == nil)
	assert(vaxis.event_get_type(event) == .None)
	assert(consumed == 0)

	event, consumed, err = parse(&parser, "\x1b]4;1;rgb:zz/zz/zz\x1b\\")
	assert(err == nil)
	assert(event == nil)
	assert(consumed == 20)

	assert(vaxis.key_from_name("enter") == vaxis.VAXIS_KEY_ENTER)
	assert(vaxis.key_from_name("nope") == 0)
	fmt.printf("libvaxis %s: all Odin parser checks passed\n", vaxis.version())
}
