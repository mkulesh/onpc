/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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
import "../iscp/ISCPMessage.dart";
import "../iscp/messages/AutoPowerMsg.dart";
import "../iscp/messages/DigitalFilterMsg.dart";
import "../iscp/messages/DimmerLevelMsg.dart";
import "../iscp/messages/GoogleCastAnalyticsMsg.dart";
import "../iscp/messages/HdmiCecMsg.dart";
import "../iscp/messages/MusicOptimizerMsg.dart";
import "../iscp/messages/PhaseMatchingBassMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/SleepSetCommandMsg.dart";
import "../iscp/messages/SpeakerACommandMsg.dart";
import "../iscp/messages/SpeakerBCommandMsg.dart";
import "../iscp/state/DeviceSettingsState.dart";
import "../utils/Logging.dart";
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
        GoogleCastAnalyticsMsg.CODE
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

        if (ds.dimmerLevel.key != DimmerLevel.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_dimmer_level,
                ds.dimmerLevel.description,
                Strings.device_dimmer_level_toggle,
                DimmerLevelMsg.output(DimmerLevel.TOGGLE)));
        }

        if (ds.digitalFilter.key != DigitalFilter.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_digital_filter,
                ds.digitalFilter.description,
                Strings.device_digital_filter_toggle,
                DigitalFilterMsg.output(DigitalFilter.TOGGLE)));
        }

        if (ds.musicOptimizer.key != MusicOptimizer.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_music_optimizer,
                ds.musicOptimizer.description,
                Strings.device_two_way_switch_toggle,
                MusicOptimizerMsg.output(MusicOptimizer.TOGGLE)));
        }

        if (ds.autoPower.key != AutoPower.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_auto_power,
                ds.autoPower.description,
                Strings.device_two_way_switch_toggle,
                AutoPowerMsg.output(AutoPower.TOGGLE)));
        }

        if (ds.hdmiCec.key != HdmiCec.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_hdmi_cec,
                ds.hdmiCec.description,
                Strings.device_two_way_switch_toggle,
                HdmiCecMsg.output(HdmiCec.TOGGLE)));
        }

        if (ds.phaseMatchingBass.key != PhaseMatchingBass.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_phase_matching_bass,
                ds.phaseMatchingBass.description,
                Strings.device_two_way_switch_toggle,
                PhaseMatchingBassMsg.output(PhaseMatchingBass.TOGGLE)));
        }

        if (ds.sleepTime != SleepSetCommandMsg.NOT_APPLICABLE)
        {
            final String description = ds.sleepTime == SleepSetCommandMsg.SLEEP_OFF ?
                Strings.device_two_way_switch_off :
                ds.sleepTime.toString() + " " + Strings.device_sleep_time_minutes;
            rows.add(_buildRow(context,
                Strings.device_sleep_time,
                description,
                Strings.device_two_way_switch_toggle,
                SleepSetCommandMsg.output(SleepSetCommandMsg.toggle(ds.sleepTime))));
        }

        // Speaker A/B (For Main zone and Zone 2 only)
        final int zone = state.getActiveZone;
        if (zone < 2)
        {
            final _SpeakerABStatus spState = _getSpeakerABStatus(ds.speakerA.key, ds.speakerB.key);
            // OFF -> A_ONLY -> B_ONLY -> ON -> OFF (optional) -> A_ONLY -> B_ONLY -> ON -> ...
            switch (spState)
            {
                case _SpeakerABStatus.OFF: // OFF -> A_ONLY
                    rows.add(_buildRow(context,
                        Strings.speaker_ab_command,
                        Strings.speaker_ab_command_ab_off,
                        Strings.speaker_ab_command_toggle,
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
                        Strings.speaker_ab_command_toggle,
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
                        Strings.speaker_ab_command_toggle,
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
                            Strings.speaker_ab_command_toggle,
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
                            Strings.speaker_ab_command_toggle,
                            SpeakerBCommandMsg.output(zone, SpeakerBCommand.OFF),
                            postQueries: [
                                SpeakerBCommandMsg.ZONE_COMMANDS[zone]
                            ]
                        ));
                    }
                    break;
                case _SpeakerABStatus.NONE:
                    // nothing to do
                    break;
            }
        }

        if (ds.googleCastAnalytics.key != GoogleCastAnalytics.NONE)
        {
            rows.add(_buildRow(context,
                Strings.device_google_cast_analytics,
                ds.googleCastAnalytics.description,
                Strings.device_two_way_switch_toggle,
                GoogleCastAnalyticsMsg.output(GoogleCastAnalyticsMsg.toggle(ds.googleCastAnalytics.key))));
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
        final String value, final buttonDescription,
        final ISCPMessage cmd, {List<ISCPMessage> postMessages, List<String> postQueries})
    {
        final bool isEnabled = stateManager.state.isOn;

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
                            if (isEnabled)
                            {
                                _onPress(context, cmd, postMessages: postMessages, postQueries: postQueries);
                            }
                        }),
                    flex: 1),
                CustomImageButton.small(
                    Drawables.wrap_around,
                    buttonDescription,
                    onPressed: ()
                    {
                        if (isEnabled)
                        {
                            _onPress(context, cmd, postMessages: postMessages, postQueries: postQueries);
                        }
                    },
                    isEnabled: isEnabled,
                    isSelected: false,
                )
            ]
        );

        return TableRow(children: [rowTitle, rowValue]);
    }

    void _onPress(BuildContext context, final ISCPMessage cmd, {List<ISCPMessage> postMessages, List<String> postQueries})
    {
        FocusScope.of(context).unfocus();
        stateManager.sendMessage(cmd);
        if (postMessages != null)
        {
            postMessages.forEach((p) => stateManager.sendMessage(p));
        }
        if (postQueries != null)
        {
            stateManager.sendQueries(postQueries);
        }
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
}
