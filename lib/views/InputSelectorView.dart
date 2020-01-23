/*
 * Copyright (C) 2019. Mikhail Kulesh
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

import "../config/CheckableItem.dart";
import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/InputSelectorMsg.dart";
import "../iscp/messages/ListTitleInfoMsg.dart";
import "../iscp/messages/OperationCommandMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
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
        Logging.info(this, "rebuild widget");

        final List<Widget> buttons = List<Widget>();

        final OperationCommandMsg commandTopMsg = OperationCommandMsg.output(
            ReceiverInformationMsg.DEFAULT_ACTIVE_ZONE, OperationCommand.TOP);

        buttons.add(CustomImageButton.small(
            commandTopMsg.getValue.icon,
            commandTopMsg.getValue.description,
            padding: EdgeInsets.symmetric(
                vertical: ButtonDimens.textButtonPadding,
                horizontal: MediaListDimens.itemPadding),
            onPressed: ()
            => stateManager.sendMessage(commandTopMsg, waitingForData: true),
            isEnabled: state.isOn && !state.mediaListState.isTopLayer()
        )
        );

        final List<Selector> sortedSelectors = _getSortedDeviceSelectors(
            false, state.mediaListState.inputType, state.receiverInformation.deviceSelectors);
        sortedSelectors.forEach((deviceSelector)
        {
            final EnumItem<InputSelector> selectorEnum =
            InputSelectorMsg.ValueEnum.valueByCode(deviceSelector.getId);
            if (selectorEnum.key != InputSelector.NONE)
            {
                final InputSelectorMsg cmd = InputSelectorMsg.output(state.getActiveZone, selectorEnum.key);
                buttons.add(CustomTextButton(
                    configuration.friendlyNames ? deviceSelector.getName : selectorEnum.description.toUpperCase(),
                    isEnabled: state.isOn,
                    isSelected: state.mediaListState.inputType.code == selectorEnum.code,
                    onPressed: ()
                    => stateManager.sendMessage(cmd, waitingForData: true))
                );
            }
        });

        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: buttons));
    }

    List<Selector> _getSortedDeviceSelectors(bool allItems, EnumItem<InputSelector> activeItem, final List<Selector> defaultItems)
    {
        final List<Selector> result = List<Selector>();
        final List<String> defItems = List<String>();
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