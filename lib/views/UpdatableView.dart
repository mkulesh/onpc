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

import "dart:async";

import "package:flutter/material.dart";

import "../config/Configuration.dart";
import "../constants/Dimens.dart";
import "../iscp/State.dart" as remote_state;
import "../iscp/StateManager.dart";

class ViewContext
{
    final Configuration configuration;
    final StateManager stateManager;
    final StreamController updateNotifier;

    ViewContext(this.configuration, this.stateManager, this.updateNotifier);

    remote_state.State get state
    => stateManager.state;
}

abstract class UpdatableView
{
    final ViewContext _viewContext;
    final List<String> _updateTriggers;

    UpdatableView(this._viewContext, this._updateTriggers);

    Widget createView(BuildContext context, VoidCallback updateCallback);

    ViewContext get viewContext
    => _viewContext;

    Configuration get configuration
    => _viewContext.configuration;

    StateManager get stateManager
    => _viewContext.stateManager;

    StreamController get updateNotifier
    => _viewContext.updateNotifier;

    remote_state.State get state
    => _viewContext.stateManager.state;
}

class UpdatableWidget extends StatefulWidget
{
    final UpdatableView child;

    UpdatableWidget({this.child});

    @override _UpdatableWidgetState createState()
    => _UpdatableWidgetState();
}

class UpdatableAppBarWidget extends UpdatableWidget
    implements PreferredSizeWidget
{
    final BuildContext _context;

    UpdatableAppBarWidget(this._context, UpdatableView child) : super(child: child);

    @override _UpdatableWidgetState createState()
    => _UpdatableWidgetState();

    @override
    Size get preferredSize
    => Size.fromHeight(ActivityDimens.appBarHeight(_context));
}

class _UpdatableWidgetState extends State<UpdatableWidget>
{
    StreamSubscription _updateStream;

    @override
    initState()
    {
        super.initState();
        _updateStream = widget.child.updateNotifier.stream.listen((code)
        => _update(code));
    }

    @override
    didUpdateWidget(UpdatableWidget old)
    {
        super.didUpdateWidget(old);
        // in case the stream instance changed, subscribe to the new one
        if (widget.child.updateNotifier != old.child.updateNotifier)
        {
            _updateStream.cancel();
            _updateStream = widget.child.updateNotifier.stream.listen((code)
            => _update(code));
        }
    }

    @override
    dispose()
    {
        super.dispose();
        _updateStream.cancel();
    }

    _update(Set<String> changes)
    {
        if (changes.where((s) => widget.child._updateTriggers.contains(s)).isNotEmpty)
        {
            _updateCallback();
        }
    }

    void _updateCallback()
    {
        setState(()
        {
            // nothing to do: build will be called
        });
    }

    @override
    Widget build(BuildContext context)
    {
        return widget.child.createView(context, _updateCallback);
    }
}