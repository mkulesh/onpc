[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/mkulesh/onpc.svg?branch=master)](https://travis-ci.org/mkulesh/onpc) 
[![Download unsigned APK](https://img.shields.io/badge/APK-autobuild-blue.svg)](https://github.com/mkulesh/onpc/raw/autobuild/autobuild/onpc-v0.7.apk)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> Open Music Controller for Onkyo

*Remote controller for Onkyo devices: listen music properly*

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc)

This app allows to remotely control Onkyo Network Player or a Network A/V Receiver over the home network by means of
"Integra Serial Communication Protocol". The app is primary aimed to get a control over music playback and sound profiles.

## Benefits and features
- One-click access to music playback actions
- The modern material design supports different color themes and works on smartphone or tablet in portrait and landscape mode
- Full music playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Full support of Tuneln Radio and Deezer
- Control of devices attached vie RI
- Play queue support (add, remove, clear, change playback order)
- Show information about the device and control some device settings (dimmer level, digital filter, auto power)
- App doesn't need any special permissions

## Supported devices
Currently, this app is only tested with following devices:
- [ONKYO NS-6130](https://www.eu.onkyo.com/en/products/ns-6130-132943.html) (Firmware versions 2110-0000-0000-0010-0000, 2120-1000-0000-0010-0000, ...)
![NS-6130](https://github.com/mkulesh/onpc/blob/master/images/ns_6130.png)
- [ONKYO TX-NR676E](https://www.eu.onkyo.com/en/products/tx-nr676e-138719.html) (Firmware version 1091-1020-3050-0010-0000)
![TX-NR676E](https://github.com/mkulesh/onpc/blob/master/images/tx_nr676e.png)

## Screenshots
* Playback screen in landscape orientation, Dark (Dim Gray and Cyan) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_playback_hor.png" align="center" width="800">

* Playback screen in portrait orientation, Strong Dark (Black and Lime) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_playback_vert.png" align="center" height="800">

* Media list screen, Dark (Dim Gray and Yellow) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/tablet_tx_nr676_media_hor.png" align="center" height="800">

* Device info screen, Light (Indigo and Orange) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_device_vert.png" align="center" height="800">

For more screenshots, see directory images/screenshots.

## Limitations
Some network services like Spotify, Tidal, AirPlay are currently not yet tested and may not work.

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in this repository on in 'doc' directory.

## Publications:

* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985/)

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com

## Acknowledgement
* Thank to [Tebriz](https://github.com/tebriz159) for Logo design

## License

This software is published under the *GNU General Public License, Version 3*

Copyright © 2018 by Mikhail Kulesh, Alexander Gomanyuk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have
received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).