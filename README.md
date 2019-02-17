[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/mkulesh/onpc.svg?branch=master)](https://travis-ci.org/mkulesh/onpc) 
[![Download unsigned APK](https://img.shields.io/badge/APK-autobuild-blue.svg)](https://github.com/mkulesh/onpc/raw/autobuild/autobuild/onpc-v0.8-debug.apk)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> Open Music Controller for Onkyo

*Remote controller for Onkyo devices: listen to music properly!*

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc)

This app allows remote control of an Onkyo Network Player or a Network A/V Receiver via the
"Integra Serial Communication Protocol". Its two most popular features are music playback and sound profile management.  Other benefits include:
- Maximum privacy: No ads, no trackers, no telemetry
- One-click access to music playback actions
- Full music playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- The modern material design supports different color themes and works on smartphones and/or tablets in portrait and landscape mode
- Tuneln Radio and Deezer streaming
- Multi-zone support
- Control of devices attached via RI
- Play queue support (add, remove, clear, change playback order)
- Display device details and control device settings such as dimmer level, digital filter, auto power
- App doesn't need any special permissions
- Allows control of receivers over an OpenVPN connection (even over a cellular connection). Onkyo Controller does not have this functionality.

## Supported devices
Currently, this app is only tested with following devices:
- [ONKYO NS-6130](https://www.eu.onkyo.com/en/products/ns-6130-132943.html) 
- [ONKYO TX-NR676E](https://www.eu.onkyo.com/en/products/tx-nr676e-138719.html) 
- [Integra DRX-5.2](https://integraworldwide.com/Products/receivers/drx-5.2/)
- [Integra DTR 30.7](http://www.integrahometheater.com/Products/model.php?m=DTR-30.7&class=Receiver&source=prodClass)
- [Integra DTR 40.7](http://www.integrahometheater.com/Products/model.php?m=DTR-40.7&class=Receiver&source=prodClass)

## Screenshots
* Playback screen in landscape orientation, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_playback_hor.png" align="center">

* Playback screen in portrait orientation, Strong Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_playback_vert.png" align="center" height="800">

* Playback screen and navigation drawer in landscape orientation, 10 Inch tablet, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/tablet_ns_6130_playback_hor.png" align="center">

* Media screen (network services), Light theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/phone_ns_6130_media_top_vert.png" align="center" height="800">

For more screenshots, see directory images/screenshots.

## Limitations
Some network services like Spotify, Tidal, AirPlay are currently not yet tested and may not work.

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in this repository on in 'doc' directory.

## Publications:

* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985/)
* [Logo design for Open Music Controller](https://steemit.com/utopian-io/@tebriz/logo-design-for-open-music-controller)

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com

## Acknowledgement
* Thank to [Tebriz](https://github.com/tebriz159) for Logo design
* Thank to [mrlad](https://github.com/mrlad), [onschedule](https://github.com/onschedule) for testing and improvements ideas

## License

This software is published under the *GNU General Public License, Version 3*

Copyright © 2018-2019 by Mikhail Kulesh, Alexander Gomanyuk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have
received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).
