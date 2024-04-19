/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2023 by Mikhail Kulesh
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

import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../dialogs/RenameDialog.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/messages/AutoPowerMsg.dart";
import "../iscp/messages/DcpAudioRestorerMsg.dart";
import "../iscp/messages/DcpEcoModeMsg.dart";
import "../iscp/messages/DigitalFilterMsg.dart";
import "../iscp/messages/DimmerLevelMsg.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/GoogleCastAnalyticsMsg.dart";
import "../iscp/messages/HdmiCecMsg.dart";
import "../iscp/messages/LateNightCommandMsg.dart";
import "../iscp/messages/MusicOptimizerMsg.dart";
import "../iscp/messages/NetworkStandByMsg.dart";
import "../iscp/messages/PhaseMatchingBassMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/SleepSetCommandMsg.dart";
import "../iscp/messages/SpeakerACommandMsg.dart";
import "../iscp/messages/SpeakerBCommandMsg.dart";
import "../iscp/state/DeviceSettingsState.dart";
import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../widgets/ContextMenuListener.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

enum _ParameterContextMenu
{
    EDIT
}

enum _ParameterType
{
    DIMMER_LEVEL,
    DIGITAL_FILTER,
    MUSIC_OPTIMIZER,
    AUTO_POWER,
    HDMI_CEC,
    PHASE_MATCHING_BASS,
    SLEEP_TIME,
    SPEAKER_AB_COMMAND,
    GOOGLE_CAST_ANALYTICS,
    LATE_NIGHT_MODE,
    NETWORK_STANDBY,
    DCP_ECO_MODE,
    DCP_AUDIO_RESTORER
}

enum _SpeakerABStatus
{
    OFF,
    ON,
    A_ONLY,
    B_ONLY,
    NONE
}

class DeviceSettingsView extends UpdatableView
{
    static const DEVICE_SETTING_RENAMED = "DEVICE_SETTING_RENAMED";

    static const List<String> UPDATE_TRIGGERS = [
        DEVICE_SETTING_RENAMED,
        PowerStatusMsg.CODE,
        DimmerLevelMsg.CODE,
        DigitalFilterMsg.CODE,
        MusicOptimizerMsg.CODE,
        AutoPowerMsg.CODE,
        HdmiCecMsg.CODE,
        PhaseMatchingBassMsg.CODE,
        SleepSetCommandMsg.CODE,
        SpeakerACommandMsg.CODE,
        SpeakerBCommandMsg.CODE,
        GoogleCastAnalyticsMsg.CODE,
        LateNightCommandMsg.CODE,
        NetworkStandByMsg.CODE,
        DcpEcoModeMsg.CODE,
        DcpAudioRestorerMsg.CODE
    ];

    final bool showAll;

    DeviceSettingsView(final ViewContext viewContext, {this.showAll = false}) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        if (!state.isOn)
        {
            return SizedBox.shrink();
        }

        Logging.logRebuild(this);

        final List<TableRow> rows = [];

        final DeviceSettingsState ds = state.deviceSettingsState;

        // Change the brightness level of the receiver display.
        if (showAll || ds.dimmerLevel.key != DimmerLevel.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.DIMMER_LEVEL,
                Pair(Strings.device_dimmer_level, Strings.device_dimmer_level_help),
                ds.dimmerLevel,
                DimmerLevelMsg.output(DimmerLevel.TOGGLE)));
        }

        // Digital Filter: You can switch the type of digital filter in the audio DAC.
        // You can choose "Slow" (gives the sound a soft and fluid feel), "Sharp"
        // (gives the sound more structure and firmer feel) or "Auto" (auto).
        if (showAll || ds.digitalFilter.key != DigitalFilter.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.DIGITAL_FILTER,
                Pair(Strings.device_digital_filter, Strings.device_digital_filter_help),
                ds.digitalFilter,
                DigitalFilterMsg.output(DigitalFilter.TOGGLE)));
        }

        // Improve the quality of the compressed audio. Playback
        // sound of lossy compressed files such as MP3 will be
        // improved. The setting is effective with 2 ch signals with a
        // sampling frequency of 48 kHz or less. The setting is not
        // effective in the bitstream signals.
        if (showAll || ds.musicOptimizer.key != MusicOptimizer.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.MUSIC_OPTIMIZER,
                Pair(Strings.device_music_optimizer, Strings.device_music_optimizer_help),
                ds.musicOptimizer,
                MusicOptimizerMsg.output(MusicOptimizer.TOGGLE)));
        }

        // Allows the unit to enter standby automatically when
        // the certain time of inactivity without any audio input elapses.
        // The time value depends on the receiver model.
        if (showAll || ds.autoPower.key != AutoPower.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.AUTO_POWER,
                Pair(Strings.device_auto_power, Strings.device_auto_power_help),
                ds.autoPower,
                AutoPowerMsg.output(AutoPower.TOGGLE)));
        }

        // By connecting a device that complies with CEC (Consumer Electronics Control)
        // of the HDMI standard using an HDMI cable, a variety of linked operations
        // between devices are possible. This function enables various linking operations
        // with players, such as switching input selectors interlocking with a player,
        // adjusting the volume of this unit using the remote controller of a TV, and
        // automatically switching this unit to standby when the TV is turned off.
        if (showAll || ds.hdmiCec.key != HdmiCec.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.HDMI_CEC,
                Pair(Strings.device_hdmi_cec, Strings.device_hdmi_cec_help),
                ds.hdmiCec,
                HdmiCecMsg.toggle(ds.hdmiCec, state.protoType)));
        }

        // Phase Matching Bass Boost function eliminates phase-shift between low- and mid-range
        // frequency bands above 300 Hz. Bass response is enhanced without compromising vocal clarity,
        // and that's something especially useful when playing music at low volume where bass and
        // high-frequency sounds are more difficult to hear.
        if (showAll || ds.phaseMatchingBass.key != PhaseMatchingBass.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.PHASE_MATCHING_BASS,
                Pair(Strings.device_phase_matching_bass, Strings.device_phase_matching_bass_help),
                ds.phaseMatchingBass,
                PhaseMatchingBassMsg.output(PhaseMatchingBass.TOGGLE)));
        }

        // Allows the unit to enter standby automatically when
        // the specified time elapses.
        if (showAll || ds.sleepTime != SleepSetCommandMsg.NOT_APPLICABLE)
        {
            final String description = ds.sleepTime == SleepSetCommandMsg.SLEEP_OFF ?
                Strings.device_two_way_switch_off :
                ds.sleepTime.toString() + " " + Strings.device_sleep_time_minutes;
            rows.add(_buildRowExt(context,
                _ParameterType.SLEEP_TIME,
                Pair(Strings.device_sleep_time, Strings.device_sleep_time_help),
                Pair(ds.sleepTime.toString(), description),
                SleepSetCommandMsg.output(SleepSetCommandMsg.toggle(ds.sleepTime))));
        }

        // Speaker A/B selection. Works for Main zone and Zone 2 only.
        final int zone = state.getActiveZone;
        if (zone < 2)
        {
            final _SpeakerABStatus spState = _getSpeakerABStatus(ds.speakerA.key, ds.speakerB.key);
            final Pair<String, String> name = Pair(Strings.speaker_ab_command, Strings.speaker_ab_command_help);
            // OFF -> A_ONLY -> B_ONLY -> ON -> OFF (optional) -> A_ONLY -> B_ONLY -> ON -> ...
            switch (spState)
            {
                case _SpeakerABStatus.NONE:
                    if (showAll)
                    {
                        continue showAllCase;
                    }
                    break;
                showAllCase:
                case _SpeakerABStatus.OFF: // OFF -> A_ONLY
                    rows.add(_buildRowExt(context,
                        _ParameterType.SPEAKER_AB_COMMAND, name,
                        Pair("OFF", Strings.speaker_ab_command_ab_off),
                        SpeakerACommandMsg.output(zone, SpeakerACommand.ON),
                        postQueries: [
                            SpeakerACommandMsg.ZONE_COMMANDS[zone]
                        ]
                    ));
                    break;
                case _SpeakerABStatus.A_ONLY: // A_ONLY -> B_ONLY
                    rows.add(_buildRowExt(context,
                        _ParameterType.SPEAKER_AB_COMMAND, name,
                        Pair("A_ONLY", Strings.speaker_ab_command_a_only),
                        SpeakerBCommandMsg.output(zone, SpeakerBCommand.ON),
                        postMessages: [
                            SpeakerACommandMsg.output(zone, SpeakerACommand.OFF)
                        ],
                        postQueries: [
                            SpeakerACommandMsg.ZONE_COMMANDS[zone],
                            SpeakerBCommandMsg.ZONE_COMMANDS[zone]
                        ]
                    ));
                    break;
                case _SpeakerABStatus.B_ONLY: // B_ONLY -> ON
                    rows.add(_buildRowExt(context,
                        _ParameterType.SPEAKER_AB_COMMAND, name,
                        Pair("B_ONLY", Strings.speaker_ab_command_b_only),
                        SpeakerACommandMsg.output(zone, SpeakerACommand.ON),
                        postQueries: [
                            SpeakerACommandMsg.ZONE_COMMANDS[zone]
                        ]
                    ));
                    break;
                case _SpeakerABStatus.ON: // ON -> OFF (optional) -> A_ONLY
                    if (state.receiverInformation.model == "DTM-6")
                    {
                        rows.add(_buildRowExt(context,
                            _ParameterType.SPEAKER_AB_COMMAND, name,
                            Pair("ON", Strings.speaker_ab_command_ab_on),
                            SpeakerACommandMsg.output(zone, SpeakerACommand.OFF),
                            postMessages: [
                                SpeakerBCommandMsg.output(zone, SpeakerBCommand.OFF)
                            ],
                            postQueries: [
                                SpeakerACommandMsg.ZONE_COMMANDS[zone],
                                SpeakerBCommandMsg.ZONE_COMMANDS[zone]
                            ]
                        ));
                    }
                    else
                    {
                        rows.add(_buildRowExt(context,
                            _ParameterType.SPEAKER_AB_COMMAND, name,
                            Pair("ON", Strings.speaker_ab_command_ab_on),
                            SpeakerBCommandMsg.output(zone, SpeakerBCommand.OFF),
                            postQueries: [
                                SpeakerBCommandMsg.ZONE_COMMANDS[zone]
                            ]
                        ));
                    }
                    break;
            }
        }

        // Controls the collection of marketing and analytics data when using Google Cast.
        // To protect the privacy, keep this setting Off.
        if (showAll || ds.googleCastAnalytics.key != GoogleCastAnalytics.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.GOOGLE_CAST_ANALYTICS,
                Pair(Strings.device_google_cast_analytics, Strings.device_google_cast_analytics_help),
                ds.googleCastAnalytics,
                GoogleCastAnalyticsMsg.output(GoogleCastAnalyticsMsg.toggle(ds.googleCastAnalytics.key))));
        }

        // Make small sounds easily heard. It is useful when you
        // need to reduce the volume while watching a movie late
        // night.
        if (showAll || ds.lateNightMode.key != LateNightMode.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.LATE_NIGHT_MODE,
                Pair(Strings.device_late_night, Strings.device_late_night_help),
                ds.lateNightMode,
                LateNightCommandMsg.output(LateNightMode.UP)));
        }

        // When this function is set to "On", you can turn on the power of
        // the unit via network using an application such as Enhanced Music
        // Controller that can control this unit.
        if (showAll || ds.networkStandBy.key != NetworkStandBy.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.NETWORK_STANDBY,
                Pair(Strings.device_network_standby, Strings.device_network_standby_help),
                ds.networkStandBy,
                null, tapHandler: _onNetworkStandBy));
        }

        // DCP ECO mode
        if (showAll || ds.dcpEcoMode.key != DcpEcoMode.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.DCP_ECO_MODE,
                Pair(Strings.device_dcp_eco_mode, Strings.device_dcp_eco_mode_help),
                ds.dcpEcoMode,
                DcpEcoModeMsg.toggle(ds.dcpEcoMode)));
        }

        // DCP audio restorer
        if (showAll || ds.dcpAudioRestorer.key != DcpAudioRestorer.NONE)
        {
            rows.add(_buildRow(context,
                _ParameterType.DCP_AUDIO_RESTORER,
                Pair(Strings.device_dcp_audio_restorer, Strings.device_dcp_audio_restorer_help),
                ds.dcpAudioRestorer,
                DcpAudioRestorerMsg.toggle(ds.dcpAudioRestorer)));
        }

        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FractionColumnWidth(0.35);
        columnWidths[1] = FractionColumnWidth(0.65);

        final Widget table = Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                CustomTextLabel.small(Strings.device_settings, padding: ActivityDimens.headerPadding),
                table
            ]);
    }

    TableRow _buildRow<T>(BuildContext context,
        final _ParameterType type,
        final Pair<String, String> name,
        final EnumItem<T> value,
        final ISCPMessage? cmd, {List<ISCPMessage>? postMessages,
            List<String>? postQueries, void Function(BuildContext context)? tapHandler})
    {
        return _buildRowExt(context,
            type,
            name,
            Pair(value.getCode, value.description),
            cmd,
            postMessages: postMessages,
            postQueries: postQueries,
            tapHandler: tapHandler);
    }

    TableRow _buildRowExt(BuildContext context,
        final _ParameterType type,
        final Pair<String, String> name,
        final Pair<String, String> value,
        final ISCPMessage? cmd, {List<ISCPMessage>? postMessages,
            List<String>? postQueries, void Function(BuildContext context)? tapHandler})
    {
        final Widget rowTitle = CustomTextLabel.small(name.item1, padding: ActivityDimens.headerPadding);

        final Pair<String, String> newValue = Pair(value.item1,
            viewContext.configuration.appSettings.readDeviceSetting(
                Convert.enumToString(type), value.item1, value.item2));

        final Widget paramValue = ContextMenuListener<_ParameterContextMenu>(
            child: InkWell(
                child: CustomTextLabel.normal(newValue.item2, textAlign: TextAlign.center),
                onTap: ()
                {
                    if (state.isOn)
                    {
                        FocusScope.of(context).unfocus();
                        if (tapHandler != null)
                        {
                            tapHandler(context);
                        }
                        else
                        {
                            _onToggleButton(context, cmd,
                                postMessages: postMessages,
                                postQueries: postQueries);
                        }
                    }
                }),
            menuName: name.item1,
            menuItems: [Pair(Strings.pref_item_update, _ParameterContextMenu.EDIT)],
            onItemSelected: (BuildContext c, _ParameterContextMenu m)
            {
                if (m == _ParameterContextMenu.EDIT)
                {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext c)
                        => RenameDialog(newValue.item2, (newName)
                            {
                                viewContext.configuration.appSettings.saveDeviceSetting(
                                    Convert.enumToString(type), value.item1, newName);
                                viewContext.stateManager.triggerStateEvent(DEVICE_SETTING_RENAMED);
                            })
                    );
                }
            }
        );

        final Widget rowValue = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Expanded(child: paramValue, flex: 1),
                CustomImageButton.small(
                    Drawables.cmd_help,
                    Strings.device_parameter_help,
                    isEnabled: true,
                    onPressed: ()
                    => _onParameterHelpButton(context, name),
                    isSelected: false,
                )
            ]
        );

        return TableRow(children: [rowTitle, rowValue]);
    }

    void _onToggleButton(BuildContext context, final ISCPMessage? cmd, {List<ISCPMessage>? postMessages, List<String>? postQueries})
    {
        if (cmd != null)
        {
            stateManager.sendMessage(cmd);
        }
        if (postMessages != null)
        {
            postMessages.forEach((p) => stateManager.sendMessage(p));
        }
        if (postQueries != null)
        {
            stateManager.sendQueries(postQueries);
        }
    }

    void _onParameterHelpButton(BuildContext context, final Pair<String, String> name)
    {
        Logging.info(this, "Parameter help button pressed");
        final ThemeData td = Theme.of(context);
        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(name.item1, Drawables.cmd_help),
            contentPadding: DialogDimens.contentPadding,
            content: CustomTextLabel.normal(name.item2),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }
                )
            ]
        );

        showDialog(
            context: context,
            builder: (BuildContext context)
            => dialog);
    }

    _SpeakerABStatus _getSpeakerABStatus(SpeakerACommand speakerA, SpeakerBCommand speakerB)
    {
        // For some devices like TX-8050, the speakerB value is often missing.
        // If speakerA value is valid, and speakerB is missing, assume that
        // speakerB os OFF
        if (speakerA != SpeakerACommand.NONE && speakerB == SpeakerBCommand.NONE)
        {
            speakerB = SpeakerBCommand.OFF;
        }
        if (speakerA == SpeakerACommand.OFF && speakerB == SpeakerBCommand.OFF)
        {
            return _SpeakerABStatus.OFF;
        }
        else if (speakerA == SpeakerACommand.ON && speakerB == SpeakerBCommand.ON)
        {
            return _SpeakerABStatus.ON;
        }
        else if (speakerA == SpeakerACommand.ON && speakerB == SpeakerBCommand.OFF)
        {
            return _SpeakerABStatus.A_ONLY;
        }
        else if (speakerA != SpeakerACommand.ON && speakerB == SpeakerBCommand.ON)
        {
            return _SpeakerABStatus.B_ONLY;
        }
        return _SpeakerABStatus.NONE;
    }

    void _onNetworkStandBy(BuildContext context)
    {
        if (state.deviceSettingsState.networkStandBy.key == NetworkStandBy.OFF)
        {
            stateManager.sendMessage(NetworkStandByMsg.output(NetworkStandBy.ON));
            return;
        }

        final ThemeData td = Theme.of(context);
        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(Strings.device_network_standby, Drawables.cmd_help),
            contentPadding: DialogDimens.contentPadding,
            content: CustomTextLabel.normal(Strings.device_network_standby_confirm),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.labelLarge),
                    onPressed: ()
                    {
                        if (state.isOn)
                        {
                            stateManager.sendMessage(
                                NetworkStandByMsg.output(NetworkStandBy.OFF));
                        }
                        Navigator.of(context).pop();
                    }),
            ]
        );

        showDialog(
            context: context,
            builder: (BuildContext context)
            => dialog);
    }
}
