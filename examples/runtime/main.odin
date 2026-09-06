// Odin port of ../../libvaxis/examples/c/runtime.c.

package main

import vaxis "../.."
import "core:mem"

exercise :: proc(allocator: mem.Allocator) {
	screen: vaxis.Screen
	assert(vaxis.screen_init(&screen, {rows = 2, cols = 8, x_pixel = 80, y_pixel = 160}, allocator) == nil)
	defer vaxis.screen_deinit(&screen)

	root := vaxis.screen_window(&screen)
	assert(root != nil)
	defer vaxis.window_free(root)
	assert(vaxis.window_width(root) == 8)
	assert(vaxis.window_height(root) == 2)

	style := vaxis.Style{attrs = {.Bold}}
	segments := []vaxis.Segment{{text = "hello", style = style}}
	_, err := vaxis.window_print(root, segments)
	assert(err == nil)
	cell, read_err := vaxis.window_read_cell(root, 0, 0)
	assert(read_err == nil)
	assert(cell.grapheme == "h")

	changing := []u8{'a'}
	changing_cell := vaxis.Cell{
		grapheme = transmute(string)(changing),
		width    = 1,
		style    = style,
	}
	assert(vaxis.window_write_cell(root, 7, 1, changing_cell) == nil)
	changing[0] = 'z'
	cell, read_err = vaxis.window_read_cell(root, 7, 1)
	assert(read_err == nil)
	assert(cell.grapheme == "a")
	for i in 0 ..< 70_000 {
		changing[0] = u8('a' + i % 26)
		assert(vaxis.window_write_cell(root, 7, 1, changing_cell) == nil)
	}

	child := vaxis.window_child(root, {
		x            = 1,
		y            = 0,
		width        = 6,
		height       = 2,
		border       = {.Top, .Right, .Bottom, .Left},
		border_style = style,
	})
	assert(child != nil)
	defer vaxis.window_free(child)
	vaxis.window_hide_cursor(child)
	vaxis.window_show_cursor(child, 0, 0)

	input: vaxis.Text_Input
	assert(vaxis.text_input_init(&input, allocator) == nil)
	defer vaxis.text_input_deinit(&input)
	assert(vaxis.text_input_insert(&input, "vaxis") == nil)
	text, text_err := vaxis.text_input_get_text(&input)
	assert(text_err == nil)
	assert(text == "vaxis")
	assert(vaxis.text_input_draw(&input, child, style) == nil)

	image: vaxis.Image
	assert(vaxis.image_init(&image, 7, 40, 40, allocator) == nil)
	defer vaxis.image_deinit(&image)
	assert(vaxis.image_id(&image) == 7)
	_, _, image_err := vaxis.image_cell_size(&image, root)
	assert(image_err == nil)
	assert(vaxis.image_draw(&image, root, {scale = .Contain}) == nil)
}

main :: proc() {
	tracker: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracker, context.allocator)
	allocator := mem.tracking_allocator(&tracker)

	exercise(allocator)
	assert(len(tracker.allocation_map) == 0)
	assert(len(tracker.bad_free_array) == 0)
	mem.tracking_allocator_destroy(&tracker)
}
