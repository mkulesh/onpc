#!/bin/bash

NAME1=${1%.svg}_cleaned.svg
echo cleaning $1 to ${NAME1}
../../../images/svgcleaner/svgcleaner $1 ${NAME1}
rm -f $1
mv ${NAME1} $1