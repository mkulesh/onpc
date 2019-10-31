[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Flutter Logo](https://github.com/mkulesh/onpc/blob/onpc-flutter/images/flutter-logo.png)](https://flutter.dev)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> Enhanced Controller for Onkyo and Pioneer

*Enhanced controller for Onkyo/Pioneer devices: listen to music properly!*

This app allows remote control of an Onkyo/Pioneer/Integra Network Player or a Network A/V Receiver via the
"Integra Serial Communication Protocol". Its two most popular features are music playback and sound profile management. Other benefits include:
- Maximum privacy: No ads, no trackers, no telemetry, no special permissions like GPS
- One-click access to music playback actions
- Full music playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Full tone control (bass, center, treble and subwoofer levels)
- The modern material design supports different color themes and works on smartphones and/or tablets in portrait and landscape mode
- Tuneln Radio and Deezer streaming (if supported by receiver)
- DAB / FM (if supported by receiver)
- Multi-zone support (if supported by receiver)
- Multi-room support: Allows control groups of devices attached via FlareConnect (like Wireless Audio System NCP-302)
- Control of devices attached via RI
- Enhanced Play Queue support (add, replace, remove, clear, change playback order)
- Display device details and control device settings such as dimmer level, digital filter, auto power
- Allows control of receivers over an OpenVPN connection (even over a cellular connection)

## Supported devices
Currently, this app is only tested with following devices:
- [ONKYO NS-6130](https://www.eu.onkyo.com/en/products/ns-6130-132943.html) 
- [ONKYO TX-NR676E](https://www.eu.onkyo.com/en/products/tx-nr676e-138719.html)
- [ONKYO TX-NR686](https://www.eu.onkyo.com/en/products/tx-nr686-148905.html)
- [ONKYO TX-8150](https://www.eu.onkyo.com/en/products/tx-8150-126088.html)
- [Wireless Audio System NCP-302](https://www.eu.onkyo.com/en/products/ncp-302-137564.html)
- [Integra DRX-5.2](https://integraworldwide.com/Products/receivers/drx-5.2/)
- [Integra DTR 30.7](http://www.integrahometheater.com/Products/model.php?m=DTR-30.7&class=Receiver&source=prodClass)
- [Integra DTR 40.7](http://www.integrahometheater.com/Products/model.php?m=DTR-40.7&class=Receiver&source=prodClass)
- [Pioneer VSX-LX303](https://www.pioneerelectronics.com/PUSA/Home/AV-Receivers/Elite+Receivers/VSX-LX303)
- [Teac NT-503](http://audio.teac.com/product/nt-503)

## Limitations
Some network services like Spotify, Tidal, AirPlay are currently not yet tested and may not work.

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in this repository on in 'doc' directory.

## Publications:
* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985/)
* [Logo design for Enhanced Controller](https://steemit.com/utopian-io/@tebriz/logo-design-for-open-music-controller)

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com

## Acknowledgement
* Thank to [Tebriz](https://github.com/tebriz159) for Logo design
* Thank to [mrlad](https://github.com/mrlad), [onschedule](https://github.com/onschedule) for testing and improvements ideas
* Thank to [Michael](https://github.com/quelbs) for German translation and code contribution
* Thank to [John Orr](https://github.com/qpkorr) for improvements ideas and code contribution

## License

This software is published under the *GNU General Public License, Version 3*

Copyright © 2018-2019 by Mikhail Kulesh, Alexander Gomanyuk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have
received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).
