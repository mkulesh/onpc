[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/mkulesh/onpc.svg?branch=master)](https://travis-ci.org/mkulesh/onpc)
![Build Status](https://img.shields.io/github/v/release/mkulesh/onpc)
[![Download unsigned APK](https://img.shields.io/badge/APK-autobuild-blue.svg)](https://github.com/mkulesh/onpc/raw/autobuild/autobuild/onpc-v1.24-debug.apk)

# <img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48"> Enhanced Controller for Onkyo and Pioneer

*Enhanced controller for Onkyo/Pioneer devices: listen to music properly!*

This app allows remote control of an Onkyo/Pioneer/Integra Network Player or a Network A/V Receiver via the "Integra Serial Communication Protocol". Some TEAC models like Teac NT-503 are also supported.

*Free Version*

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc)
[<img src="https://gitlab.com/fdroid/artwork/raw/master/badge/get-it-on.png"
      alt="Get it on F-Droid" height="110">](https://f-droid.org/packages/com.mkulesh.onpc)

*Premium Version*

This premium version is developed with Flutter, see [onpc-flutter branch for source code](https://github.com/mkulesh/onpc/tree/onpc-flutter)

The "Premium" version implements exactly the same receiver control functionality as the free version, but has a more flexible user interface.
It allows you to reorder the play queue using drag-and-drop, change the font and buttons size, and show/hide/reorder all control elements for all tabs.
Android version also allows to create a home screen widget that shows all shortcuts. 

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus)
[<img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_app_store.png"
      alt="Download on the App Store" height="110">](https://apps.apple.com/app/id1490166845)

Do you want try the last version in development?
- [TestFlight on iPhone or iPad](https://testflight.apple.com/join/oV5j2iMh)
- <img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_windows10.png" align="center" height="48" width="48"> [Windows 10](https://github.com/mkulesh/onpc/tree/autobuild/release)
- <img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_macos.png" align="center" height="48" width="48"> [macOS (Catalina, Big Sur)](https://github.com/mkulesh/onpc/tree/autobuild/release)
- <img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_linux.png" align="center" height="48" width="48"> [Linux (Fedora Workstation)](https://github.com/mkulesh/onpc/tree/autobuild/release)
 
The two most popular features of the app are music playback and sound profile management. Other benefits include:
- Maximum privacy: No ads, no trackers, no telemetry, no special permissions like GPS
- The modern Material design supports different color themes and works on smartphones and/or tablets in portrait and landscape mode
- One-click access to music playback actions
- One-click access to media items using shortcuts
- Full music playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Full tone control (listening modes, bass, center, treble and subwoofer levels)
- Enhanced Play Queue support (add, replace, remove, remove all, change playback order)
- TuneIn Radio, Deezer, and Tidal streaming (if supported by receiver)
- DAB / FM / AM (if supported by receiver)
- Multi-zone support (if supported by receiver)
- Multi-room support: Allows control of groups of devices attached via FlareConnect (like Wireless Audio System NCP-302)
- Ability to control FlareConnect without WiFi
- Control of devices attached via RI
- Display device details and control device settings such as dimmer level, digital filter, auto power, and sleep timer
- Allows control of receivers over an OpenVPN connection (even over a cellular connection)
- Integration with "Tasker"

## Known Limitations
- Please note that the app does not support the music streaming from your phone to the network player or the receiver
- Track time seek is missing in Tidal (that is a limitation of the Onkyo firmware)
- In order to use Spotify, you need the official Spotify app additionally to this app
- Amazon Music HD subscription: broadcast in AAC 256 kbps only (that is a limitation of the Onkyo firmware)
- Following Pioneer models are NOT supported: VSX-529, VSX-830, VSX-923, VSX-924, VSX-1021, VSX-1121, SC-95, N-50, N-50a, N-70A

## Supported devices
This list is based on the user feedback from Google Play and github. Not all from these devices are tested by developer:
### Onkyo
- [ONKYO TX-L50](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-l50/index.html)
- [ONKYO TX-NR414](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr414/index.html)
- [ONKYO TX-NR509](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr509/index.html)
- [ONKYO TX-NR525](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr525/index.html)
- [ONKYO TX-NR575E](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr575e/index.html)
- [ONKYO TX-NR616](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr616/index.html)
- [ONKYO TX-NR636](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr636/index.html)
- [ONKYO TX-NR646](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr646/index.html)
- [ONKYO TX-NR656](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr656/index.html)
- [ONKYO TX-NR676E](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr676e/index.html)
- [ONKYO TX-NR686](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr686/index.html)
- [ONKYO TX-RZ810](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz810/index.html)
- [ONKYO TX-RZ830](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz830/index.html)
- [ONKYO TX-RZ900](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz900/index.html)
- [ONKYO TX-RZ1100](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz1100/index.html)
- [ONKYO HT-S7805](https://www.intl.onkyo.com/products/system_components/home_theater/ht-s7805/index.html)
- [ONKYO NS-6130](https://www.intl.onkyo.com/products/hi-fi_components/network_audio_players/ns-6130/index.html)
- [ONKYO NS-6170](https://www.intl.onkyo.com/products/hi-fi_components/network_audio_players/ns-6170/index.html)
- [ONKYO TX-8130](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8130/index.html)
- [ONKYO TX-8150](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8150/index.html)
- [ONKYO TX-8250](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8250/index.html)
- [ONKYO TX-8270](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8270/index.html)
- [ONKYO TX-8390](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8390/index.html)
- [ONKYO TX-L20D](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-l20d/index.html )
- [ONKYO R-N855](https://www.intl.onkyo.com/products/hi-fi_components/compact_hi-fi/r-n855/index.html)
- [ONKYO CS-N575D](https://www.intl.onkyo.com/products/system_components/mini_systems/cs-n575d/index.html)
- [ONKYO CR-N765](https://www.intl.onkyo.com/products/system_components/mini_systems/cr-n765/index.html)
- [ONKYO CR-N775D](https://www.intl.onkyo.com/products/system_components/mini_systems/cr-n775d/index.html)
- [Wireless Audio System NCP-302](https://www.intl.onkyo.com/products/speakers/wireless_audio_systems/ncp-302/index.html)
### Integra
- [Integra DTM-6](http://www.integrahometheater.com/Products/model.php?m=DTM-6&class=Receiver&source=prodClass)
- [Integra DRX-5.2](http://www.integrahometheater.com/Products/model.php?m=DRX-5.2&class=Receiver&source=prodClass)
- [Integra DTR 30.7](http://www.integrahometheater.com/Products/model.php?m=DTR-30.7&class=Receiver&source=prodClass)
- [Integra DTR 40.7](http://www.integrahometheater.com/Products/model.php?m=DTR-40.7&class=Receiver&source=prodClass)
### Pioneer
- [Pioneer VSX-LX303](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx303)
- [Pioneer VSX-LX503](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx503)
- [Pioneer VSX-LX504](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx504)
- [Pioneer VSX-832](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-832)
- [Pioneer VSX-932](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-932)
- [Pioneer VSX-933](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-933)
- [Pioneer SC-LX701](https://intl.pioneer-audiovisual.com/products/av_receiver/sc-lx701)
- [Pioneer NC-50DAB](https://intl.pioneer-audiovisual.com/products/2ch_components/nc-50dab/)
- [Pioneer N-70AE](https://intl.pioneer-audiovisual.com/products/2ch_components/n-70ae)
- [Pioneer XC-HM86D](https://intl.pioneer-audiovisual.com/products/system_components/xc-hm86d)
- [Pioneer MRX-3](https://intl.pioneer-audiovisual.com/products/system_components/mrx-3/)
- [Pioneer MRX-5](https://intl.pioneer-audiovisual.com/products/system_components/mrx-5/)
### Teac
- [Teac NT-503](http://audio.teac.com/product/nt-503)
- [Teac AG-D500](https://www.teac-audio.eu/en/products/ag-d500-87821.html)

## Screenshots
* Playback screen in landscape orientation, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/listen.png" align="center">

* Audio control in portrait orientation, Light theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/audio_control.png" align="center" height="800">

* Media screen, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/media.png" align="center" height="800">

For more screenshots, see directory images/screenshots.

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in 'doc' directory.

## Publications:

* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985)
* [Logo design for Enhanced Controller](https://steemit.com/utopian-io/@tebriz/logo-design-for-open-music-controller)
* [Первое универсальное приложение «Enhanced Controller for Onkyo and Pioneer»(in Russian)](https://stereo.ru/to/b0erb-pervoe-universalnoe-prilozhenie-enhanced-controller-for-onkyo-and-pioneer)

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com
* DragSortListView (drag-and-drop reordering of list items): https://github.com/bauerca/drag-sort-listview

## Acknowledgement
* Thank to [Tebriz](https://github.com/tebriz159) for Logo design
* Thank to [mrlad](https://github.com/mrlad), [onschedule](https://github.com/onschedule) for testing and improvements ideas
* Thank to [Michael](https://github.com/quelbs) for German translation and code contribution
* Thank to [John Orr](https://github.com/qpkorr) for improvements ideas and code contribution
* Thank to Andrzej Chabrzyk for Polish translation

## License

This software is published under the *GNU General Public License, Version 3*

Copyright © 2018-2021 by Mikhail Kulesh, Alexander Gomanyuk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have
received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).



