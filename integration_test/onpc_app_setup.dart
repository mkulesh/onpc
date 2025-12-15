/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onpc/constants/Strings.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/utils/Platform.dart';

import 'onpc_test_utils.dart';

class OnpcAppSetup {
  static Future<void> initialSearch(OnpcTestUtils tu) async {
    // Device search is opened automatically
    try {
      await tu.ensureVisible(() => find.text(Strings.drawer_device_search));
      expect(find.text(Strings.drawer_device_search), findsOneWidget);
      expect(find.text(Strings.state_not_connected), findsOneWidget);
      await tu.ensureVisible(() => find.text("Onkyo Player"));
      await tu.ensureVisible(() => find.text("Onkyo Box"));
      await tu.ensureVisible(() => find.text("Denon AVR"));
    } finally {
      await tu.findAndTap(() => find.text("192.168.1.80:60128"), waitFor: true);
    }
  }

  static Future<void> aboutScreen(OnpcTestUtils tu) async {
    await tu.openDrawerMenu(Strings.drawer_about, ensureAfter: () => find.byType(Markdown));
    try {
      expect(find.textContaining("Enhanced AVR Controller"), findsOneWidget);
      expect(find.textContaining("Copyright © 2019-" + DateTime.now().year.toString() + " by Mikhail Kulesh"),
          findsOneWidget);
    } finally {
      await tu.previousScreen();
    }
  }

  static Future<void> changeAppSettings(final OnpcTestUtils tu) async {
    await tu.openDrawerMenu("Settings", ensureAfter: () => find.text("Theme"));
    try {
      await tu.changeParameter("Text and buttons size", "Small");
      await tu.changeParameter("Theme", "Light (Purple and Green)");
      await tu.changeParameter("App language", "English");

      // Audio control
      await tu.changeParameter("Sound control", "Automatic");
      await tu.changeParameter("Master volume unit", "Relative (dB)", pressOk: true, scrollTo: "Developer options");

      // RI-USB
      if (Platform.isDesktop) {
        final String USB_RI = Platform.isWindows ? "USB Serial Port" : "OnkioRI FT231X";
        await tu.changeParameter("Use USB-RI interface", USB_RI, ignoreMissing: true);
      }

      await tu.changeParameter("Album's cover click behaviour", "Audio muting");
    } finally {
      await tu.previousScreen();
    }
  }

  static Future<void> changeListenLayout(final OnpcTestUtils tu) async {
    final String s = "File information";
    await tu.openDrawerMenu("Tab layout", ensureAfter: () => find.text(s));
    await tu.dragReorderableItem(s, Offset(0, -600));
    await tu.previousScreen();
  }

  static Future<void> setupDenon(OnpcTestUtils tu) async {
    await tu.saveConnection("My Denon AVR", "192.168.1.82", isDCP: true);
    if (find.text("Denon AVR (Standby)").evaluate().isNotEmpty) {
      // Player is off - call power on
      await tu.findAndTap(() => find.byTooltip("On/Standby"));
    }
    await tu.changeInputs([
      Pair("HEOS MUSIC", "NET"),
      Pair("BLUETOOTH", "BT"),
      Pair("DVD", ""),
      Pair("Blu-ray", ""),
      Pair("TV Audio", "PC"),
      Pair("Onkyo", "ONKYO"),
      Pair("Media Player", ""),
      Pair("Game", ""),
      Pair("DRS610", "TAPE"),
      Pair("Phono", ""),
    ]);
    await tu.changeServices([
      Pair("Play List", true),
      Pair("Tidal", true),
      Pair("TuneIn Radio", true),
      Pair("Deezer", true),
      Pair("Local Music", true),
      Pair("Spotify", false),
      Pair("Amazon Music", false),
      Pair("Napster", false),
      Pair("Soundcloud", false),
      Pair("History", false),
    ]);
    await tu.changeListeningModes([
      Pair("Stereo", true),
      Pair("Auto", false),
      Pair("Dolby Digital", false),
      Pair("DTS Surround", false),
      Pair("Auro 3D", false),
      Pair("Auro 2D SURR", false),
      Pair("MCH Stereo", false),
      Pair("Wide Screen", false),
      Pair("Super Stadium", false),
      Pair("Rock Arena", false),
      Pair("Jazz Club", false),
      Pair("Classic Concert", false),
      Pair("Mono Movie", false),
      Pair("Matrix", false),
      Pair("Video Game", false),
      Pair("Virtual", false),
    ]);
    final AudioSliderParameters p = AudioSliderParameters();
    p.name = "Main:";
    p.initialValue = "0.5";
    p.initialValueStep = -65;
    p.secondValue = "30.0";
    p.secondValueStep = 59;
    p.buttonUp = "60.0";
    p.buttonUpValue = "30.5";
    p.buttonDown = "1";
    await tu.setMaxVolume(p);
    await tu.renameZone(1, "To Onkyo");
  }

  static Future<void> buildDenonFavourites(OnpcTestUtils tu) async {
    await tu.openTab("SHORTCUTS");
    if (find.text("Deezer Flow").evaluate().isEmpty) {
      await _buildDenonFavourites(tu,
          dlna: true, deezer: true, tuneIn: true, usbMusic: true, favorite: true, radio: true);
    }
  }

  static Future<void> _buildDenonFavourites(OnpcTestUtils tu,
      {required bool dlna,
      required bool deezer,
      required bool tuneIn,
      required bool usbMusic,
      required bool favorite,
      required bool radio}) async {
    await tu.openTab("MEDIA");
    await tu.findAndTap(() => find.text("NET"));

    if (dlna) {
      await tu.openTab("MEDIA");
      final Pair<String, String> ARTISTS = Pair<String, String>("Artist", "Artists on DLNA");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music", "Kontron DLNA Server", "Music"],
          ensureVisible: true);
      await tu.contextMenu(ARTISTS.item1, "Create shortcut", waitFor: true);

      final Pair<String, String> VYSOTSKY = Pair<String, String>("Цыганский романс 'Кони привередливые'", "В.Высоцкий");
      await tu.navigateToMedia([
        OnpcTestUtils.TOP_LAYER,
        "Local Music",
        "Denon AVR",
        "Genres",
        "Акустика<S>Эстрада",
        "Владимир Высоцкий",
        "Владимир Высоцкий и ансамбль 'Мелодия'"
      ], ensureVisible: true);
      await tu.contextMenu(VYSOTSKY.item1, "Create shortcut", waitFor: true);

      final Pair<String, String> MUSE = Pair<String, String>("- All Albums -", "Muse on DLNA");
      await tu.navigateToMedia(
          [OnpcTestUtils.TOP_LAYER, "Local Music", "Kontron DLNA Server", "Music", "Artist", "Muse<S>Mylene Farmer"],
          ensureVisible: true);
      await tu.contextMenu(MUSE.item1, "Create shortcut", waitFor: true);

      await tu.renameShortcuts([
        ARTISTS,
        MUSE,
        VYSOTSKY
      ], [
        "NET/Local Music/Kontron DLNA Server/Music/" + ARTISTS.item1,
        "NET/Local Music/Kontron DLNA Server/Music/Artist/Muse/" + MUSE.item1,
        "NET/Local Music/Denon AVR/Genres/Акустика/Владимир Высоцкий/Владимир Высоцкий и ансамбль 'Мелодия'/" +
            VYSOTSKY.item1
      ], true);
    }

    if (deezer) {
      await tu.openTab("MEDIA");
      final Pair<String, String> PLAYLIST = Pair<String, String>("Onkyo playlist", "Deezer Playlist");
      final Pair<String, String> FAVOURITES = Pair<String, String>("Favourite tracks", "Deezer Favourites");
      final Pair<String, String> ROCK_STATION = Pair<String, String>("Rock classics", "Deezer Classic Rock");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Playlists"]);
      await tu.contextMenu(PLAYLIST.item1, "Create shortcut", waitFor: true);
      await tu.contextMenu(FAVOURITES.item1, "Create shortcut", waitFor: true);
      await tu.navigateToMedia([tu.getReturnString(), "Radio Channels", "Rock<S>Soul & Funk"],
          ensureVisible: true, ensureAfter: () => find.text(ROCK_STATION.item1));
      await tu.contextMenu(ROCK_STATION.item1, "Create shortcut", waitFor: true);
      await tu.renameShortcuts([
        PLAYLIST,
        FAVOURITES,
        ROCK_STATION
      ], [
        "NET/Deezer/My Playlists/" + PLAYLIST.item1,
        "NET/Deezer/My Playlists/" + FAVOURITES.item1,
        "NET/Deezer/Radio Channels/Rock/" + ROCK_STATION.item1
      ], true);
    }

    if (tuneIn) {
      await tu.openTab("MEDIA");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "TuneIn Radio", "Favorites"]);
      await tu.contextMenu("Absolute Classic Hits (Classic Hits)", "Create shortcut", waitFor: true);
    }

    if (usbMusic) {
      final String DENON_AVR = "Denon AVR";
      await tu.openTab("MEDIA");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
      await tu.findAndTap(() => find.widgetWithText(ListTile, DENON_AVR));
      await tu.navigateToMedia(["Genres"]);
      await tu.contextMenu("Disco", "Create shortcut", waitFor: true);
      await tu.ensureVisibleInList(
          "Rock", find.byType(ListView), () => find.text("Synthpop"), OnpcTestUtils.LIST_DRAG_OFFSET);
      await tu.contextMenu("Power Metall", "Create shortcut", waitFor: true);
      await tu.contextMenu("Rock", "Create shortcut", waitFor: true);
      await tu.ensureVisibleInList(
          "Русский рок", find.byType(ListView), () => find.text("Сборники"), OnpcTestUtils.LIST_DRAG_OFFSET);
      await tu.contextMenu("Русский рок", "Create shortcut", waitFor: true);
    }

    if (favorite) {
      await tu.openTab("MEDIA");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Favorite"]);
      await tu.contextMenu("Flow", "Create shortcut");
      await tu.contextMenu("Hard Rock", "Create shortcut");
      await tu.contextMenu("PureRock.US (Metal)", "Create shortcut");
    }

    if (radio) {
      final Pair<String, String> DAB = Pair<String, String>("17 - BOB!", "BOB! on DAB");
      final Pair<String, String> FM1 = Pair<String, String>("2 - 89.80 MHz", "ENERGY on FM");
      final Pair<String, String> FM2 = Pair<String, String>("5 - 93.80 MHz", "");
      await tu.openTab("MEDIA");
      await tu.findAndTap(() => find.text("TUNER"));
      await tu.ensureVisibleInList(
          "List top", find.byType(ListView), () => find.text("DAB"), OnpcTestUtils.LIST_DRAG_OFFSET_UP);
      await tu.findAndTap(() => find.text("DAB"));
      await tu.contextMenu(DAB.item1, "Create shortcut", waitFor: true);
      await tu.findAndTap(() => find.text("FM"));
      await tu.contextMenu(FM1.item1, "Create shortcut", waitFor: true);
      await tu.contextMenu(FM2.item1, "Create shortcut", waitFor: true);
      await tu.renameShortcuts([DAB], [], true, ensureItem: FM2.item1);
      await tu.dragReorderableItem(DAB.item2, OnpcTestUtils.LIST_DRAG_OFFSET_UP, dragIndex: 2);
      await tu.renameShortcuts([FM1], [], true);
      await tu.dragReorderableItem(FM1.item2, OnpcTestUtils.LIST_DRAG_OFFSET_UP, dragIndex: 2);
      await tu.contextMenu(FM2.item1, "Delete", waitFor: true);
    }

    await tu.findAndTap(() => find.text("Deezer Classic Rock"), delay: OnpcTestUtils.NORMAL_DELAY);
  }

  static Future<void> setupOnkyoBox(OnpcTestUtils tu) async {
    await tu.saveConnection("My Onkyo Box", "192.168.1.81");
    if (find.text("Onkyo Box (Standby)").evaluate().isNotEmpty) {
      // Player is off - call power on
      await tu.findAndTap(() => find.byTooltip("On/Standby"));
    }
    await tu.changeServices([
      Pair("Deezer", true),
      Pair("Music Server (DLNA)", true),
      Pair("Spotify", false),
      Pair("Tidal", false),
      Pair("Amazon Music", false),
    ]);
    await tu.changeListeningModes([
      Pair("Mono", false),
      Pair("Stereo", false),
      Pair("Direct", false),
      Pair("Unplugged", false),
      Pair("Orchestra", false),
      Pair("Studio-Mix", false),
      Pair("Pure Audio", false),
      Pair("Full Mono", false),
      Pair("All Ch Stereo", false),
      Pair("TV Logic", false),
      Pair("Theater-Dimensional", false),
      Pair("Dolby Digital", false),
      Pair("Dolby Surround", false),
      Pair("Dolby THX Cinema", false),
      Pair("Dolby THX Music", false),
      Pair("Dolby THX Games", false),
      Pair("DTS Neural:X", false),
      Pair("DTS Virtual:X", false),
      Pair("Game-RPG", false),
      Pair("Game-Action", false),
      Pair("Game-Rock", false),
      Pair("Game-Sports", false),
      Pair("Auto Surround", false)
    ]);
    final AudioSliderParameters p = AudioSliderParameters();
    p.name = "Main:";
    p.initialValue = "1";
    p.initialValueStep = -12;
    p.secondValue = "25";
    p.secondValueStep = 24;
    p.buttonUp = "35";
    p.buttonUpValue = "26";
    p.buttonDown = "1";
    await tu.setMaxVolume(p);
  }

  static Future<void> setupOnkyoPlayer(OnpcTestUtils tu) async {
    await tu.saveConnection("My Onkyo Player", "192.168.1.80");
    if (find.text("Onkyo Player (Standby)").evaluate().isNotEmpty) {
      // Player is off - call power on
      await tu.findAndTap(() => find.byTooltip("On/Standby"));
    }
    await tu.changeInputs([Pair("USB(R)", "USB Disk"), Pair("USB(F)", "")]);
    await tu.changeServices([
      Pair("Tidal", true),
      Pair("TuneIn Radio", true),
      Pair("Deezer", true),
      Pair("Music Server (DLNA)", true),
      Pair("Spotify", false),
      Pair("Amazon Music", false),
    ]);
    await tu.changeListeningModes([
      Pair("Mono", false),
      Pair("Stereo", false),
      Pair("Direct", false),
      Pair("Unplugged", false),
      Pair("Orchestra", false),
      Pair("Studio-Mix", false),
      Pair("Pure Audio", false),
      Pair("Full Mono", false),
      Pair("All Ch Stereo", false),
      Pair("TV Logic", false),
      Pair("Theater-Dimensional", false),
      Pair("Dolby Digital", false),
      Pair("Dolby Surround", false),
      Pair("Dolby THX Cinema", false),
      Pair("Dolby THX Music", false),
      Pair("Dolby THX Games", false),
      Pair("DTS Neural:X", false),
      Pair("DTS Virtual:X", false),
      Pair("Game-RPG", false),
      Pair("Game-Action", false),
      Pair("Game-Rock", false),
      Pair("Game-Sports", false),
      Pair("Auto Surround", false)
    ]);
  }

  static Future<void> buildOnkyoFavourites(final OnpcTestUtils tu) async {
    await tu.openTab("SHORTCUTS");
    if (find.text("Deezer Flow").evaluate().isEmpty) {
      await _buildOnkyoFavourites(tu, dlna: true, deezer: true, tuneIn: true, usbMusic: true, radio: true);
    }
  }

  static Future<void> _buildOnkyoFavourites(final OnpcTestUtils tu,
      {bool dlna = false, bool deezer = false, bool tuneIn = false, bool usbMusic = false, bool radio = false}) async {
    final Pair<String, String> F_FER = Pair<String, String>("Always Ascending", "Franz Ferdinand on DLNA");
    await tu.openTab("MEDIA");

    if (dlna) {
      // DLNA Artists
      final Pair<String, String> ARTISTS = Pair<String, String>("Artist", "DLNA Artists");
      await tu.findAndTap(() => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Music Server (DLNA)", "Kontron DLNA Server", "Music"]);
      await tu.contextMenu(ARTISTS.item1, "Create shortcut",
          waitFor: true, ensureAfter: () => find.text(Strings.favorite_shortcut_added));

      // DLNA Franz Ferdinand
      await tu.navigateToMedia(["Genre", "Rock<S>Rock Opera", "Franz Ferdinand<S>Geordie"],
          ensureVisible: true, ensureAfter: () => find.text(F_FER.item1));
      await tu.ensureVisible(() => find.textContaining("Franz Ferdinand | items:"));
      await tu.findAndTap(() => find.byTooltip(Strings.cmd_description_sort),
          waitFor: true, ensureAfter: () => find.textContaining("Track Number | items:"));
      await tu.findAndTap(() => find.byTooltip(Strings.cmd_description_sort),
          waitFor: true, ensureAfter: () => find.textContaining("Title | items:"));
      await tu.findAndTap(() => find.byTooltip(Strings.cmd_description_sort),
          waitFor: true, ensureAfter: () => find.textContaining("Franz Ferdinand | items:"));
      await tu.contextMenu(F_FER.item1, "Create shortcut", waitFor: true);

      await tu.renameShortcuts([
        ARTISTS,
        F_FER
      ], [
        "NET/Music Server (DLNA)/Kontron DLNA Server/Music/" + ARTISTS.item1,
        "NET/Music Server (DLNA)/Kontron DLNA Server/Music/Genre/Rock/Franz Ferdinand/" + F_FER.item1
      ], false);
    }

    if (deezer) {
      await tu.openTab("MEDIA");
      await tu.findAndTap(() => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer"]);
      await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);

      // Flow
      final Pair<String, String> FLOW = Pair<String, String>("Flow", "Deezer Flow");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Music"]);
      await tu.findAndTap(() => find.text("My Music | items: 6"),
          waitFor: true, ensureAfter: () => find.text(FLOW.item1));
      await tu.contextMenu(FLOW.item1, "Create shortcut", waitFor: true);

      // Favourite tracks
      final Pair<String, String> FAVOURITES = Pair<String, String>("The Dancer", "Deezer Favourites");
      await tu.navigateToMedia(["My Music", "Favourite tracks"], ensureAfter: () => find.text("Lady In Black"));
      await tu.contextMenu(FAVOURITES.item1, "Create shortcut");

      // Deezer Playlist
      final Pair<String, String> PLAYLIST = Pair<String, String>("Personal Jesus / Depeche Mode", "Deezer Playlist");
      await tu.navigateToMedia([tu.getReturnString(), "My Playlists", "Onkyo playlist"],
          ensureAfter: () => find.text("Forever / Y&T"));
      await tu.contextMenu(PLAYLIST.item1, "Create shortcut", waitFor: true);

      // В.Высоцкий
      final Pair<String, String> VYSOTSKY = Pair<String, String>('Цыганский романс "Кони привередливые"', "В.Высоцкий");
      await tu.navigateToMedia([
        tu.getReturnString(),
        tu.getReturnString(),
        "My Albums",
        'Владимир Высоцкий и ансамбль "Мелодия" / Vladimir Vysotsky'
      ], ensureVisible: true);
      await tu.contextMenu(VYSOTSKY.item1, "Create shortcut", waitFor: true);

      // Rock & Roll
      final Pair<String, String> ROCK_N_ROLL = Pair<String, String>("Rock & Roll", "Deezer Rock & Roll");
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "Mixes", "Rock<S>Soul & Funk"], ensureVisible: true);
      await tu.ensureVisibleInList(
          ROCK_N_ROLL.item1, find.byType(ListView), () => find.text(ROCK_N_ROLL.item1), OnpcTestUtils.LIST_DRAG_OFFSET);
      await tu.contextMenu(ROCK_N_ROLL.item1, "Create shortcut");

      await tu.renameShortcuts([
        FLOW,
        FAVOURITES,
        PLAYLIST,
        VYSOTSKY,
        ROCK_N_ROLL
      ], [
        "NET/Deezer/" + FLOW.item1,
        "NET/Deezer/My Music/Favourite tracks/" + FAVOURITES.item1,
        "NET/Deezer/My Music/My Playlists/Onkyo playlist/" + PLAYLIST.item1,
        'NET/Deezer/My Music/My Albums/Владимир Высоцкий и ансамбль "Мелодия" / Vladimir Vysotsky/' + VYSOTSKY.item1,
        'NET/Deezer/Mixes/Rock/' + ROCK_N_ROLL.item1,
      ], false);
    }

    if (tuneIn) {
      await tu.openTab("MEDIA");
      await tu.findAndTap(() => find.text("NET"), delay: OnpcTestUtils.NORMAL_DELAY);
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "TuneIn Radio", "My Presets"]);
      await tu.contextMenu("Absolute Classic Hits (Classic Hits)", "Create shortcut", waitFor: true);
      await tu.contextMenu("PureRock.US (Metal)", "Create shortcut", waitFor: true);
    }

    if (usbMusic) {
      await tu.openTab("MEDIA");
      await tu.findAndTap(() => find.text("USB Disk"), delay: OnpcTestUtils.NORMAL_DELAY);
      await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "onkyo_music"]);
      await tu.contextMenu("Disco", "Create shortcut", waitFor: true);
      await tu.ensureVisibleInList(
          "Rock", find.byType(ListView), () => find.text("Synthpop"), OnpcTestUtils.LIST_DRAG_OFFSET);
      await tu.contextMenu("Power Metall", "Create shortcut", waitFor: true);
      await tu.contextMenu("Rock", "Create shortcut", waitFor: true);
      await tu.ensureVisibleInList(
          "Эстрада", find.byType(ListView), () => find.text("Эстрада"), OnpcTestUtils.LIST_DRAG_OFFSET);
      await tu.contextMenu("Русский рок", "Create shortcut", waitFor: true);
    }

    if (radio) {
      final Pair<String, String> DAB = Pair<String, String>("Playback mode", "DAB");
      final Pair<String, String> FM = Pair<String, String>("2 - EnrgyBRE - 89.80 MHz", "ENERGY");
      await tu.openTab("MEDIA");
      await tu.findAndTap(() => find.text("DAB"), ensureAfter: () => find.text(DAB.item1));
      await tu.contextMenu(DAB.item1, "Create shortcut", waitFor: true);
      await tu.findAndTap(() => find.text("FM"), ensureAfter: () => find.text(FM.item1));
      await tu.contextMenu(FM.item1, "Create shortcut", waitFor: true);
      await tu.renameShortcuts([DAB, FM], [], false);
    }

    await tu.findAndTap(() => find.text(F_FER.item2), delay: OnpcTestUtils.NORMAL_DELAY);
  }

  static Future<void> addOnkyoRiDevices(OnpcTestUtils tu) async {
    if (!Platform.isDesktop) {
      return;
    }
    final String TD = "Tape Deck (RI)";
    final String MD = "MD Player (RI)";
    await tu.openTab("RI", swipeRight: true);

    // Tab layout
    await tu.openDrawerMenu("Tab layout", ensureAfter: () => find.text("Divider"));
    await tu.changeReorderableItem("Divider");
    await tu.ensureVisibleInList(
        TD, find.byType(ReorderableListView), () => find.text(TD), OnpcTestUtils.LIST_DRAG_OFFSET);
    await tu.tester.drag(find.text(MD), OnpcTestUtils.LIST_DRAG_OFFSET, warnIfMissed: false);
    await tu.stepDelayMs();
    await tu.changeReorderableItem(MD, state: true);
    await tu.changeReorderableItem(TD, state: true);
    await tu.previousScreen();
  }
}
