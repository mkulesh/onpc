#!/bin/bash

# Function to convert a single SVG to a specific DPI/Size
convert_file() {
  local INPUT_FILE=$1
  local DPI=$2
  local SIZE=$3
  local NAME1=${INPUT_FILE%.svg}
  local CLEAN_NAME=${NAME1#./}
  local TARGET="../../android/app/src/main/res/mipmap-${DPI}/${CLEAN_NAME}.png"
  local INK=/Applications/Inkscape.app/Contents/MacOS/inkscape
  echo "Converting ${INPUT_FILE} to ${TARGET} (${SIZE}x${SIZE})"
  $INK --export-type=png -o "${TARGET}" "${INPUT_FILE}" -w "${SIZE}" -h "${SIZE}"
}

echo Converting ic_launcher
  convert_file ./ic_launcher.svg mdpi 48
  convert_file ./ic_launcher.svg hdpi 72
  convert_file ./ic_launcher.svg xhdpi 96
  convert_file ./ic_launcher.svg xxhdpi 144
  convert_file ./ic_launcher.svg xxxhdpi 192
echo Converting ic_launcher_adapt
  convert_file ./ic_launcher_adapt.svg mdpi 108
  convert_file ./ic_launcher_adapt.svg hdpi 162
  convert_file ./ic_launcher_adapt.svg xhdpi 216
  convert_file ./ic_launcher_adapt.svg xxhdpi 324
  convert_file ./ic_launcher_adapt.svg xxxhdpi 432
echo Converting ic_launcher_mono
  convert_file ./ic_launcher_mono.svg mdpi 108
  convert_file ./ic_launcher_mono.svg hdpi 162
  convert_file ./ic_launcher_mono.svg xhdpi 216
  convert_file ./ic_launcher_mono.svg xxhdpi 324
  convert_file ./ic_launcher_mono.svg xxxhdpi 432
