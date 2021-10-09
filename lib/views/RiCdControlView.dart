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
import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/CdPlayerOperationCommandMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomImageButton.dart";
import "../widgets/CustomTextLabel.dart";
import "UpdatableView.dart";

class RiCdControlView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT
    ];

    RiCdControlView(final ViewContext viewContext) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.logRebuild(this);

        final Widget image = Padding(
            padding: ActivityDimens.coverImagePadding(context),
            child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: ControlViewDimens.imageHeight),
                child: Image.asset(Drawables.ri_cd_player)
            )
        );

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                CustomTextLabel.small(Strings.app_control_ri_cd_player,
                    padding: ActivityDimens.headerPaddingTop,
                    textAlign: TextAlign.center),
                image,
                _buildTopTable(),
                CustomTextLabel.small(Strings.remote_interface_playback, textAlign: TextAlign.center),
                _buildPlaybackRow(),
                _buildNumberRow1(),
                _buildNumberRow2(),
                _buildNumberRow3()
            ]);
    }

    Widget _buildTopTable()
    {
        final Map<int, TableColumnWidth> columnWidths = Map();
        columnWidths[0] = FlexColumnWidth();
        columnWidths[1] = IntrinsicColumnWidth();
        columnWidths[2] = IntrinsicColumnWidth();
        columnWidths[3] = FlexColumnWidth();

        // Top rows: quick menu, setup, return
        final List<TableRow> rows = [];
        rows.add(TableRow(children: [
            SizedBox.shrink(),
            CustomTextLabel.small(Strings.remote_interface_power, textAlign: TextAlign.center),
            CustomTextLabel.small(Strings.remote_interface_common, textAlign: TextAlign.center),
            SizedBox.shrink()
        ]));
        rows.add(TableRow(children: [
            SizedBox.shrink(),
            _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.POWER)),
            Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.OP_CL)),
                    _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.REPEAT)),
                    _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.RANDOM))
                ],
            ),
            SizedBox.shrink()
        ]));

        return Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
        );
    }

    Widget _buildPlaybackRow()
    {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.SKIP_R)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.STOP)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.PLAY)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.PAUSE)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.SKIP_F))
            ],
        );
    }

    Widget _buildNumberRow1()
    {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_1)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_2)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_3)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_4)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_5))
            ],
        );
    }

    Widget _buildNumberRow2()
    {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_6)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_7)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_8)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_9)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_0))
            ],
        );
    }

    Widget _buildNumberRow3()
    {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.NUMBER_GREATER_10)),
                _buildImgBtn(CdPlayerOperationCommandMsg.output(CdPlayerOperationCommand.CLEAR))
            ],
        );
    }

    Widget _buildImgBtn(final CdPlayerOperationCommandMsg cmd)
    {
        return CustomImageButton.normal(
            cmd.getValue.icon,
            cmd.getValue.description,
            onPressed: ()
            => stateManager.sendMessage(cmd),
            isEnabled: stateManager.isConnected
        );
    }
}