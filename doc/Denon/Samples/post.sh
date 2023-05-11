#!/bin/sh

echo ----- GetAllZonePowerStatus:
curl -X POST -H "Content-Type: text/xml" \
    -d '{"body": "<?xml version="1.0" encoding="utf-8"?><tx><cmd id="1">GetAllZonePowerStatus</cmd><cmd id="1">GetZoneName</cmd><cmd id="1">GetAllZoneVolume</cmd><cmd id="1">GetAllZoneSource</cmd><cmd id="1">GetAllZoneMuteStatus</cmd></tx>"}' \
    http://192.168.1.82:8080/goform/AppCommand.xml

echo ----- GetSourceRename:
curl -X POST -H "Content-Type: text/xml" \
    -d '{"body": "<?xml version="1.0" encoding="utf-8"?><tx><cmd id="3"><name>GetSourceRename</name><list/></cmd></tx>"}' \
    http://192.168.1.82:8080/goform/AppCommand0300.xml

echo ----- GetSoundMode:
curl -X POST -H "Content-Type: text/xml" \
    -d '{"body": "<?xml version="1.0" encoding="utf-8"?><tx><cmd id="3"><name>GetSoundMode</name><list><param name="movie"></param><param name="music"></param><param name="game"></param><param name="pure"></param></list></cmd></tx>"}' \
    http://192.168.1.82:8080/goform/AppCommand0300.xml

echo ----- SetTunerPresetMemory:
curl -X POST -H "Content-Type: text/xml" \
    -d '{"body": "<?xml version="1.0" encoding="utf-8"?><tx><cmd id="1">SetTunerPresetMemory</cmd><presetno>32</presetno></tx>"}' \
    http://192.168.1.82:8080/goform/AppCommand.xml

