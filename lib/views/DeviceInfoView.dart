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

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/FirmwareUpdateMsg.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/GoogleCastVersionMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/state/ReceiverInformation.dart";
import "../utils/Logging.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextField.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class DeviceInfoView extends StatefulWidget
{
    final ViewContext _viewContext;

    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        ReceiverInformationMsg.CODE,
        PowerStatusMsg.CODE,
        FriendlyNameMsg.CODE,
        GoogleCastVersionMsg.CODE,
        FirmwareUpdateMsg.CODE
    ];

    DeviceInfoView(this._viewContext);

    @override _DeviceInfoViewState createState()
    => _DeviceInfoViewState(_viewContext, UPDATE_TRIGGERS);
}

class _DeviceInfoViewState extends WidgetStreamState<DeviceInfoView>
{
    TextEditingController _friendlyNameController;

    _DeviceInfoViewState(final ViewContext _viewContext, final List<String> _updateTriggers) : super(_viewContext, _updateTriggers);

    String get friendlyNameValue
    => state.isConnected ? state.receiverInformation.getDeviceName(true) : "";

    @override
    void initState()
    {
        super.initState();
        _friendlyNameController = TextEditingController();
        _friendlyNameController.text = friendlyNameValue;
    }

    @override
    void dispose()
    {
        _friendlyNameController.dispose();
        super.dispose();
    }

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this.widget, "rebuild widget");

        final List<TableRow> rows = List();

        final bool isData = state.isConnected;
        final ReceiverInformation ri = state.receiverInformation;

        if (ri.isFriendlyName)
        {
            if (_friendlyNameController.text.isEmpty)
            {
                _friendlyNameController.text = friendlyNameValue;
            }

            final Widget friendlyName = Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    Expanded(
                        child: CustomTextField(_friendlyNameController,
                            isFocused: false,
                            onPressed: ()
                            => _submitDeviceName(context, state.isConnected && state.isOn)),
                        flex: 1),
                    CustomImageButton.small(
                        Drawables.cmd_friendly_name,
                        Strings.device_change_friendly_name,
                        onPressed: ()
                        => _submitDeviceName(context, state.isConnected && state.isOn),
                        isEnabled: isData && stateManager.state.isOn,
                        isSelected: false,
                    )
                ]);

            // Friendly name
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.device_friendly_name),
                friendlyName
            ]));
        }

        if (ri.isReceiverInformation)
        {
            // Brand
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.device_brand),
                CustomTextLabel.normal(isData ? ri.brand : "")
            ]));

            // Model
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.device_model),
                CustomTextLabel.normal(isData ? ri.model : "")
            ]));

            // Year
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.device_year),
                CustomTextLabel.normal(isData ? ri.year : "")
            ]));

            // Firmware update status
            Widget firmwareInfo = CustomTextLabel.normal(isData ? ri.firmaware : "");

            if (ri.firmwareStatus.key != FirmwareUpdate.NONE)
            {
                firmwareInfo = Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        firmwareInfo,
                        CustomTextLabel.small(ri.firmwareStatus.description)
                    ]);
            }

            if (ri.firmwareStatus.key != FirmwareUpdate.ACTUAL &&
                ri.firmwareStatus.key != FirmwareUpdate.NONE)
            {
                final bool isEnabled = ri.firmwareStatus.key == FirmwareUpdate.NEW_VERSION ||
                    ri.firmwareStatus.key == FirmwareUpdate.NEW_VERSION_FORCE;
                firmwareInfo = Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        Expanded(
                            child: firmwareInfo,
                            flex: 1),
                        CustomImageButton.small(
                            Drawables.cmd_firmware_update,
                            Strings.device_firmware_net,
                            onPressed: ()
                            {
                                if (isData && stateManager.state.isOn)
                                {
                                    stateManager.sendMessage(FirmwareUpdateMsg.output(FirmwareUpdate.NET));
                                }
                            },
                            isEnabled: isData && stateManager.state.isOn && isEnabled,
                            isSelected: false,
                        )
                    ]);
            }

            // Firmware
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.device_firmware),
                firmwareInfo
            ]));

            // Google cast
            rows.add(TableRow(children: [
                _buildRowTitle(Strings.google_cast_version),
                CustomTextLabel.normal(isData ? ri.googleCastVersion : "")
            ]));
        }

        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FractionColumnWidth(0.37);
        columnWidths[1] = FractionColumnWidth(0.63);

        final Widget table = Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );

        final Widget title = Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Expanded(
                    child: CustomTextLabel.small(Strings.device_info, textAlign:TextAlign.left),
                    flex: 1),
                Expanded(
                    child: CustomTextLabel.small(stateManager.getAddressAndPort(), textAlign:TextAlign.right),
                    flex: 1),
            ]);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                title,
                CustomDivider(),
                table
            ]);
    }

    Widget _buildRowTitle(final String title)
    => CustomTextLabel.small(title, padding: DeviceInfoDimens.rowPadding);

    _submitDeviceName(BuildContext context, final bool isEnabled)
    {
        if (isEnabled)
        {
            stateManager.sendMessage(FriendlyNameMsg.output(_friendlyNameController.text));
            FocusScope.of(context).unfocus();
        }
    }
}