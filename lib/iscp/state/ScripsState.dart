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

import 'package:collection/collection.dart';

import '../../config/CfgFavoriteShortcuts.dart';
import '../../config/CfgTabSettings.dart';
import '../../utils/Convert.dart';
import '../../utils/Logging.dart';
import '../../utils/Pair.dart';
import '../../utils/Platform.dart';
import '../ISCPMessage.dart';
import '../MessageChannel.dart';
import '../State.dart';
import '../messages/DcpMediaContainerMsg.dart';
import '../scripts/AutoPower.dart';
import '../scripts/HandleDcpDuplicates.dart';
import '../scripts/MessageScript.dart';
import '../scripts/MessageScriptIf.dart';
import '../scripts/RequestListeningMode.dart';

enum ScriptType
{
    CONFIG,
    RUNTIME
}

class ScriptsState
{
    final List<Pair<ScriptType, MessageScriptIf>> _messageScripts = [];
    MessageScript? _intentHost;

    MessageScript? get intentHost
    => _intentHost;

    void addScript(ScriptType type, MessageScriptIf script)
    {
        final Pair<ScriptType, MessageScriptIf>? item =
            _messageScripts.firstWhereOrNull((m) =>
                m.item2.runtimeType.toString() == script.runtimeType.toString());
        if (item != null)
        {
            Logging.info(this, "Skipped addition for " + script.runtimeType.toString() + ": already added");
        }
        else
        {
            Logging.info(this, "Add script " + script.runtimeType.toString() + " with type " + Convert.enumToString(type));
            _messageScripts.add(Pair(type, script));
        }
        Logging.info(this, "    Known scripts: " + _messageScripts.toString());
    }

    void clearScripts(ScriptType type)
    {
        if (_messageScripts.isNotEmpty)
        {
            _messageScripts.removeWhere((s) => s.item1 == type);
            Logging.info(this, "Delete scripts of type " + Convert.enumToString(type));
            Logging.info(this, "    Known scripts: " + _messageScripts.toString());
        }
    }

    void startScripts(final State state, final MessageChannel channel)
    {
        Logging.info(this, "Start scripts " + _messageScripts.toString() + " for channel " + channel.toString());
        _messageScripts.forEach((script)
        {
            if (script.item2.initialize(state, channel))
            {
                script.item2.start(state, channel);
            }
        });

        // After scripts are started, no need to hold intent host
        _intentHost = null;
    }

    void processScripts(final ISCPMessage msg, final State state, final MessageChannel channel)
    => _messageScripts.forEach((script)
    {
        if (script.item2.isValid(state.protoType))
        {
            script.item2.processMessage(msg, state, channel);
        }
    });

    void applyShortcut(final Shortcut shortcut, final State state, final MessageChannel channel)
    {
        Logging.info(this, "selected favorite shortcut: " + shortcut.toString());
        final MessageScript script = MessageScript(shortcut: shortcut);
        _messageScripts.removeWhere((s) => s.item2 is MessageScript);
        addScript(ScriptType.RUNTIME, script);
        if (script.initialize(state, channel))
        {
            script.start(state, channel);
        }
    }

    void handleDcpDuplicates(final List<DcpMediaContainerMsg> items,
        final State state,
        final MessageChannel channel,
        final OnHandleDcpDuplicatesFinished onFinished)
    {
        Logging.info(this, "handle DCP duplicates for " + items.length.toString() + " items");
        final HandleDcpDuplicates script = HandleDcpDuplicates(items, onFinished);
        _messageScripts.removeWhere((s) => s.item2 is HandleDcpDuplicates);
        addScript(ScriptType.RUNTIME, script);
        if (script.initialize(state, channel))
        {
            script.start(state, channel);
        }
    }

    AppControl? updateScripts({bool autoPower = false, final String? intent, final List<Shortcut>? shortcuts})
    {
        AppControl? retValue;
        clearScripts(ScriptType.CONFIG);
        clearScripts(ScriptType.RUNTIME);
        addScript(ScriptType.CONFIG, RequestListeningMode());
        if (autoPower)
        {
            addScript(ScriptType.CONFIG, AutoPower(AutoPowerMode.POWER_ON));
        }
        if (intent != null)
        {
            if (intent == Platform.SHORTCUT_AUTO_POWER)
            {
                addScript(ScriptType.RUNTIME, AutoPower(AutoPowerMode.POWER_ON));
            }
            else if (intent == Platform.SHORTCUT_ALL_STANDBY)
            {
                addScript(ScriptType.RUNTIME, AutoPower(AutoPowerMode.ALL_STANDBY));
            }
            else if (intent.contains(Platform.WIDGET_SHORTCUT) && shortcuts != null)
            {
                final List<String> tokens = intent.split(":");
                if (tokens.length > 1)
                {
                    final Shortcut? shortcut = shortcuts.firstWhereOrNull(
                            (s) => s.id == ISCPMessage.nonNullInteger(tokens[1], 10, -1));
                    if (shortcut != null)
                    {
                        addScript(ScriptType.RUNTIME, MessageScript(shortcut: shortcut));
                        retValue = AppControl.MEDIA_LIST;
                    }
                }
            }
            else if (intent.contains(MessageScript.SCRIPT_NAME))
            {
                final MessageScript messageScript = MessageScript(intent: intent);
                addScript(ScriptType.RUNTIME, messageScript);
                _intentHost = messageScript;
            }
        }
        return retValue;
    }

    void removeScript(MessageScriptIf script)
    {
        Logging.info(this, "Delete scripts of type " + script.runtimeType.toString());
        _messageScripts.removeWhere((m) =>
            m.item2.runtimeType.toString() == script.runtimeType.toString());
        Logging.info(this, "    Known scripts: " + _messageScripts.toString());
    }
}