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
import 'package:onpc/iscp/EISCPMessage.dart';
import 'package:onpc/iscp/StateManager.dart';
import 'package:onpc/main.dart' as app;

import 'onpc_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simulation of the device display', (tester) async {
    final OnpcTestUtils tu = OnpcTestUtils(tester);
    app.main();

    await tu.stepDelayMs();
    await tu.openTab("RC");

    final List<String> special = [
      "83416972506C6179202020202020", // Music note airplay
      "1A4C6F7365722020202020202020", // Arrow song title
      "43656E746572203A202030906442", // Decimal decibel center level
      "432020202020203A2D3131956442", // C   :-11.5dB
      "824D792050726573657473202020"  // ?My Presets (up down arrows and folder icon)
    ];

    final List<String> messages = [
      "836F772050616972696E672E2E2E",
      "83772050616972696E672E2E2E20",
      "832050616972696E672E2E2E2020",
      "8350616972696E672E2E2E202020",
      "83616972696E672E2E2E20202020",
      "836972696E672E2E2E2020202020",
      "8372696E672E2E2E202020202020",
      "42442F4456442020202D36302E30",
      "43424C2F53415420202D36302E30",
      "4344202020202020202D36302E30",
      "5456202020202020202D36302E30",
      "50484F4E4F202020202D36302E30",
      "4E45542020202020202D36302E30",
      "424C5545544F4F54482D36302E30",
      "4368726F6D6563617320372F3130",
      "4368726F6D6563617320372F3130",
      "20436F6E6E656374696E672E2E2E",
      "1B4368726F6D6563617374206275",
      "4368726F6D656361737420627569",
      "68726F6D6563617374206275696C",
      "726F6D6563617374206275696C74",
      "6F6D6563617374206275696C742D",
      "6D6563617374206275696C742D69",
      "1A416E67656C2028666561742E20",
      "6563617374206275696C742D696E",
      "63617374206275696C742D696E20",
      "617374206275696C742D696E2020",
      "7374206275696C742D696E202020",
      "74206275696C742D696E20202020",
      "206275696C742D696E2020202020",
      "6275696C742D696E202020202020",
      "75696C742D696E20202020202020",
      "696C742D696E2020202020202020",
      "6C742D696E202020202020202020",
      "742D696E20202020202020202020",
      "2D696E2020202020202020202020",
      "696E202020202020202020202020",
      "6E20202020202020202020202020",
      "566F6C756D652020202D34352E30",
      "5456206541524320202D34352E30",
      "53797374656D2053657475702020",
      "4D43414343202020202020202020",
      "4E6574776F726B20202020202020",
      "496E2F4F75742041737369676E20",
      "537065616B657220202020202020",
      "417564696F2041646A7573742020",
      "536F757263652020202020202020",
      "4861726477617265202020202020",
      "4D697363656C6C616E656F757320",
      "5456204F75742F4F534420202020",
      "48444D4920496E70757420202020",
      "566964656F20496E707574202020",
      "4469676974616C20417564696F20",
      "416E616C6F6720417564696F2020",
      "496E70757420536B697020202020",
      "546F6E6520202020202020202020",
      "4C6576656C202020202020202020",
      "4F74686572202020202020202020",
      "566F6C756D652020202D34342E35",
      "5456206541524320202D34342E35",
      "566F6C756D652020202D34342E30",
      "566F6C756D652020202D34332E35",
      "566F6C756D652020202D34332E30",
      "566F6C756D652020202D34322E35",
      "5456206541524320202D34322E35",
      "5043202020202020202D34322E35",
      "476F6F676C654361732D34322E35",
      "5456202020202020202D34322E35",
      "425420415544494F202D34322E35"
    ];

    final StateManager sm = tu.getStateManager();

    for(String element in special) {
      final EISCPMessage raw = EISCPMessage.outputCat("s", "FLD", element);
      sm.injectIscpMessage(raw);
      await tu.stepDelayMs(delay: 2000);
    }

    for(String element in messages) {
      final EISCPMessage raw = EISCPMessage.outputCat("s", "FLD", element);
      sm.injectIscpMessage(raw);
      await tu.stepDelayMs(delay: 501);
    }
  });
}
