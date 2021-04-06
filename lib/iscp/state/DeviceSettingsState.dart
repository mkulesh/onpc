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
// @dart=2.9
import "../../utils/Logging.dart";
import "../messages/AutoPowerMsg.dart";
import "../messages/DigitalFilterMsg.dart";
import "../messages/DimmerLevelMsg.dart";
import "../messages/EnumParameterMsg.dart";
import "../messages/GoogleCastAnalyticsMsg.dart";
import "../messages/HdmiCecMsg.dart";
import "../messages/LateNightCommandMsg.dart";
import "../messages/MusicOptimizerMsg.dart";
import "../messages/PhaseMatchingBassMsg.dart";
import "../messages/PrivacyPolicyStatusMsg.dart";
import "../messages/SleepSetCommandMsg.dart";
import "../messages/SpeakerACommandMsg.dart";
import "../messages/SpeakerBCommandMsg.dart";

class DeviceSettingsState
{
    EnumItem<DimmerLevel> _dimmerLevel;

    EnumItem<DimmerLevel> get dimmerLevel
    => _dimmerLevel;

    EnumItem<DigitalFilter> _digitalFilter;

    EnumItem<DigitalFilter> get digitalFilter
    => _digitalFilter;

    EnumItem<MusicOptimizer> _musicOptimizer;

    EnumItem<MusicOptimizer> get musicOptimizer
    => _musicOptimizer;

    EnumItem<AutoPower> _autoPower;

    EnumItem<AutoPower> get autoPower
    => _autoPower;

    EnumItem<HdmiCec> _hdmiCec;

    EnumItem<HdmiCec> get hdmiCec
    => _hdmiCec;

    EnumItem<PhaseMatchingBass> _phaseMatchingBass;

    EnumItem<PhaseMatchingBass> get phaseMatchingBass
    => _phaseMatchingBass;

    int _sleepTime;

    int get sleepTime
    => _sleepTime;

    EnumItem<SpeakerACommand> _speakerA;

    EnumItem<SpeakerACommand> get speakerA
    => _speakerA;

    EnumItem<SpeakerBCommand> _speakerB;

    EnumItem<SpeakerBCommand> get speakerB
    => _speakerB;

    EnumItem<GoogleCastAnalytics> _googleCastAnalytics;

    EnumItem<GoogleCastAnalytics> get googleCastAnalytics
    => _googleCastAnalytics;

    EnumItem<LateNightMode> _lateNightMode;

    EnumItem<LateNightMode> get lateNightMode
    => _lateNightMode;

    DeviceSettingsState()
    {
        clear();
    }

    List<String> getQueries(int zone)
    {
        Logging.info(this, "Requesting data for zone " + zone.toString() + "...");
        return [
            DimmerLevelMsg.CODE,
            DigitalFilterMsg.CODE,
            MusicOptimizerMsg.CODE,
            AutoPowerMsg.CODE,
            HdmiCecMsg.CODE,
            PhaseMatchingBassMsg.CODE,
            SleepSetCommandMsg.CODE,
            SpeakerACommandMsg.ZONE_COMMANDS[zone],
            SpeakerBCommandMsg.ZONE_COMMANDS[zone],
            GoogleCastAnalyticsMsg.CODE,
            PrivacyPolicyStatusMsg.CODE,
            LateNightCommandMsg.CODE
        ];
    }

    void clear()
    {
        _dimmerLevel = DimmerLevelMsg.ValueEnum.defValue;
        _digitalFilter = DigitalFilterMsg.ValueEnum.defValue;
        _musicOptimizer = MusicOptimizerMsg.ValueEnum.defValue;
        _autoPower = AutoPowerMsg.ValueEnum.defValue;
        _hdmiCec = HdmiCecMsg.ValueEnum.defValue;
        _phaseMatchingBass = PhaseMatchingBassMsg.ValueEnum.defValue;
        _sleepTime = SleepSetCommandMsg.NOT_APPLICABLE;
        _speakerA = SpeakerACommandMsg.ValueEnum.defValue;
        _speakerB = SpeakerBCommandMsg.ValueEnum.defValue;
        _googleCastAnalytics = GoogleCastAnalyticsMsg.ValueEnum.defValue;
        _lateNightMode = LateNightCommandMsg.ValueEnum.defValue;
    }

    bool processDimmerLevel(DimmerLevelMsg msg)
    {
        final bool changed = _dimmerLevel.key != msg.getValue.key;
        _dimmerLevel = msg.getValue;
        return changed;
    }

    bool processDigitalFilter(DigitalFilterMsg msg)
    {
        final bool changed = _digitalFilter.key != msg.getValue.key;
        _digitalFilter = msg.getValue;
        return changed;
    }

    bool processMusicOptimizer(MusicOptimizerMsg msg)
    {
        final bool changed = _musicOptimizer.key != msg.getValue.key;
        _musicOptimizer = msg.getValue;
        return changed;
    }

    bool processAutoPower(AutoPowerMsg msg)
    {
        final bool changed = _autoPower.key != msg.getValue.key;
        _autoPower = msg.getValue;
        return changed;
    }

    bool processHdmiCec(HdmiCecMsg msg)
    {
        final bool changed = _hdmiCec.key != msg.getValue.key;
        _hdmiCec = msg.getValue;
        return changed;
    }

    bool processPhaseMatchingBass(PhaseMatchingBassMsg msg)
    {
        final bool changed = _phaseMatchingBass.key != msg.getValue.key;
        _phaseMatchingBass = msg.getValue;
        return changed;
    }

    bool processSleepSet(SleepSetCommandMsg msg)
    {
        final bool changed = _sleepTime != msg.sleepTime;
        _sleepTime = msg.sleepTime;
        return changed;
    }

    bool processSpeakerACommand(SpeakerACommandMsg msg)
    {
        final bool changed = _speakerA.key != msg.getValue.key;
        _speakerA = msg.getValue;
        return changed;
    }

    bool processSpeakerBCommand(SpeakerBCommandMsg msg)
    {
        final bool changed = _speakerB.key != msg.getValue.key;
        _speakerB = msg.getValue;
        return changed;
    }

    bool processGoogleCastAnalytics(GoogleCastAnalyticsMsg msg)
    {
        final bool changed = _googleCastAnalytics.key != msg.getValue.key;
        _googleCastAnalytics = msg.getValue;
        return changed;
    }

    bool processLateNightCommand(LateNightCommandMsg msg)
    {
        final bool changed = _lateNightMode.key != msg.getValue.key;
        _lateNightMode = msg.getValue;
        return changed;
    }
}