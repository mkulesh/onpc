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

import "../config/CheckableItem.dart";
import "../config/Configuration.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import '../widgets/TextButtonScroll.dart';
import "../widgets/CustomTextButton.dart";
import "UpdatableView.dart";


class InputSelectorView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.ZONE_EVENT,
        PowerStatusMsg.CODE,
        ReceiverInformationMsg.CODE,
        InputSelectorMsg.CODE,
        ListTitleInfoMsg.CODE
    ];

    InputSelectorView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final List<CustomTextButton> buttons = [];
        CustomTextButton selectedButton;

        final List<Selector> sortedSelectors = _getSortedDeviceSelectors(
            false, state.mediaListState.inputType, state.receiverInformation.deviceSelectors);
        sortedSelectors.forEach((deviceSelector)
        {
            final EnumItem<InputSelector> selectorEnum =
                InputSelectorMsg.ValueEnum.valueByCode(deviceSelector.getId);
            // #265 Add new input selector "SOURCE":
            // Ignore SOURCE input for all not allowed zones
            final bool activeForZone = selectorEnum.key == InputSelector.SOURCE ?
                deviceSelector.isActiveForZone(state.getActiveZone) : true;
            if (selectorEnum.key != InputSelector.NONE && activeForZone)
            {
                final InputSelectorMsg cmd = InputSelectorMsg.output(state.getActiveZone, selectorEnum.key);
                final String name = configuration.deviceSelectorName(selectorEnum,
                    useFriendlyName: configuration.friendlyNames,
                    friendlyName: deviceSelector.getName);
                final bool isSelected = state.isOn && state.mediaListState.inputType.code == selectorEnum.code;
                final Widget button = CustomTextButton(name,
                    isEnabled: state.isConnected,
                    isSelected: isSelected,
                    onPressed: ()
                    {
                        if (!state.isOn)
                        {
                            stateManager.sendMessage(PowerStatusMsg.output(state.getActiveZone, PowerStatus.ON));
                        }
                        stateManager.sendMessage(cmd, waitingForData: true);
                    });
                if (isSelected)
                {
                    selectedButton = button;
                }
                buttons.add(button);
            }
        });

        return buttons.isEmpty ? SizedBox.shrink() : TextButtonScroll(buttons, selectedButton);
    }

    List<Selector> _getSortedDeviceSelectors(bool allItems, EnumItem<InputSelector> activeItem, final List<Selector> defaultItems)
    {
        final List<Selector> result = [];
        final List<String> defItems = [];
        defaultItems.forEach((i) => defItems.add(i.getId));
        final String par = configuration.getModelDependentParameter(Configuration.SELECTED_DEVICE_SELECTORS);
        for (CheckableItem sp in CheckableItem.readFromPreference(configuration, par, defItems))
        {
            final bool visible = allItems || sp.checked ||
                (activeItem.key != InputSelector.NONE && activeItem.getCode == sp.code);
            for (Selector i in defaultItems)
            {
                if (visible && i.getId == sp.code)
                {
                    result.add(i);
                }
            }
        }
        return result;
    }
}