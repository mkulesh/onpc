#!/bin/bash

INK=/Applications/Inkscape.app/Contents/MacOS/inkscape

if [[ -z "$1" ]]
then
 echo "SVG file needed."
 exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"

OUT=../../ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Notification icon size
$INK -D --export-type=png -o "$OUT$BASE-20x20@1x.png" $SVG -y 1.0 -w 20 -h 20
$INK -D --export-type=png -o "$OUT$BASE-20x20@2x.png" $SVG -y 1.0 -w 40 -h 40
$INK -D --export-type=png -o "$OUT$BASE-20x20@3x.png" $SVG -y 1.0 -w 60 -h 60

# Settings icon size
$INK -D --export-type=png -o "$OUT$BASE-29x29@1x.png" $SVG -y 1.0 -w 29 -h 29
$INK -D --export-type=png -o "$OUT$BASE-29x29@2x.png" $SVG -y 1.0 -w 58 -h 58
$INK -D --export-type=png -o "$OUT$BASE-29x29@3x.png" $SVG -y 1.0 -w 87 -h 87

# Spotlight icon size
$INK -D --export-type=png -o "$OUT$BASE-40x40@1x.png" $SVG -y 1.0 -w 40 -h 40
$INK -D --export-type=png -o "$OUT$BASE-40x40@2x.png" $SVG -y 1.0 -w 80 -h 80
$INK -D --export-type=png -o "$OUT$BASE-40x40@3x.png" $SVG -y 1.0 -w 120 -h 120

# iPhone
$INK -D --export-type=png -o "$OUT$BASE-60x60@2x.png" $SVG -y 1.0 -w 120 -h 120
$INK -D --export-type=png -o "$OUT$BASE-60x60@3x.png" $SVG -y 1.0 -w 180 -h 180

# iPad, iPad mini
$INK -D --export-type=png -o "$OUT$BASE-76x76@1x.png" $SVG -y 1.0 -w 76 -h 76
$INK -D --export-type=png -o "$OUT$BASE-76x76@2x.png" $SVG -y 1.0 -w 152 -h 152

# iPad Pro
$INK -D --export-type=png -o "$OUT$BASE-83.5x83.5@2x.png" $SVG -y 1.0 -w 167 -h 167

#iTunes Artwork
$INK -D --export-type=png -o "$OUT$BASE-1024x1024@1x.png" $SVG -y 1.0 -w 1024 -h 1024

