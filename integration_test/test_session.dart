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

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onpc/main.dart' as app;

import 'onpc_app_setup.dart';
import 'onpc_denon_tests.dart';
import 'onpc_onkyo_tests.dart';
import 'onpc_test_utils.dart';

final List<OnpcTestProcedure> procedures = [
  // Application setup
  OnpcTestProcedure(OnpcAppSetup.initialSearch, "Initial Search"),
  OnpcTestProcedure(OnpcAppSetup.aboutScreen, "About Screen"),
  OnpcTestProcedure(OnpcAppSetup.changeAppSettings, "Change Basic Settings"),
  OnpcTestProcedure(OnpcAppSetup.changeListenLayout, "Change Tab Layout"),
  OnpcTestProcedure(OnpcAppSetup.setupDenon, "Initial Setup of Denon AVR"),
  OnpcTestProcedure(OnpcAppSetup.buildDenonFavourites, "Building Favourites for Denon AVR"),
  OnpcTestProcedure(OnpcAppSetup.setupOnkyoBox, "Initial Setup of Onkyo Box"),
  OnpcTestProcedure(OnpcAppSetup.setupOnkyoPlayer, "Initial Setup of Onkyo Player"),
  OnpcTestProcedure(OnpcAppSetup.buildOnkyoFavourites, "Building Favourites for Onkyo Player"),
  OnpcTestProcedure(OnpcAppSetup.addOnkyoRiDevices, "Set Onkyo RI devices"),
  // Onkyo test
  OnpcTestProcedure(OnpcOnkyoTests.playFromDlna, "Onkyo: Play from DLNA"),
  OnpcTestProcedure(OnpcOnkyoTests.playFromUsb, "Onkyo: Play from USB"),
  OnpcTestProcedure(OnpcOnkyoTests.playFromQueue, "Onkyo: Play from Queue"),
  OnpcTestProcedure(OnpcOnkyoTests.playFromDeezer, "Onkyo: Play from Deezer"),
  OnpcTestProcedure(OnpcOnkyoTests.playFromDAB, "Onkyo: Play from DAB"),
  OnpcTestProcedure(OnpcOnkyoTests.changeVolume, "Onkyo: Change volume"),
  OnpcTestProcedure(OnpcOnkyoTests.groupUngroup, "Onkyo: Group/Ingroup"),
  OnpcTestProcedure(OnpcOnkyoTests.changeDeviceSettings, "Onkyo: Device settings"),
  OnpcTestProcedure(OnpcOnkyoTests.deviceDisplay, "Onkyo: Device display"),
  // Denon test
  OnpcTestProcedure(OnpcDenonTests.playFromUsb, "Denon: Play from USB"),
  OnpcTestProcedure(OnpcDenonTests.audioControlMain, "Denon: Audio Control for main zone"),
  OnpcTestProcedure(OnpcDenonTests.playFromQueue, "Denon: Play from Queue"),
  OnpcTestProcedure(OnpcDenonTests.testHeosFavorites, "Denon: Test HEOS favorites"),
  OnpcTestProcedure(OnpcDenonTests.playFromDeezer, "Denon: Play from Deezer"),
  OnpcTestProcedure(OnpcDenonTests.hideEmptyItems, "Denon: Hide empty items"),
  OnpcTestProcedure(OnpcDenonTests.changeListeningModes, "Denon: Change listening modes"),
  OnpcTestProcedure(OnpcDenonTests.playFromDAB, "Denon: Play from DAB"),
  OnpcTestProcedure(OnpcDenonTests.changeDeviceSettings, "Denon: Device settings"),
  OnpcTestProcedure(OnpcDenonTests.allZoneStereo, "Denon: All zone stereo"),
  OnpcTestProcedure(OnpcDenonTests.createPlayList, "Denon: Create playlist")
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Music Control Test', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);
    tu.preparePlatform("release-test.log");

    app.main();

    int count = 0, passed = 0;
    final List<String> failed = [];
    final DateTime startTime = DateTime.now();
    for (OnpcTestProcedure procedure in procedures) {
      count++;
      if (await procedure.run(tu)) {
        passed++;
      } else {
        failed.add(procedure.name);
      }
    }
    final DateTime endTime = DateTime.now();

    tu.startMethod("Summary");
    tu.log("Executed " + count.toString() + " procedures");
    tu.log("Total duration: " + endTime.difference(startTime).inMinutes.toString() + " minutes");
    tu.log("PASSED: " + passed.toString());
    tu.log("FAILED: " + failed.toString());
    tu.endMethod();
  });
}
