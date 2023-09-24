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
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/SetupOperationCommandMsg.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomImageButton.dart";

class SetupNavigationCommandsView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        PowerStatusMsg.CODE,
    ];

    SetupNavigationCommandsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FlexColumnWidth();
        columnWidths[1] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[2] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[3] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[4] = FlexColumnWidth();

        final List<TableRow> rows = [];
        rows.add(TableRow(children: [
            SizedBox.shrink(),
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.UP)),
            SizedBox.shrink(),
            SizedBox.shrink()
        ]));
        rows.add(TableRow(children: [
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.LEFT)),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.ENTER)),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.RIGHT)),
            SizedBox.shrink()
        ]));
        rows.add(TableRow(children: [
            SizedBox.shrink(),
            SizedBox.shrink(),
            _buildBtn(SetupOperationCommandMsg.output(SetupOperationCommand.DOWN)),
            SizedBox.shrink(),
            SizedBox.shrink()
        ]));

        return Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );
    }

    Widget _buildBtn<T>(final EnumParameterMsg<T> cmd)
    {
        return CustomImageButton.big(
            cmd.getValue.icon!,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: state.isOn
        );
    }
}
