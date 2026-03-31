# tex-wasm

TeX compiled to WebAssembly. Forked from [@drgrice1/tikzjax](https://github.com/drgrice1/tikzjax), stripped to the engine essentials.

## What's included

- `dist/tex.wasm.gz` — TeX engine (e-TeX) compiled to WASM via emscripten
- `dist/core.dump.gz` — Pre-loaded LaTeX format (article class, amsmath, etc.)
- `dist/fonts/` — Computer Modern woff2 fonts (152 fonts)
- `dist/tex_files/` — TeX support files (.sty, .def, .cfg — gzipped)
- `dist/tfm/` — TFM font metric data (character widths, heights, depths)

## Usage

This is a submodule of [pretex](https://github.com/somnai-dreams/pretex). The JS harness that drives the WASM engine lives in pretex's `src/tex/engine.ts`.

## Sizes

| Asset | Size |
|-|-|
| tex.wasm.gz | 124K |
| core.dump.gz | 5.8M |
| fonts/ | 1.8M |
| tex_files/ | 1.3M |
| tfm/ | 12K |

## Credits

- [Jim Fowler](https://github.com/kisonecat) — original tikzjax and web2js (Pascal TeX → WASM compilation)
- [@drgrice1](https://github.com/drgrice1) — tikzjax fork with dvi2html, font tooling, and modernized build
- [Jesse Hoobergs](https://github.com/jhoobergs) — web2js improvements

## License

MIT (inherited from tikzjax)
