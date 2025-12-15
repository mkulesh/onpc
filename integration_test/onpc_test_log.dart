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

import 'dart:io';

import 'package:onpc/utils/Logging.dart';

class OnpcTestLog {
  final List<String> _testLog = [];
  final List<String> _stack = [];
  File? _fName;

  void setLogFile(String tName) {
    _fName = File(tName);
  }

  void startMethod(final String name, {bool clearStack = false}) {
    log("[START - " + name + "]");
    if (clearStack) {
      _stack.clear();
    }
    _stack.add(name);
  }

  void endMethod() {
    if (_stack.isNotEmpty) {
      final String name = _stack.removeLast();
      log("[END - " + name + "]");
    }
  }

  void log(final String text) {
    String info = "";
    _stack.forEach((e) => info += "    ");
    info += text;
    Logging.info(this, info);
    _testLog.add(info);
    if (_fName != null) {
      _fName!.writeAsStringSync(info + Platform.lineTerminator, mode: FileMode.append);
    }
  }
}
