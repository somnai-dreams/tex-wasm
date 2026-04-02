#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEX_FILES_DIR="$ROOT_DIR/dist/tex_files"
TFM_DIR="$ROOT_DIR/dist/tfm/data"

mkdir -p "$TEX_FILES_DIR" "$TFM_DIR"

declare -A CTAN_FALLBACKS=(
  [cite.sty]="https://mirrors.ctan.org/macros/latex/contrib/cite/cite.sty"
  [enumitem.sty]="https://mirrors.ctan.org/macros/latex/contrib/enumitem/enumitem.sty"
  [mathrsfs.sty]="https://mirrors.ctan.org/macros/latex/contrib/jknapltx/mathrsfs.sty"
)

declare -A CTAN_ARCHIVE_FALLBACKS=(
  [booktabs.sty]="https://mirrors.ctan.org/macros/latex/contrib/booktabs.zip"
  [hyperref.sty]="https://mirrors.ctan.org/macros/latex/contrib/hyperref.zip"
  [lettrine.sty]="https://mirrors.ctan.org/macros/latex/contrib/lettrine.zip"
  [mathtools.sty]="https://mirrors.ctan.org/macros/latex/contrib/mathtools.zip"
  [mhsetup.sty]="https://mirrors.ctan.org/macros/latex/contrib/mathtools.zip"
  [microtype.sty]="https://mirrors.ctan.org/macros/latex/contrib/microtype.zip"
  [nameref.sty]="https://mirrors.ctan.org/macros/latex/contrib/hyperref.zip"
  [pd1enc.def]="https://mirrors.ctan.org/macros/latex/contrib/hyperref.zip"
  [pdfmark.def]="https://mirrors.ctan.org/macros/latex/contrib/hyperref.zip"
  [puenc.def]="https://mirrors.ctan.org/macros/latex/contrib/hyperref.zip"
  [xcolor.sty]="https://mirrors.ctan.org/macros/latex/contrib/xcolor.zip"
)

find_archive_entry() {
  local archive="$1"
  local name="$2"
  local stem="${name%.*}"
  local ext=".${name##*.}"

  unzip -Z1 "$archive" | awk -v name="$name" -v stem="$stem" -v ext="$ext" '
    {
      entry = $0
      base = entry
      sub(/^.*\//, "", base)
      if (base == name) {
        exact = entry
      } else if (base ~ ("^" stem "-[0-9]{4}-[0-9]{2}-[0-9]{2}" ext "$")) {
        versioned = entry
      }
    }
    END {
      if (exact != "") {
        print exact
      } else if (versioned != "") {
        print versioned
      }
    }
  '
}

build_archive_generated_asset() {
  local archive="$1"
  local name="$2"
  local stem="${name%.*}"
  local workdir
  workdir="$(mktemp -d /tmp/ctan-archive.XXXXXX)"

  unzip -q "$archive" -d "$workdir"

  while IFS= read -r ins; do
    (
      cd "$(dirname "$ins")"
      latex -interaction=nonstopmode "$(basename "$ins")" >/dev/null 2>&1
    ) || true
  done < <(find "$workdir" -type f -name '*.ins' | sort)

  local built
  built="$(find "$workdir" -type f -name "$name" | sort | tail -n 1 || true)"
  if [[ -z "$built" ]]; then
    local dtx
    dtx="$(find "$workdir" -type f -name "${stem}.dtx" | sort | tail -n 1 || true)"
    if [[ -n "$dtx" ]]; then
      (
        cd "$(dirname "$dtx")"
        tex "$(basename "$dtx")" >/dev/null 2>&1
      ) || true
      built="$(find "$workdir" -type f -name "$name" | sort | tail -n 1 || true)"
    fi
  fi

  if [[ -n "$built" ]] && gzip -nc "$built" > "$TEX_FILES_DIR/$name.gz"; then
    echo "synced tex asset from generated CTAN source: $name"
    rm -rf "$workdir"
    return 0
  fi

  rm -rf "$workdir"
  return 1
}

sync_archive_asset() {
  local name="$1"
  local archive="${CTAN_ARCHIVE_FALLBACKS[$name]:-}"
  if [[ -z "$archive" ]]; then
    return 1
  fi

  local tmp
  tmp="$(mktemp /tmp/ctan-archive.XXXXXX.zip)"
  if ! curl -fsSL "$archive" -o "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  local entry=""
  entry="$(find_archive_entry "$tmp" "$name")"
  if [[ -n "$entry" ]] && unzip -p "$tmp" "$entry" | gzip -nc > "$TEX_FILES_DIR/$name.gz"; then
    echo "synced tex asset from CTAN archive: $name"
    rm -f "$tmp"
    return 0
  fi

  if build_archive_generated_asset "$tmp" "$name"; then
    rm -f "$tmp"
    return 0
  fi

  rm -f "$tmp" "$TEX_FILES_DIR/$name.gz"
  return 1
}

sync_gzip_asset() {
  local name="$1"
  local source
  source="$(kpsewhich "$name" || true)"
  if [[ -z "$source" ]]; then
    local fallback="${CTAN_FALLBACKS[$name]:-}"
    if [[ -n "$fallback" ]]; then
      if curl -fsSL "$fallback" | gzip -nc > "$TEX_FILES_DIR/$name.gz"; then
        echo "synced tex asset from CTAN: $name"
        return 0
      fi
      rm -f "$TEX_FILES_DIR/$name.gz"
    fi

    if sync_archive_asset "$name"; then
      return 0
    fi

    echo "skip missing tex asset: $name" >&2
    return 0
  fi

  gzip -nc "$source" > "$TEX_FILES_DIR/$name.gz"
  echo "synced tex asset: $name"
}

sync_tfm_directory() {
  local probe="$1"
  local source
  source="$(kpsewhich "$probe" || true)"
  if [[ -z "$source" ]]; then
    echo "skip missing tfm probe: $probe" >&2
    return 0
  fi

  local source_dir
  source_dir="$(dirname "$source")"
  find "$source_dir" -maxdepth 1 -name '*.tfm' -exec cp {} "$TFM_DIR/" \;
  echo "synced tfm directory: $source_dir"
}

TEX_ASSETS=(
  amsthm.sty
  atbegshi.sty
  atbegshi-ltx.sty
  atveryend-ltx.sty
  auxhook.sty
  bigintcalc.sty
  bitset.sty
  bm.sty
  booktabs.sty
  cite.sty
  color.cfg
  color.sty
  dvips.def
  enumitem.sty
  geometry.sty
  gettitlestring.sty
  graphics.cfg
  graphics.sty
  graphicx.sty
  hdvips.def
  hopatch.sty
  hyperref.sty
  hycolor.sty
  iftex.sty
  ifvtex.sty
  infwarerr.sty
  intcalc.sty
  keyval.sty
  kvdefinekeys.sty
  kvoptions.sty
  kvsetkeys.sty
  letltxmacro.sty
  lettrine.sty
  ltxcmds.sty
  mathrsfs.sty
  mhsetup.sty
  mathtools.sty
  microtype.sty
  nameref.sty
  pdfescape.sty
  pdftexcmds.sty
  pd1enc.def
  puenc.def
  pdfmark.def
  refcount.sty
  rerunfilecheck.sty
  size10.clo
  size11.clo
  size12.clo
  trig.sty
  uniquecounter.sty
  url.sty
  xcolor.sty
)

for asset in "${TEX_ASSETS[@]}"; do
  sync_gzip_asset "$asset"
done

sync_tfm_directory cmr10.tfm
sync_tfm_directory msam10.tfm
sync_tfm_directory cmbsy5.tfm
