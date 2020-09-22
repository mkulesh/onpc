/*
 * Copyright (C) 2020. Mikhail Kulesh
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
import "../iscp/StateManager.dart";
import "../iscp/messages/EnumParameterMsg.dart";
import "../iscp/messages/SetupOperationCommandMsg.dart";
import "../widgets/CustomImageButton.dart";

class SetupNavigationCommandsView extends StatelessWidget
{
    final StateManager stateManager;
    final bool enabled;

    const SetupNavigationCommandsView(this.stateManager,
    {
        this.enabled = false,
        Key key
    }) : super(key: key);

    @override
    Widget build(BuildContext context)
    {
        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FlexColumnWidth();
        columnWidths[1] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[2] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[3] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        columnWidths[4] = FlexColumnWidth();

        final List<TableRow> rows = List();
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
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: enabled
        );
    }
}
