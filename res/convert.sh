#!/bin/sh

cp strings.xml ../android/app/src/main/res/values/strings.xml
cp strings_de.xml ../android/app/src/main/res/values-de/strings.xml
cp strings_fr.xml ../android/app/src/main/res/values-fr/strings.xml
cp strings_pl.xml ../android/app/src/main/res/values-pl/strings.xml
cp strings_ru.xml ../android/app/src/main/res/values-ru/strings.xml

dart xml2strings.dart --input strings.xml --output ../lib/constants/Strings.dart

