#!/bin/bash

INK=/Applications/Inkscape.app/Contents/MacOS/inkscape

if [[ -z "$1" ]]
then
 echo "SVG file needed."
 exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"

OUT=../../macos/Runner/Assets.xcassets/AppIcon.appiconset/

$INK --export-type=png -o "$OUT/app_icon_16.png" $SVG   -w 16 -h 16
$INK --export-type=png -o "$OUT/app_icon_32.png" $SVG   -w 32 -h 32
$INK --export-type=png -o "$OUT/app_icon_64.png" $SVG   -w 64 -h 64
$INK --export-type=png -o "$OUT/app_icon_128.png" $SVG  -w 128 -h 128
$INK --export-type=png -o "$OUT/app_icon_256.png" $SVG  -w 256 -h 256
$INK --export-type=png -o "$OUT/app_icon_512.png" $SVG  -w 512 -h 512
$INK --export-type=png -o "$OUT/app_icon_1024.png" $SVG -w 1024 -h 1024
