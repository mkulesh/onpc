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
import 'package:onpc/widgets/CustomTextButton.dart';

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
    await _audioControl(tu);
    await _playFromQueue(tu);
    await _testHeosFavorites(tu);
    await _playFromDeezer(tu);
    await _hideEmptyItems(tu);
    await _changeListeningModes(tu, "FLAC 44.1 kHz");
    await _playFromDAB(tu);
    await _changeDeviceSettings(tu);

    // Power-off
    await tu.findAndTap("Power-off", () => find.byTooltip("On/Standby"));

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

class _AudioSliderParameters {
  String name = "";
  String initialValue = "";
  double initialValueStep = 0;
  String secondValue = "";
  double secondValueStep = 0;
  String buttonUp = "";
  String buttonUpValue = "";
  String buttonDown = "";
}

Future<void> _testAudioSlider(OnpcTestUtils tu, final _AudioSliderParameters p) async {
  Pair<Finder, Finder> slider;
  // Stepwise down
  while (find.text(p.name + " " + p.initialValue).evaluate().isEmpty) {
    slider = tu.findSliderByName(p.name);
    await tu.slideByValue(slider.item1, p.initialValueStep);
  }
  // Up by value
  slider = tu.findSliderByName(p.name + " " + p.initialValue);
  await tu.slideByValue(slider.item1, p.secondValueStep);
  // Up using button
  slider = tu.findSliderByName(p.name + " " + p.secondValue, withButtons: true);
  assert(slider.item2.evaluate().length == 2);
  assert((slider.item2.evaluate().first.widget as CustomTextButton).text.contains(p.buttonDown));
  assert((slider.item2.evaluate().last.widget as CustomTextButton).text.contains(p.buttonUp));
  await tu.findAndTap(p.name + " up", () => slider.item2,
      num: 2, idx: 1, ensureAfter: () => find.text(p.name + " " + p.buttonUpValue));
  // Down using button
  slider = tu.findSliderByName(p.name + " " + p.buttonUpValue, withButtons: true);
  await tu.findAndTap(p.name + " down", () => slider.item2,
      num: 2, idx: 0, ensureAfter: () => find.text(p.name + " " + p.secondValue));
}

Future<void> _audioControl(OnpcTestUtils tu) async {
  await tu.findAndTap("Open audio control", () => find.byTooltip("Audio control"),
      ensureAfter: () => find.text("Audio control"));

  final _AudioSliderParameters p = _AudioSliderParameters();

  // Master volume
  p.name = "Master volume:";
  p.initialValue = "0.0 (-80.0 dB)";
  p.initialValueStep = -10;
  p.secondValue = "9.0 (-71.0 dB)";
  p.secondValueStep = 15;
  p.buttonUp = "60";
  p.buttonUpValue = "9.5 (-70.5 dB)";
  p.buttonDown = "0";
  await _testAudioSlider(tu, p);

  // Bass and Treble
  p.name = "Bass:";
  p.initialValue = "-6";
  p.initialValueStep = -4;
  p.secondValue = "0";
  p.secondValueStep = 6;
  p.buttonUp = "6";
  p.buttonUpValue = "1";
  p.buttonDown = "-6";
  await _testAudioSlider(tu, p);
  p.name = "Treble:";
  p.secondValue = "3";
  p.secondValueStep = 9;
  p.buttonUpValue = "4";
  await _testAudioSlider(tu, p);

  // Balance
  p.name = "Balance:";
  p.initialValue = "-12";
  p.initialValueStep = -4;
  p.secondValue = "0";
  p.secondValueStep = 12;
  p.buttonUp = "12";
  p.buttonUpValue = "1";
  p.buttonDown = "-12";
  await _testAudioSlider(tu, p);

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
  await tu.playShortcut(shortcut, "TUNER", ensureTop: "DAB", waitPlaying: "BOB!");

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
  await _changeListeningMode(tu, input, "Pure Direct");
  await _changeListeningMode(tu, input, "Direct");
  await _changeListeningMode(tu, input, "Stereo");
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

Future<void> _changeListeningMode(OnpcTestUtils tu, String input, String mode) async {
  await tu.openTab("LISTEN", swipeLeft: true, ensureAfter: () => find.text(mode.toUpperCase()));
  await tu.findAndTap("Set " + mode, () => find.text(mode.toUpperCase()), delay: OnpcTestUtils.NORMAL_DELAY);
  await tu.ensureAvInfo(input, mode);
  await tu.openTab("RC", swipeRight: true, ensureAfter: () => find.text("Listening modes"));
  expect(find.text(mode), findsOneWidget);
  if (mode == "Stereo") {
    await tu.findAndTap("Mode Up", () => find.byTooltip("Sets listening mode wrap-around up"),
        ensureAfter: () => find.text("Pure Direct"));
    await tu.findAndTap("Mode Down", () => find.byTooltip("Sets listening mode wrap-around down"),
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
