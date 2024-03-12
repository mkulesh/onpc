[![License](https://img.shields.io/badge/license-GNU_GPLv3-orange.svg)](https://github.com/mkulesh/onpc/blob/master/LICENSE)
![Release Status](https://img.shields.io/github/v/release/mkulesh/onpc)
[![Documentation Dashboard](https://sourcespy.com/shield.svg)](https://sourcespy.com/github/mkuleshonpc/)

<img src="https://github.com/mkulesh/onpc/blob/master/images/icon.png" align="center" height="48" width="48">

# Enhanced Music Controller 

*Enhanced AVR controller: listen to music properly!*

This app allows remote control of a Network Player or a Network A/V Receiver via the local network.
The app supports Onkyo/Pioneer/Integra released in April 2016 or later and Denon/Marantz with build-in HEOS technology.
Some TEAC models like Teac NT-503 are also supported.

The two most popular features of the app are music playback and sound profile management. Other benefits include:
- Maximum privacy: No ads, no trackers, no telemetry, no special permissions like GPS
- The modern Material design supports different color themes and works on smartphones and/or tablets in portrait and landscape mode
- One-click access to music playback actions
- One-click access to media items using shortcuts for Onkyo or Favourites for Denon
- Full music playback control (play, stop, pause, track up/down, time seek, repeat and random modes)
- Full tone control (listening modes, bass, center, treble and subwoofer levels)
- Enhanced Play Queue support (add, replace, remove, remove all, change playback order)
- TuneIn Radio, Deezer, Spotify and Tidal streaming (if supported by receiver)
- DAB / FM / AM (if supported by receiver)
- Multi-zone support (if supported by receiver)
- Multi-room support: Allows control of groups of devices attached via FlareConnect (for Onkyo/Pioneer/Integra only). Ability to control FlareConnect without WiFi
- Control of devices attached via RI (for Onkyo/Pioneer/Integra only)
- Display device details and control device settings such as dimmer level, digital filter, auto power, and sleep timer
- Allows control of receivers over an OpenVPN connection (even over a cellular connection)
- Integration with "Tasker"

## Versions

*Free Android Version (Enhanced Music Controller Lite)*

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc)
      
[<img src="https://gitlab.com/fdroid/artwork/raw/master/badge/get-it-on.png"
      alt="Get it on F-Droid" height="110">](https://f-droid.org/packages/com.mkulesh.onpc)

*Premium Version*

This premium version is developed with Flutter, see [onpc-flutter branch for source code](https://github.com/mkulesh/onpc/tree/onpc-flutter)

This "Premium" version implements exactly the same receiver control functionality as the free version, but has some additional features:
- It is available for all desktop systems (Linux, Windows, macOS).
- The Windows version allows to define global shortcuts for volume and playback control.
- It allows to rename input channels when this feature is not supported in the firmware.
- It allows to reorder the play queue using drag-and-drop, change the font and buttons size and show/hide/reorder all control elements for all tabs.
- Android version allows to create home screen widgets.

On Android:

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play" height="110">](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus)
      
On Mac, iPhone, iPad: 

[<img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_app_store.png"
      alt="Download on the App Store" height="110">](https://apps.apple.com/app/id1490166845)

On Windows: 

[<img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_windows_store.png"
      alt="Download on Windows Store" height="110">](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

Do you want try the last version in development?
- [TestFlight on iPhone or iPad](https://testflight.apple.com/join/oV5j2iMh)
- <img src="https://github.com/mkulesh/onpc/blob/master/images/badges/badge_linux.png" align="center" height="48" width="48"> [Linux (Fedora Workstation)](https://1drv.ms/u/s!At2sh2-YDyGFgTY827qdnu3VsmjC?e=FPjUeB)

## Known Limitations
- Please note that the app does not support the music streaming from your phone to the network player or the receiver
- In order to login into Deezer, Tidal, or Spotify, you need the official Onkyo/Denon app additionally to this app
- Pioneer models before year 2016 are NOT supported, for example: VSX-424, VSX-529, VSX-830, VSX-920K, VSX-923, VSX-924, VSX-1021, VSX-1121, SC-95, SC-LX79, N-50, N-50a, N-70A
- Following Denon models are not supported: AVR-X1000, DNP-730AE, Heos Link 2
- Following models do not support "Play Queue" feature (that is a limitation of the Onkyo firmware): CR-N765, DTR-40.5, HM76, HT-R693, HT-R695, TX-8130, TX-8150, TX-NR626, TX-NR636, TX-NR646, TX-RZ900

## Supported devices
This list is based on the user feedback from Google Play and github. Not all from these devices are tested by developer:
### Onkyo
- [ONKYO TX-L20D](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-l20d/index.html)
- [ONKYO TX-L50](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-l50/index.html)
- [ONKYO TX-NR414](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr414/index.html)
- [ONKYO TX-NR509](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr509/index.html)
- [ONKYO TX-NR525](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr525/index.html)
- [ONKYO TX-NR535](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr535/index.html)
- [ONKYO TX-NR575E](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr575e/index.html)
- [ONKYO TX-NR616](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr616/index.html)
- [ONKYO TX-NR636](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr636/index.html)
- [ONKYO TX-NR646](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr646/index.html)
- [ONKYO TX-NR656](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr656/index.html)
- [ONKYO TX-NR676E](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr676e/index.html)
- [ONKYO TX-NR686](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr686/index.html)
- [ONKYO TX-NR696](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr696/index.html)
- [ONKYO TX-NR818](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-nr818/index.html)
- [ONKYO TX-RZ50](https://www.onkyousa.com/product/tx-rz50-9-2-channel-thx-certified-av-receiver)
- [ONKYO TX-RZ70](https://emea.onkyo-av.com/receivers/av-receivers/tx-rz70)
- [ONKYO TX-RZ810](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz810/index.html)
- [ONKYO TX-RZ830](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz830/index.html)
- [ONKYO TX-RZ900](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz900/index.html)
- [ONKYO TX-RZ1100](https://www.intl.onkyo.com/products/av_components/av_receivers/tx-rz1100/index.html)
- [ONKYO TX-8130](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8130/index.html)
- [ONKYO TX-8150](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8150/index.html)
- [ONKYO TX-8250](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8250/index.html)
- [ONKYO TX-8270](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8270/index.html)
- [ONKYO TX-8390](https://www.intl.onkyo.com/products/hi-fi_components/receivers/tx-8390/index.html)
- [ONKYO R-N855](https://www.intl.onkyo.com/products/hi-fi_components/compact_hi-fi/r-n855/index.html)
- [ONKYO CS-N575D](https://www.intl.onkyo.com/products/system_components/mini_systems/cs-n575d/index.html)
- [ONKYO CR-N755](https://www.intl.onkyo.com/products/system_components/mini_systems/cr-n755/index.html)
- [ONKYO CR-N765](https://www.intl.onkyo.com/products/system_components/mini_systems/cr-n765/index.html)
- [ONKYO CR-N775D](https://www.intl.onkyo.com/products/system_components/mini_systems/cr-n775d/index.html)
- [ONKYO HT-S7805](https://www.intl.onkyo.com/products/system_components/home_theater/ht-s7805/index.html)
- [ONKYO NS-6130](https://www.intl.onkyo.com/products/hi-fi_components/network_audio_players/ns-6130/index.html)
- [ONKYO NS-6170](https://www.intl.onkyo.com/products/hi-fi_components/network_audio_players/ns-6170/index.html)
- [Wireless Audio System NCP-302](https://www.intl.onkyo.com/products/speakers/wireless_audio_systems/ncp-302/index.html)
### Integra
- [Integra DTM-6](http://www.integrahometheater.com/Products/model.php?m=DTM-6&class=Receiver&source=prodClass)
- [Integra DRX-5.2](http://www.integrahometheater.com/Products/model.php?m=DRX-5.2&class=Receiver&source=prodClass)
- [Integra DTR 30.7](http://www.integrahometheater.com/Products/model.php?m=DTR-30.7&class=Receiver&source=prodClass)
- [Integra DTR 40.7](http://www.integrahometheater.com/Products/model.php?m=DTR-40.7&class=Receiver&source=prodClass)
### Pioneer (models after 2016)
- [Pioneer VSX-LX101](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx101)
- [Pioneer VSX-LX103](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx103)
- [Pioneer VSX-LX104](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx104)
- [Pioneer VSX-LX302](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx302)
- [Pioneer VSX-LX303](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx303)
- [Pioneer VSX-LX503](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx503)
- [Pioneer VSX-LX504](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-lx504)
- [Pioneer VSX-S520D](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-s520d)
- [Pioneer VSX-832](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-832)
- [Pioneer VSX-932](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-932)
- [Pioneer VSX-933](https://intl.pioneer-audiovisual.com/products/av_receiver/vsx-933)
- [Pioneer SC-LX701](https://intl.pioneer-audiovisual.com/products/av_receiver/sc-lx701)
- [Pioneer SC-LX901](https://intl.pioneer-audiovisual.com/products/av_receiver/sc-lx901)
- [Pioneer SX-N30](https://intl.pioneer-audiovisual.com/products/2ch_components/sx-n30)
- [Pioneer SX-S30DAB](https://intl.pioneer-audiovisual.com/products/2ch_components/sx-s30dab)
- [Pioneer NC-50DAB](https://intl.pioneer-audiovisual.com/products/2ch_components/nc-50dab/)
- [Pioneer N-50AE](https://intl.pioneer-audiovisual.com/products/2ch_components/n-50ae)
- [Pioneer N-70AE](https://intl.pioneer-audiovisual.com/products/2ch_components/n-70ae)
- [Pioneer XC-HM86D](https://intl.pioneer-audiovisual.com/products/system_components/xc-hm86d)
- [Pioneer MRX-3](https://intl.pioneer-audiovisual.com/products/system_components/mrx-3/)
- [Pioneer MRX-5](https://intl.pioneer-audiovisual.com/products/system_components/mrx-5/)
### Teac
- [Teac NT-503](http://audio.teac.com/product/nt-503)
- [Teac AG-D500](https://www.teac-audio.eu/en/products/ag-d500-87821.html)
### Denon with build-in HEOS
- [Denon DRA-800H](https://www.denon.com/de-ch/shop/avreceiver/dra800h)
- [Denon AVR-S750H](https://www.denon.com/de-ch/shop/avreceiver/avrs750h)
- [Denon AVR-S760H](https://www.denon.com/de-de/product/av-receivers/avr-s760h/AVRS760H.html)
- [Denon AVR-X2400H](https://www.denon.com/de-ch/shop/avreceiver/avrx2400h)
- [Denon AVR-X2600H](https://www.denon.com/de-ch/shop/avreceiver/avrx2600h)
- [Denon AVR-X2800H](https://www.denon.com/de-ch/shop/avreceiver/avrx2800h)
- [Denon AVR-X3700H](https://www.denon.com/de-ch/shop/avreceiver/avcx3700h)
- [Denon AVR-X3800H](https://www.denon.com/de-ch/shop/avreceiver/avcx3800h)
- [Denon AVR-X4300H](https://www.denon.com/de-de/product/archive-av-receivers/avr-x4300h/800218.html)
- [Denon AVR-X4500H](https://www.denon.com/de-ch/shop/avreceiver/avrx4500h)
- [Denon AVR-X6300H](https://www.denon.com/de-ch/shop/avreceiver/avrx6300h)
### Marantz with build-in HEOS
- [Marantz NR1200](https://www.marantz.com/de-de/product/av-receivers/nr1200)
- [Marantz NR1510](https://www.marantz.com/de-de/product/av-receivers/nr1510)
- [Marantz NR1711](https://www.marantz.com/de-de/product/av-receivers/nr1711)
- [Marantz SR5015](https://www.marantz.com/de-de/product/av-receivers/sr5015)
- [Marantz SR6015](https://www.marantz.com/de-de/product/av-receivers/sr6015)

## Documentation
Documents from Onkyo describing the protocol, including lists of supported commands, are stored in 'doc' directory.

## Publications:
* [Протокол ISCP/eISCP от Onkyo: управление устройствами Onkyo по сети (in Russian)](https://habr.com/post/427985)
* [Logo design for Open Music Controller](https://steemit.com/utopian-io/@tebriz/logo-design-for-open-music-controller)
* [Первое универсальное приложение «Enhanced Controller for Onkyo and Pioneer»(in Russian)](https://stereo.ru/to/b0erb-pervoe-universalnoe-prilozhenie-enhanced-controller-for-onkyo-and-pioneer)

## Acknowledgement
* Thank to [Tebriz](https://github.com/tebriz159) for Logo design
* Thank to [mrlad](https://github.com/mrlad), [onschedule](https://github.com/onschedule) for testing and improvements ideas
* Thank to [Michael](https://github.com/quelbs) for German translation and code contribution
* Thank to [John Orr](https://github.com/qpkorr) for improvements ideas and code contribution
* Thank to Andrzej Chabrzyk for Polish translation

## License
This software is published under the *GNU General Public License, Version 3*

Copyright © 2018-2023 by Mikhail Kulesh, Alexander Gomanyuk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have
received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses).

## Used Open Source Libraries
* Material Design Icons: http://materialdesignicons.com
* Material Design Palette: https://www.materialpalette.com
* DragSortListView (drag-and-drop reordering of list items): https://github.com/bauerca/drag-sort-listview

## Screenshots
* Playback screen in landscape orientation, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/listen.png" align="center">

* Audio control in portrait orientation, Light theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/audio_control.png" align="center" height="800">

* Media screen, Dark theme
<img src="https://github.com/mkulesh/onpc/blob/master/images/screenshots/android-phone/media.png" align="center" height="800">

For more screenshots, see directory images/screenshots.
