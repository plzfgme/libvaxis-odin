# libvaxis-odin

Odin bindings for the C API of [libvaxis](https://github.com/rockorager/libvaxis).

`raw.odin` contains the direct low-level bindings to the C ABI. `libvaxis.odin` adds a higher-level, idiomatic Odin API with typed values and support for Odin allocators.

## Requirements

- Odin
- Zig 0.16.0

## Usage

Build the libvaxis C library first:

```sh
cd libvaxis
zig build lib-static
```

## License

MIT. libvaxis retains its own MIT license in [`libvaxis/LICENSE`](libvaxis/LICENSE).
