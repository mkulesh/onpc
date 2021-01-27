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
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../iscp/messages/SetupOperationCommandMsg.dart";
import "../views/UpdatableView.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";

class SetupOperationalCommandsView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        ReceiverInformationMsg.CODE,
        PowerStatusMsg.CODE,
    ];

    SetupOperationalCommandsView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        final bool enabled = state.isOn;

        // Commands to be shows
        final List<SetupOperationCommandMsg> cmd = [];
        if (state.receiverInformation.isControlExists("Setup"))
        {
            cmd.add(SetupOperationCommandMsg.output(SetupOperationCommand.MENU));
        }
        if (state.receiverInformation.isControlExists("Home"))
        {
            cmd.add(SetupOperationCommandMsg.output(SetupOperationCommand.HOME));
        }
        if (state.receiverInformation.isControlExists("Quick"))
        {
            cmd.add(SetupOperationCommandMsg.output(SetupOperationCommand.QUICK));
        }
        cmd.add(SetupOperationCommandMsg.output(SetupOperationCommand.EXIT));

        // Columns width
        final Map<int, TableColumnWidth> columnWidths = Map();
        for (int i = 0; i < cmd.length; i++)
        {
            columnWidths[i] = FixedColumnWidth(1.9 * ButtonDimens.bigButtonSize);
        }

        final List<TableRow> rows = [];

        // Labels (first row)
        {
            final List<Widget> cells = [];
            cmd.forEach((c)
            => cells.add(InkWell(
                    child: CustomTextLabel.small(c.getValue.description,
                        padding: ActivityDimens.headerPaddingTop,
                        textAlign: TextAlign.center),
                    onTap: ()
                    => enabled ? stateManager.sendMessage(c) : null
                )
            ));
            rows.add(TableRow(children: cells));
        }

        // Buttons
        {
            final List<Widget> cells = [];
            cmd.forEach((c)
            => cells.add(CustomImageButton.big(
                    c.getValue.icon,
                    c.getValue.description,
                    onPressed: ()
                    => stateManager.sendMessage(c),
                    isEnabled: enabled
                )
            ));
            rows.add(TableRow(children: cells));
        }

        final Widget table = Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );

        return Row(mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [table]);
    }
}
