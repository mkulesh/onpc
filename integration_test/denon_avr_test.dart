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
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/constants/Strings.dart';
import 'package:onpc/main.dart' as app;
import 'package:onpc/utils/Logging.dart';
import 'package:onpc/utils/Pair.dart';
import 'package:onpc/views/AudioControlChannelLevelView.dart';

import 'onpc_test_utils.dart';

final String DENON_AVR = "Denon AVR";
final String FRIENDLY_NAME = "My Denon AVR";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Automatic test of ' + FRIENDLY_NAME, (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);

    app.main();
    await tu.connect(FRIENDLY_NAME, DENON_AVR);

    await _playFromUsb(tu);
    await _audioControl(tu, true);
    await _playFromQueue(tu);
    await _testHeosFavorites(tu);
    await _playFromDeezer(tu);
    await _hideEmptyItems(tu);
    await _changeListeningModes(tu, "FLAC 44.1 kHz");
    await _playFromDAB(tu);
    await _changeDeviceSettings(tu);
    await _allZoneStereo(tester, tu);
    await _createPlayList(tu);

    // Power-off
    await tu.openDrawerMenu(Strings.drawer_all_standby,
        ensureAfter: () => find.text(DENON_AVR + "/" + "To Onkyo (Standby)"));
    await tu.openDrawerMenu("Main", ensureAfter: () => find.text(DENON_AVR + " (Standby)"));

    // Write log
    await tu.writeLog("auto-test-denon");
  });
}

Future<void> _playFromUsb(final OnpcTestUtils tu) async {
  // Start playing shortcut1
  final String shortcut1 = "В.Высоцкий";
  final String shortcut1_artist = "Владимир Высоцкий и ансамбль 'Мелодия'";
  final String shortcut1_track = "Цыганский романс 'Кони привередливые'";
  await tu.playShortcut(shortcut1, shortcut1_artist, waitPlaying: shortcut1_track);
  await tu.openTab("LISTEN", ensureAfter: () => find.text("Владимир Высоцкий"));
  expect(find.textContaining(shortcut1_artist), findsOneWidget);
  expect(find.textContaining(shortcut1_track), findsOneWidget);

  // Navigate to USB
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
  await tu.findAndTap("Navigate to: " + DENON_AVR, () => find.widgetWithText(ListTile, DENON_AVR),
      ensureAfter: () => find.byTooltip("Search"));

  // Search Accept
  final String artist1 = "Accept";
  await _openSearchDialog(tu, 0, artist1);

  // Add first albums to the queue
  final String album1 = "Metal Heart";
  await tu.findAndTap("Select " + artist1, () => find.widgetWithText(ListTile, artist1),
      ensureAfter: () => find.widgetWithText(ListTile, album1));
  await tu.contextMenu(album1, "Replace and play",
      checkItems: ["Play queue", "Replace and play", "Add", "Add and play", "Create shortcut"]);

  // Search and add second album to the queue
  final String artist2 = "Muse";
  final String album2 = "Absolution";
  await _openSearchDialog(tu, 1, album2);
  expect(find.text(artist1), findsNothing);
  expect(find.text(album1), findsNothing);
  await tu.contextMenu(album2, "Add");

  // Inspect queue
  await tu.findAndTap("Top Menu", () => find.byTooltip("Top Menu"), ensureAfter: () => find.text("Play Queue"));
  await tu.findAndTap("Open Play Queue", () => find.text("Play Queue"),
      ensureAfter: () => find.textContaining("Play Queue | items: 27"));

  // Inspect playing
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist1));
  expect(find.byTooltip("Play Queue"), findsOneWidget);
  expect(find.text(album1), findsExactly(2));
  expect(find.text("1/27"), findsOneWidget);

  // Play mode
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Repeat", () => find.byTooltip("Repeat"), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.findAndTap("Random", () => find.byTooltip("Random"), delay: OnpcTestUtils.NORMAL_DELAY);

  // Next track
  await tu.findAndTap("Next track", () => find.byTooltip("Track Up"), ensureAfter: () => find.text("Midnight Mover"));
  expect(find.text(artist1), findsOneWidget);
  expect(find.text(album1), findsOneWidget);
  expect(find.text("2/27"), findsOneWidget);

  // Pause
  await tu.ensureVisible(() => find.byTooltip("Pause"));
  await tu.findAndTap("Pause", () => find.byTooltip("Pause"), ensureAfter: () => find.byTooltip("Play"));
  expect(find.byTooltip("Pause"), findsNothing);
  await tu.findAndTap("Play", () => find.byTooltip("Play"));

  // Stop
  await tu.findAndTap("Stop playback", () => find.byTooltip("Stop"));

  // Start from play queue
  await tu.findAndTap("Open queue", () => find.byTooltip("Play Queue"),
      ensureAfter: () => find.textContaining("Play Queue | items: 27"));
  await tu.ensureVisibleInList("Ensure " + artist2, find.byType(ReorderableListView),
      () => find.text("Muse - Endlessly"), OnpcTestUtils.LIST_DRAG_OFFSET);
  await tu.findAndTap("Start " + artist2, () => find.text("Muse - Fury"));
  await tu.openTab("LISTEN", ensureAfter: () => find.text(artist2));
  expect(find.text("Fury"), findsOneWidget);
  expect(find.text(album2), findsOneWidget);
  expect(find.text("24/27"), findsOneWidget);

  // Audio info dialog
  await tu.findAndTap("Set Stereo Mode", () => find.text("Stereo".toUpperCase()), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.ensureAvInfo("MP3 44.1 kHz", "Stereo");
}

Future<void> _audioControl(OnpcTestUtils tu, bool mainZone) async {
  await tu.findAndTap("Open audio control", () => find.byTooltip(Strings.audio_control),
      ensureAfter: () => find.text(Strings.audio_control_current_zone));

  expect(find.byTooltip(Strings.audio_control_current_zone), findsOneWidget);
  expect(find.byTooltip(Strings.audio_control_all_zones), findsOneWidget);
  expect(find.byTooltip(Strings.audio_control_equalizer), findsNothing);
  expect(find.byTooltip(Strings.audio_control_channel_level), findsOneWidget);
  expect(find.byTooltip(Strings.audio_control_max_level), findsOneWidget);

  final AudioSliderParameters p = AudioSliderParameters();

  // Current zone
  final String zone = mainZone ? ": Main" : ": To Onkyo";
  expect(find.text(Strings.drawer_group_zone + zone), findsOneWidget);

  if (mainZone) {
    // Master volume
    p.name = Strings.master_volume + ":";
    p.initialValue = "0.0 (-80.0 dB)";
    p.initialValueStep = -10;
    p.secondValue = "8.0 (-72.0 dB)";
    p.secondValueStep = 15;
    p.buttonUp = "30.0";
    p.buttonUpValue = "8.5 (-71.5 dB)";
    p.buttonDown = "0";
    await tu.testAudioSlider(p);

    // Bass and Treble
    p.name = Strings.tone_bass + ":";
    p.initialValue = "-6";
    p.initialValueStep = -4;
    p.secondValue = "0";
    p.secondValueStep = 6;
    p.buttonUp = "6";
    p.buttonUpValue = "1";
    p.buttonDown = "-6";
    await tu.testAudioSlider(p);
    p.name = Strings.tone_treble + ":";
    p.secondValue = "3";
    p.secondValueStep = 9;
    p.buttonUpValue = "4";
    await tu.testAudioSlider(p);
  } else {
    expect(find.textContaining(Strings.tone_bass), findsNothing);
    expect(find.textContaining(Strings.tone_treble), findsNothing);
  }

  // Balance
  p.name = Strings.audio_balance + ":";
  p.initialValue = "-12";
  p.initialValueStep = -4;
  p.secondValue = "0";
  p.secondValueStep = 12;
  p.buttonUp = "12";
  p.buttonUpValue = "1";
  p.buttonDown = "-12";
  await tu.testAudioSlider(p);

  // All zones
  await tu.findAndTap("Open all zones", () => find.byTooltip(Strings.audio_control_all_zones),
      ensureAfter: () => find.text(Strings.audio_control_all_zones));

  expect(find.text(Strings.master_volume), findsOneWidget);
  expect(find.textContaining("Main:"), findsOneWidget);
  expect(find.textContaining("To Onkyo:"), findsOneWidget);

  // master volume
  p.name = "Main:";
  p.initialValue = "0.0 (-80.0 dB)";
  p.initialValueStep = -10;
  p.secondValue = "8.0 (-72.0 dB)";
  p.secondValueStep = 15;
  p.buttonUp = "30.0";
  p.buttonUpValue = "8.5 (-71.5 dB)";
  p.buttonDown = "0";
  await tu.testAudioSlider(p);

  if (!mainZone) {
    p.name = "To Onkyo:";
    p.initialValue = "0 (-80.0 dB)";
    p.initialValueStep = -22;
    p.secondValue = "50 (-30.0 dB)";
    p.secondValueStep = 51;
    p.buttonUp = "60";
    p.buttonUpValue = "51 (-29.0 dB)";
    p.buttonDown = "0";
    await tu.testAudioSlider(p);
  }

  // Channel level
  await tu.findAndTap("Open channel level", () => find.byTooltip(Strings.audio_control_channel_level),
      ensureAfter: () => find.text(Strings.audio_control_channel_level));
  expect(find.text("Front"), findsOneWidget);
  expect(find.text("Center"), findsOneWidget);
  AudioControlChannelLevelView.LABELS.forEach((label) => expect(find.text(label), findsOneWidget));
  expect(find.text(Strings.action_default.toUpperCase()), findsOneWidget);

  // Maximum level
  await tu.findAndTap("Open maximum volume", () => find.byTooltip(Strings.audio_control_max_level),
      ensureAfter: () => find.text(Strings.audio_control_max_level));
  expect(find.text(Strings.master_volume_max), findsOneWidget);
  expect(find.textContaining("Main:"), findsOneWidget);
  expect(find.textContaining("To Onkyo:"), findsOneWidget);

  await tu.findAndTap("Close audio control", () => find.text("OK"));
}

Future<void> _playFromQueue(OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));

  // Navigate to play queue
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Play Queue"]);
  expect(find.text("Play Queue | items: 27"), findsOneWidget);

  // Get initial list
  List<Pair<String, String>> list = tu.getListContent();
  Logging.info(tu, "Initial list: " + list.toString());

  // Start playing first item
  final String toPlay = "Accept - Metal Heart";
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toPlay);
  await tu.findAndTap("Start " + toPlay, () => find.text(list.elementAt(1).item2));
  await tu.waitMediaItemPlaying(toPlay);

  // Reorder list
  final String toReorder = "Accept - Too High To Get It Right";
  await tu.dragReorderableItem(toReorder, Offset(0, -600), dragIndex: 2);
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  list = tu.getListContent();
  assert(list.elementAt(1).item1.contains("media_item_music.svg"));
  assert(list.elementAt(1).item2 == toReorder);

  // Remove item
  final String toDelete = "Accept - Up To The Limit";
  expect(find.text(toDelete), findsOneWidget);
  await tu.contextMenu(toDelete, "Remove item",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 26"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);
  expect(find.text(toDelete), findsNothing);

  // Remove all
  final String toDeleteAll = "Accept - Dogs On Leads";
  expect(find.text(toDeleteAll), findsOneWidget);
  await tu.contextMenu(toDeleteAll, "Remove all",
      checkItems: ["Play queue", "Remove item", "Remove all", "Create shortcut"],
      ensureAfter: () => find.text("Play Queue | items: 0"));
  await tu.stepDelaySec(OnpcTestUtils.NORMAL_DELAY);

  await tu.findAndTap("Return to top layer", () => find.text("Return"),
      ensureAfter: () => find.textContaining("HEOS MUSIC | items:"));
  await tu.openTab("LISTEN", ensureAfter: () => find.text("---/---"));
}

Future<void> _testHeosFavorites(OnpcTestUtils tu) async {
  final String shortcut = "Flow";

  // Start playing
  await tu.playShortcut(shortcut, "Favorite");
  expect(find.text(shortcut), findsOneWidget);

  // Remove from HEOS
  await tu.contextMenu(shortcut, "Remove from HEOS Favorites", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Remove from HEOS Favorites",
    "Create shortcut"
  ]);
  await tu.ensureDeleted(() => find.text(shortcut));
  expect(find.text(shortcut), findsNothing);

  // Add to HEOS again
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "Flow"]);
  await tu.ensureVisible(() => find.text("Flow | items: 1"));
  await tu.contextMenu(shortcut, "Add to HEOS Favorites", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Add to HEOS Favorites",
    "Create shortcut"
  ]);

  // Check that item is added
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Favorite"]);
  expect(find.text(shortcut), findsOneWidget);
}

Future<void> _playFromDeezer(OnpcTestUtils tu) async {
  // Play from Deezer favourites
  final String toPlay = "Don't You Believe a Stranger";
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer", "My Playlists", "Favourite tracks"]);
  await tu.ensureVisible(() => find.textContaining("Favourite tracks | items: "));
  expect(find.text(toPlay), findsOneWidget);
  await tu.findAndTap("Start " + toPlay, () => find.text(toPlay));
  await tu.waitMediaItemPlaying(toPlay);

  // Audio info
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  await tu.ensureAvInfo("FLAC 44.1 kHz", "Stereo");
}

Future<void> _hideEmptyItems(OnpcTestUtils tu) async {
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));

  // Search artist
  final String artist = "Muse";
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Deezer"]);
  await _openSearchDialog(tu, 0, artist);

  // Filter artist
  await tu.findAndTap("Open filter", () => find.byTooltip(Strings.medialist_filter));
  await tu.setText(1, 0, artist);
  await tu.stepDelayMs();
  await tu.ensureVisibleInList(
      "Ensure return", find.byType(ListView), () => find.text("Return"), OnpcTestUtils.LIST_DRAG_OFFSET_UP);

  // Get initial number of items
  final List<Pair<String, String>> list1 = tu.getListContent();
  final int count1 = list1.where((item) => item.item2 == artist).length;
  expect(find.widgetWithText(ListTile, artist), findsNWidgets(count1));

  // Hide empty items
  await tu.contextMenu(artist, Strings.medialist_hide_empty_items, waitFor: true, num: count1 + 1, idx: count1 - 1);
  await tu.stepDelayMs();
  await tu.ensureVisible(() => find.byTooltip(Strings.medialist_filter));

  // Get final number of items
  final List<Pair<String, String>> list2 = tu.getListContent();
  final int count2 = list2.where((item) => item.item2 == artist).length;
  Logging.info(tu, "Initial number of items: " + count1.toString());
  Logging.info(tu, "Final number of items: " + count2.toString());
  expect(count2 < count1, true);
}

Future<void> _playFromDAB(final OnpcTestUtils tu) async {
  final String shortcut = "BOB! on DAB";

  // Start playing
  await tu.playShortcut(shortcut, "TUNER", ensureItem: "ENERGY on FM", ensureTop: "DAB", waitPlaying: "BOB!");

  // Check station data
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  expect(find.byTooltip("Sets tuning frequency wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets tuning frequency wrap-around down"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around up"), findsOneWidget);
  expect(find.byTooltip("Sets preset wrap-around down"), findsOneWidget);
  await tu.ensureVisible(() => find.text("5C:178.352MHz"));
  expect(find.text("BOB!"), findsOneWidget);
  expect(find.text("RADIO BOB!"), findsOneWidget);
  await tu.ensureAvInfo("AAC", "Stereo");

  // Change station by preset
  await tu.findAndTap("Next preset", () => find.byTooltip("Sets preset wrap-around up"),
      ensureAfter: () => find.text("ROLAND"));
  expect(find.text("RADIO ROLAND"), findsOneWidget);
  await tu.stepDelayMs();

  // Seek station
  await tu.findAndTap("Next station", () => find.byTooltip("Sets tuning frequency wrap-around up"),
      ensureAfter: () => find.text("5D:180.064MHz"));
  expect(find.text("ROCK ANTENNE"), findsOneWidget);
  await tu.stepDelayMs();

  // Change station by list
  final String station = "OLDIEANT";
  await tu.openTab("MEDIA", ensureAfter: () => find.textContaining(station));
  await tu.findAndTap("Start " + station, () => find.textContaining(station));
  await tu.waitMediaItemPlaying(station);
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"));
  expect(find.text(station), findsOneWidget);
  expect(find.text("OLDIE ANTENNE"), findsOneWidget);
}

Future<void> _changeListeningModes(OnpcTestUtils tu, String input) async {
  await _changeListeningMode(tu, input, Strings.listening_mode_pure_direct, false);
  await _changeListeningMode(tu, input, Strings.listening_mode_mode_01, false); // Direct
  await _changeListeningMode(tu, input, Strings.listening_mode_mode_00, true); // Stereo
}

Future<void> _changeDeviceSettings(OnpcTestUtils tu) async {
  // New friendly name
  await tu.openTab("DEVICE", ensureAfter: () => find.byTooltip("Change friendly name"));
  await tu.changeFriendlyName(tu, "New Player Name");

  // Restore friendly name
  await tu.openTab("LISTEN", ensureAfter: () => find.text("STEREO"), swipeLeft: true);
  await tu.openTab("DEVICE", ensureAfter: () => find.byTooltip("Change friendly name"), swipeRight: true);
  await tu.changeFriendlyName(tu, "Denon AVR");

  // Rename dimmer level
  final String DIM_NAME = "Super-Bright";
  await tu.contextMenu("Bright", "Edit");
  await tu.setText(2, 1, DIM_NAME);
  await tu.findAndTap("Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsOneWidget);

  // Restore dimmer level name
  await tu.contextMenu(DIM_NAME, "Edit");
  await tu.findAndTap("Dimmer level: delete", () => find.byTooltip("Delete"));
  await tu.findAndTap("Dimmer level: confirm change", () => find.text("OK"));
  expect(find.text(DIM_NAME), findsNothing);
  expect(find.text("Bright"), findsOneWidget);
}

Future<void> _allZoneStereo(final WidgetTester tester, OnpcTestUtils tu) async {
  final String lm1 = Strings.listening_mode_pure_direct.toUpperCase();
  final String lm2 = Strings.listening_mode_all_zone_stereo.toUpperCase();
  final String artist = "Metallica";
  final String album = "Reload";
  final String zone = "To Onkyo";

  // Set listening mode
  await tu.openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.text(lm1));
  await tester.drag(find.text(lm1), Offset(-200, 0), warnIfMissed: false);
  await tu.stepDelayMs();
  await tu.findAndTap("Set all zone stereo", () => find.text(lm2));
  // Start playing
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
  await tu.findAndTap("Navigate to: " + DENON_AVR, () => find.widgetWithText(ListTile, DENON_AVR),
      ensureAfter: () => find.byTooltip("Search"));
  await _openSearchDialog(tu, 1, album);
  await tu.contextMenu(album, "Replace and play",
      checkItems: ["Play queue", "Replace and play", "Add", "Add and play", "Create shortcut"]);
  // Check that playing started
  await tu.openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.text(lm2));
  await tu.findAndTap("Ensure artist", () => find.text(artist), waitFor: true);
  expect(find.text(album), findsOneWidget);
  // Open Zone2
  await tu.openDrawerMenu(zone, ensureAfter: () => find.text(DENON_AVR + "/" + zone));
  await tu.findAndTap("Ensure artist", () => find.text(artist), waitFor: true);
  expect(find.text(album), findsOneWidget);
  await _audioControl(tu, false);
}

Future<void> _createPlayList(OnpcTestUtils tu) async {
  final String playlist = "My test playlist";
  final String playlist1 = "My test playlist1";
  final String artist = "Ayo";
  final String album = "Joyful";
  final String song1 = "Without You";
  final String song2 = "Letter By Letter";
  final String items = "items: 12";

  // Start playing
  await tu.openTab("MEDIA", ensureAfter: () => find.text("NET"));
  await tu.findAndTap("Select NET", () => find.text("NET"));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Local Music"]);
  await tu.findAndTap("Navigate to: " + DENON_AVR, () => find.widgetWithText(ListTile, DENON_AVR),
      ensureAfter: () => find.byTooltip("Search"));
  await _openSearchDialog(tu, 1, album);
  await tu.contextMenu(album, "Replace and play",
      checkItems: ["Play queue", "Replace and play", "Add", "Add and play", "Create shortcut"]);

  // Check queue state
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Play Queue"]);
  await tu.ensureVisible(() => find.text(artist + " - " + song1));
  expect(find.byTooltip(Strings.medialist_filter), findsOneWidget);
  expect(find.byTooltip(Strings.playlist_save_queue_as), findsOneWidget);
  expect(find.text("Play Queue | " + items), findsOneWidget);
  await tu.findAndTap("Ensure song1", () => find.text(artist + " - " + song1), waitFor: true);

  // Create playlist
  await tu.findAndTap("Open playlist creation dialog", () => find.byTooltip(Strings.playlist_save_queue_as),
      waitFor: true);
  expect(find.text(Strings.playlist_save_queue_as), findsOneWidget);
  await tu.setText(1, 0, playlist);
  await tu.findAndTap("Create playlist: " + playlist, () => find.text("OK"));
  await tu.ensureVisible(() => find.text(Strings.playlist_created));

  // Check playlist state
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Play List"]);
  await tu.ensureVisible(() => find.text(playlist));
  expect(find.byTooltip(Strings.medialist_filter), findsOneWidget);
  expect(find.byTooltip(Strings.playlist_save_queue_as), findsNothing);
  await tu.findAndTap("Ensure playlist", () => find.text(playlist), waitFor: true);
  await tu.findAndTap("Ensure song2", () => find.text(artist + " - " + song2), waitFor: true);
  await tu.findAndTap("Ensure top level", () => find.text(playlist + " | " + items), waitFor: true);
  await tu.ensureVisible(() => find.text(playlist));

  // Rename playlist
  await tu.contextMenu(playlist, "Rename playlist", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Rename playlist",
    "Delete playlist",
    "Create shortcut"
  ]);
  await tu.setText(1, 0, playlist1);
  await tu.findAndTap("Rename playlist1: " + playlist1, () => find.text("OK"));
  await tu.findAndTap("Ensure playlist1", () => find.text(playlist1), waitFor: true);
  await tu.findAndTap("Ensure song1", () => find.text(artist + " - " + song1), waitFor: true);
  await tu.findAndTap("Ensure top level", () => find.text(playlist1 + " | " + items), waitFor: true);
  await tu.ensureVisible(() => find.text(playlist1));

  // Delete playlist
  await tu.contextMenu(playlist1, "Delete playlist", checkItems: [
    "Play queue",
    "Replace and play",
    "Add",
    "Add and play",
    "Rename playlist",
    "Delete playlist",
    "Create shortcut"
  ]);
  await tu.ensureDeleted(() => find.text(playlist1));
  await tu.navigateToMedia([OnpcTestUtils.TOP_LAYER, "Play List"]);
  await tu.ensureVisible(() => find.textContaining("Play List | items"));
  expect(find.text(playlist), findsNothing);
  expect(find.text(playlist1), findsNothing);
}

Future<void> _changeListeningMode(OnpcTestUtils tu, String input, String mode, bool isToneCtrl) async {
  await tu.openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.text(mode.toUpperCase()));
  await tu.findAndTap("Set " + mode, () => find.text(mode.toUpperCase()), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.ensureAvInfo(input, mode);
  await tu.findAndTap("Open audio control", () => find.byTooltip(Strings.audio_control),
      ensureAfter: () => find.text(Strings.audio_control_current_zone));
  expect(find.textContaining(Strings.master_volume), findsOneWidget);
  expect(find.textContaining(Strings.tone_bass), isToneCtrl ? findsOneWidget : findsNothing);
  expect(find.textContaining(Strings.tone_treble), isToneCtrl ? findsOneWidget : findsNothing);
  expect(find.textContaining(Strings.audio_balance), isToneCtrl ? findsOneWidget : findsNothing);
  expect(find.textContaining(Strings.tone_direct), isToneCtrl ? findsNothing : findsOneWidget);
  await tu.findAndTap("Close audio control", () => find.text("OK"));
  await tu.openTab("RC", swipeRight: true, ensureAfter: () => find.text(Strings.pref_listening_modes));
  expect(find.text(mode), findsOneWidget);
  if (mode == "Stereo") {
    await tu.findAndTap("Mode Up", () => find.byTooltip(Strings.listening_mode_up),
        ensureAfter: () => find.text(Strings.listening_mode_pure_direct));
    await tu.findAndTap("Mode Down", () => find.byTooltip(Strings.listening_mode_down),
        ensureAfter: () => find.text("Stereo"));
  }
}

Future<void> _openSearchDialog(OnpcTestUtils tu, int type, String search) async {
  await tu.findAndTap("Open Search dialog", () => find.byTooltip("Search"), ensureAfter: () => find.text("OK"));
  expect(find.text("Search"), findsOneWidget);
  expect(find.text("Artist"), findsOneWidget);
  expect(find.text("Album"), findsOneWidget);
  expect(find.text("Track"), findsOneWidget);
  expect(find.text("CANCEL"), findsOneWidget);
  final Finder fab = find.byWidgetPredicate((widget) => widget is Radio);
  expect(fab, findsNWidgets(3));
  await tu.findAndTap("Search for type: " + type.toString(), () => fab.at(type));
  await tu.setText(1, 0, search);
  await tu.findAndTap("Start search for: " + search, () => find.text("OK"),
      ensureAfter: () => find.textContaining("Search: " + search + " | items:"));
  await tu.ensureVisibleInList(
      "Ensure item " + search, find.byType(ListView), () => find.text(search), Offset(0, -300));
}
