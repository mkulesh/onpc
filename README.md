[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Download unsigned APK](https://img.shields.io/badge/APK-1.0beta-blue.svg)](https://github.com/mkulesh/onpc/raw/master/release/onpc-1.0.apk)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> "Onkyo Network Player Remote Control"

This app allows to remote control Onkyo Network Player like [ONKYO NS-6130](https://www.eu.onkyo.com/en/products/ns-6130-132943.html) over the network using "Integra Serial Communication Protocol". The following features are currently implemented:
- Full playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Control Onkyo amplifier if it is attached to the player using RI interface
- Select the media to be played, full support of Tuneln Radio and Deezer
- Play queue support (add, remove, clear, change the order of tracks)
- Show information about the device and control some device settings (dimmer level, digital filter, auto power)
- Support of different color themes, working on smartphone or tablet in portrait and landscape mode
- The app only needs network permission in order to communicate with target device

## Supported devices
Currently, this app is only tested with ONKYO NS-6130 (Firmware version 2110-0000-0000-0010-0000, 2120-1000-0000-0010-0000, ...):

![NS-6130](https://github.com/mkulesh/onpc/blob/master/images/ns_6130.png)

## Screenshots
* Playback screen in landscape orientation, Light (Teal and Deep Orange) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/playback_horizontal.png" align="center" width="800">

* Playback screen in portrait orientation, Strong Dark (Black and Lime) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/playback_vertical.png" align="center" height="800">

* Media list screen, Dark (Dim Gray and Cyan) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/madia_list.png" align="center" height="800">

* Device info screen, Light (Indigo and Orange) theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/device_info.png" align="center" height="800">

For more screenshots, see directory images/screenshots.

## Limitations
Some network services like Spotify, Tidal, AirPlay are currently not yet testet and may not work.

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in this repository on in 'doc' directory.

## Publications:

* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985/)

## License

This software is published under the *GNU General Public License, Version 3*

Copyright (C) 2014-2018 Mikhail Kulesh

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com/
