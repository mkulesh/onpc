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
// @dart=2.9
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/messages/AutoPowerMsg.dart";
import "../iscp/messages/DigitalFilterMsg.dart";
import "../iscp/messages/DimmerLevelMsg.dart";
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
import "../utils/Logging.dart";
import "../widgets/CustomDialogTitle.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

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
    static const List<String> UPDATE_TRIGGERS = [
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
        NetworkStandByMsg.CODE
    ];

    DeviceSettingsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

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
        final bool showAll = false;

        // Change the brightness level of the receiver display.
        if (showAll || ds.dimmerLevel.key != DimmerLevel.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_dimmer_level,
                ds.dimmerLevel.description,
                Strings.device_dimmer_level_help,
                DimmerLevelMsg.output(DimmerLevel.TOGGLE)));
        }

        // Digital Filter: You can switch the type of digital filter in the audio DAC.
        // You can choose "Slow" (gives the sound a soft and fluid feel), "Sharp"
        // (gives the sound more structure and firmer feel) or "Auto" (auto).
        if (showAll || ds.digitalFilter.key != DigitalFilter.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_digital_filter,
                ds.digitalFilter.description,
                Strings.device_digital_filter_help,
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
                Strings.device_music_optimizer,
                ds.musicOptimizer.description,
                Strings.device_music_optimizer_help,
                MusicOptimizerMsg.output(MusicOptimizer.TOGGLE)));
        }

        // Allows the unit to enter standby automatically when
        // the certain time of inactivity without any audio input elapses.
        // The time value depends on the receiver model.
        if (showAll || ds.autoPower.key != AutoPower.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_auto_power,
                ds.autoPower.description,
                Strings.device_auto_power_help,
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
                Strings.device_hdmi_cec,
                ds.hdmiCec.description,
                Strings.device_hdmi_cec_help,
                HdmiCecMsg.output(HdmiCec.TOGGLE)));
        }

        // Phase Matching Bass Boost function eliminates phase-shift between low- and mid-range
        // frequency bands above 300 Hz. Bass response is enhanced without compromising vocal clarity,
        // and that's something especially useful when playing music at low volume where bass and
        // high-frequency sounds are more difficult to hear.
        if (showAll || ds.phaseMatchingBass.key != PhaseMatchingBass.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_phase_matching_bass,
                ds.phaseMatchingBass.description,
                Strings.device_phase_matching_bass_help,
                PhaseMatchingBassMsg.output(PhaseMatchingBass.TOGGLE)));
        }

        // Allows the unit to enter standby automatically when
        // the specified time elapses.
        if (showAll || ds.sleepTime != SleepSetCommandMsg.NOT_APPLICABLE)
        {
            final String description = ds.sleepTime == SleepSetCommandMsg.SLEEP_OFF ?
                Strings.device_two_way_switch_off :
                ds.sleepTime.toString() + " " + Strings.device_sleep_time_minutes;
            rows.add(_buildRow(context,
                Strings.device_sleep_time,
                description,
                Strings.device_sleep_time_help,
                SleepSetCommandMsg.output(SleepSetCommandMsg.toggle(ds.sleepTime))));
        }

        // Speaker A/B selection. Works for Main zone and Zone 2 only.
        final int zone = state.getActiveZone;
        if (zone < 2)
        {
            final _SpeakerABStatus spState = _getSpeakerABStatus(ds.speakerA.key, ds.speakerB.key);
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
                    rows.add(_buildRow(context,
                        Strings.speaker_ab_command,
                        Strings.speaker_ab_command_ab_off,
                        Strings.speaker_ab_command_help,
                        SpeakerACommandMsg.output(zone, SpeakerACommand.ON),
                        postQueries: [
                            SpeakerACommandMsg.ZONE_COMMANDS[zone]
                        ]
                    ));
                    break;
                case _SpeakerABStatus.A_ONLY: // A_ONLY -> B_ONLY
                    rows.add(_buildRow(context,
                        Strings.speaker_ab_command,
                        Strings.speaker_ab_command_a_only,
                        Strings.speaker_ab_command_help,
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
                    rows.add(_buildRow(context,
                        Strings.speaker_ab_command,
                        Strings.speaker_ab_command_b_only,
                        Strings.speaker_ab_command_help,
                        SpeakerACommandMsg.output(zone, SpeakerACommand.ON),
                        postQueries: [
                            SpeakerACommandMsg.ZONE_COMMANDS[zone]
                        ]
                    ));
                    break;
                case _SpeakerABStatus.ON: // ON -> OFF (optional) -> A_ONLY
                    if (state.receiverInformation.model == "DTM-6")
                    {
                        rows.add(_buildRow(context,
                            Strings.speaker_ab_command,
                            Strings.speaker_ab_command_ab_on,
                            Strings.speaker_ab_command_help,
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
                        rows.add(_buildRow(context,
                            Strings.speaker_ab_command,
                            Strings.speaker_ab_command_ab_on,
                            Strings.speaker_ab_command_help,
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
                Strings.device_google_cast_analytics,
                ds.googleCastAnalytics.description,
                Strings.device_google_cast_analytics_help,
                GoogleCastAnalyticsMsg.output(GoogleCastAnalyticsMsg.toggle(ds.googleCastAnalytics.key))));
        }

        // Make small sounds easily heard. It is useful when you
        // need to reduce the volume while watching a movie late
        // night.
        if (showAll || ds.lateNightMode.key != LateNightMode.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_late_night,
                ds.lateNightMode.description,
                Strings.device_late_night_help,
                LateNightCommandMsg.output(LateNightMode.UP)));
        }

        // When this function is set to "On", you can turn on the power of
        // the unit via network using an application such as Enhanced Music
        // Controller that can control this unit.
        if (showAll || ds.networkStandBy.key != NetworkStandBy.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_network_standby,
                ds.networkStandBy.description,
                Strings.device_network_standby_help,
                null, tapHandler: _onNetworkStandBy));
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

    TableRow _buildRow(BuildContext context, final String title,
        final String value, final String description,
        final ISCPMessage cmd, {List<ISCPMessage> postMessages,
            List<String> postQueries, void Function(BuildContext context) tapHandler})
    {
        final Widget rowTitle = CustomTextLabel.small(title, padding: ActivityDimens.headerPadding);

        final Widget rowValue = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Expanded(
                    child: InkWell(
                        child: CustomTextLabel.normal(value, textAlign: TextAlign.center),
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
                    flex: 1),
                CustomImageButton.small(
                    Drawables.cmd_help,
                    Strings.device_parameter_help,
                    onPressed: ()
                    => _onParameterHelpButton(context, title, description),
                    isSelected: false,
                )
            ]
        );

        return TableRow(children: [rowTitle, rowValue]);
    }

    void _onToggleButton(BuildContext context, final ISCPMessage cmd, {List<ISCPMessage> postMessages, List<String> postQueries})
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

    void _onParameterHelpButton(BuildContext context, final String title, final String description)
    {
        Logging.info(this, "Parameter help button pressed");
        final ThemeData td = Theme.of(context);
        final Widget dialog = AlertDialog(
            title: CustomDialogTitle(title, Drawables.cmd_help),
            contentPadding: DialogDimens.contentPadding,
            content: CustomTextLabel.normal(description),
            actions: <Widget>[
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.button),
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
                    child: Text(Strings.action_cancel.toUpperCase(), style: td.textTheme.button),
                    onPressed: ()
                    {
                        Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(Strings.action_ok.toUpperCase(), style: td.textTheme.button),
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
