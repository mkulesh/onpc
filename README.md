[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/mkulesh/onpc.svg?branch=master)](https://travis-ci.org/mkulesh/onpc) 
[![Download unsigned APK](https://img.shields.io/badge/APK-autobuild-blue.svg)](https://github.com/mkulesh/onpc/raw/autobuild/autobuild/onpc-v1.0.apk)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> "Onkyo Network Player Remote Control"

This app allows to remote control Onkyo Network Player or a Network A/V Receiver like over the 
network using "Integra Serial Communication Protocol". The app is primary invented to music control:
navigation in the media library, playback control and sound tuning.

## Benefits and features
- The modern material design that supports different color themes and works on smartphone or tablet in portrait and landscape mode
- Access to all functions with minimal number of clicks
- Full playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Control Onkyo amplifier if attached to the player using RI interface (muting, volume, input selector)
- Select the media to be played, full support of Tuneln Radio and Deezer
- Play queue support (add, remove, clear, change the order of tracks)
- Show information about the device and control some device settings (dimmer level, digital filter, auto power)
- The app only needs network permission in order to communicate with target device

## Supported devices
Currently, this app is only tested with following devices:
- [ONKYO NS-6130](https://www.eu.onkyo.com/en/products/ns-6130-132943.html) (Firmware versions 2110-0000-0000-0010-0000, 2120-1000-0000-0010-0000, ...)
![NS-6130](https://github.com/mkulesh/onpc/blob/master/images/ns_6130.png)
- [ONKYO TX-NR676E](https://www.eu.onkyo.com/en/products/tx-nr676e-138719.html) (Firmware version 1091-1020-3050-0010-0000)
![TX-NR676E](https://github.com/mkulesh/onpc/blob/master/images/tx_nr676e.png)

## Screenshots
* Playback screen in landscape orientation, Light (Teal and Deep Orange) theme
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

## License

This software is published under the *GNU General Public License, Version 3*

Copyright © 2018 by Mikhail Kulesh, Alexander Gomanuke

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com
