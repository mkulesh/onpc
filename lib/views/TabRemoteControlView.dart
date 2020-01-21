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
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/SetupOperationCommandMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class TabRemoteControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        PowerStatusMsg.CODE
    ];

    static final SetupOperationCommandMsg _setupQuickCmd = SetupOperationCommandMsg.output(SetupOperationCommand.QUICK);
    static final SetupOperationCommandMsg _setupSetupCmd = SetupOperationCommandMsg.output(SetupOperationCommand.MENU);
    static final SetupOperationCommandMsg _setupExitCmd = SetupOperationCommandMsg.output(SetupOperationCommand.EXIT);

    TabRemoteControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");

        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FlexColumnWidth();
        columnWidths[1] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[2] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[3] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[4] = FlexColumnWidth();

        // Top rows: quick menu, setup, return
        final List<TableRow> topRows = List();
        topRows.add(TableRow(children: [
            SizedBox.shrink(),
            InkWell(
                child: CustomTextLabel.small(Strings.cmd_description_quick_menu, textAlign: TextAlign.center),
                onTap: () => stateManager.sendMessage(_setupQuickCmd)
            ),
            InkWell(
                child: CustomTextLabel.small(Strings.cmd_description_setup, textAlign: TextAlign.center),
                onTap: () => stateManager.sendMessage(_setupSetupCmd)
            ),
            InkWell(
                child: CustomTextLabel.small(Strings.cmd_description_return, textAlign: TextAlign.center),
                onTap: () => stateManager.sendMessage(_setupExitCmd)
            ),
            SizedBox.shrink()
        ]));
        topRows.add(TableRow(children: [
            SizedBox.shrink(),
            _buildBtn(_setupQuickCmd),
            _buildBtn(_setupSetupCmd),
            _buildBtn(_setupExitCmd),
            SizedBox.shrink()
        ]));

        // Bottom rows: arrows
        final List<TableRow> bottomRows = List();
        bottomRows.add(TableRow(children: [
            SizedBox.shrink(),
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.UP)),
            SizedBox.shrink(),
            SizedBox.shrink()
        ]));
        bottomRows.add(TableRow(children: [
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.LEFT)),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.ENTER)),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.RIGHT)),
            SizedBox.shrink()
        ]));
        bottomRows.add(TableRow(children: [
            SizedBox.shrink(),
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.DOWN)),
            SizedBox.shrink(),
            SizedBox.shrink()
        ]));

        final EdgeInsetsGeometry activityMargins = ActivityDimens.activityMargins(context);

        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListBody(children: [
                Table(
                    columnWidths: columnWidths,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: topRows,
                ),
                CustomDivider(height: activityMargins.vertical),
                Table(
                    columnWidths: columnWidths,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: bottomRows,
                ),
            ]));
    }

    Widget _buildBtn(final SetupOperationCommandMsg cmd)
    {
        return CustomImageButton.big(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: stateManager.isConnected && stateManager.state.isOn
        );
    }
}