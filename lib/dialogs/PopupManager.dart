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
import 'dart:async';

import "package:flutter/material.dart";

import "../utils/Logging.dart";
import "../views/UpdatableView.dart";
import "CustomPopupDialog.dart";
import "TrackMenuDialog.dart";

enum _DialogType
{
    TRACK_MENU,
    POPUP
}

class PopupManager
{
    static const int TOAST_DURATION = 4;

    final List<_DialogType> _openDialogs = [];

    void _openDialog(final _DialogType t)
    {
        Logging.info(this, "Open dialog: " + t.toString().split('.').last);
        if (!_openDialogs.contains(t))
        {
            _openDialogs.add(t);
        }
    }

    void _closeDialog(final _DialogType t)
    {
        Logging.info(this, "Close dialog: " + t.toString().split('.').last);
        if (_openDialogs.contains(t))
        {
            _openDialogs.remove(t);
        }
    }

    bool _isDialog(final _DialogType t, {bool last = false})
    {
        if (_openDialogs.isNotEmpty)
        {
            return last ? (_openDialogs.last == t) : _openDialogs.contains(t);
        }
        return false;
    }

    void showTrackMenuDialog(final BuildContext context, final ViewContext viewContext)
    {
        if (_isDialog(_DialogType.TRACK_MENU))
        {
            return;
        }

        closePopupDialog(context);
        _openDialog(_DialogType.TRACK_MENU);
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext c)
            => TrackMenuDialog(viewContext, ()
                => _closeDialog(_DialogType.TRACK_MENU))
        );
    }

    void closeTrackMenuDialog(final BuildContext context)
    {
        if (_isDialog(_DialogType.TRACK_MENU, last: true) && Navigator.of(context).canPop())
        {
            Navigator.of(context).pop();
        }
    }

    void showPopupDialog(final BuildContext context, final ViewContext viewContext, { final GlobalKey<ScaffoldState> toastKey })
    {
        if (_isDialog(_DialogType.TRACK_MENU) && Navigator.of(context).canPop())
        {
            Navigator.of(context).pop();
        }

        final String simplePopupMessage = viewContext.state.retrieveSimplePopupMessage();
        if (simplePopupMessage != null)
        {
            showToast(simplePopupMessage, toastKey: toastKey);
            return;
        }

        if (!_isDialog(_DialogType.POPUP) && viewContext.state.popupDocument != null)
        {
            _openDialog(_DialogType.POPUP);
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c)
                => CustomPopupDialog(viewContext, ()
                    => _closeDialog(_DialogType.POPUP))
            );
        }
    }

    void closePopupDialog(final BuildContext context)
    {
        if (_isDialog(_DialogType.POPUP, last: true) && Navigator.of(context).canPop())
        {
            Navigator.of(context).pop();
        }
    }

    static void showToast(final String msg, {final BuildContext context, final GlobalKey<ScaffoldState> toastKey})
    {
        try
        {
            final ScaffoldState sm = (toastKey != null) ? toastKey.currentState : Scaffold.of(context);
            if (sm != null)
            {
                sm.showSnackBar(SnackBar(content: Text(msg)));
                Timer(Duration(seconds: TOAST_DURATION), ()
                => sm.removeCurrentSnackBar());
            }
        }
        on Exception
        {
            // nothing to do
        }
    }
}