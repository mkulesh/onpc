/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2025 by Mikhail Kulesh
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

import "package:collection/collection.dart";

import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../MessageChannel.dart";
import "../State.dart";
import "../messages/DcpMediaContainerMsg.dart";
import "../messages/XmlListItemMsg.dart";
import "MessageScriptIf.dart";

class ContainerContent
{
    final DcpMediaContainerMsg parent;
    DcpMediaContainerMsg? firstLevel;
    int tracks = -1;
    int requests = 0;

    ContainerContent(this.parent);
}

typedef OnHandleDcpDuplicatesFinished = void Function(HandleDcpDuplicates script);

//
// This scripts analyzes duplicates DCP containers whether any valid items are available
//
class HandleDcpDuplicates implements MessageScriptIf
{
    final List<ContainerContent> _items = [];

    List<ContainerContent> get items
    => _items;

    final OnHandleDcpDuplicatesFinished _onFinished;

    bool _finished = false;

    HandleDcpDuplicates(List<DcpMediaContainerMsg> _dcpDuplicates, this._onFinished)
    {
        _dcpDuplicates.forEach((c) => _items.add(ContainerContent(c)));
    }

    @override
    bool isValid(ProtoType protoType)
    => protoType == ProtoType.DCP;

    @override
    bool initialize(final State state, MessageChannel channel)
    => isValid(state.protoType);

    @override
    void start(State state, MessageChannel channel)
    {
        Logging.info(this, "started script for " + _items.length.toString() + " items");
        if (_items.isNotEmpty)
        {
            _requestContainerContent(_items.first, channel);
        }
        _finished = false;
    }

    @override
    void processMessage(ISCPMessage msg, State state, MessageChannel channel)
    {
        if (msg is! DcpMediaContainerMsg || _items.isEmpty || _finished)
        {
            return;
        }

        if (!msg.isContainerContent)
        {
            // Abort script since received a valid "browse" message
            Logging.info(this, "script aborted");
            _items.clear();
            _finished = true;
            _onFinished(this);
            return;
        }

        final ContainerContent? cFirst = _items.firstWhereOrNull((c) => c.firstLevel != null && c.firstLevel!.getCid() == msg.getCid());
        if (cFirst != null)
        {
            Logging.info(this, "received container content for the first level: " + msg.toString());
            cFirst.tracks = msg.getCount();
            if (_startNext(channel))
            {
                return;
            }
        }
        final ContainerContent? cParent = _items.firstWhereOrNull((c) => c.parent.getCid() == msg.getCid());
        if (cParent != null)
        {
            Logging.info(this, "received container content for the parent item: " + msg.toString());
            for (XmlListItemMsg c in msg.getItems())
            {
                final DcpMediaContainerMsg? dcpC = state.mediaListState.getDcpContainerMsg(c);
                if (dcpC != null && dcpC.isContainer() && dcpC.isPlayable())
                {
                    cParent.firstLevel = dcpC;
                    _requestContainerContent(cParent, channel);
                    return;
                }
            }
            Logging.info(this, "no playable containers for the parent item");
            cParent.tracks = msg.getCount();
            if (_startNext(channel))
            {
                return;
            }
        }
        Logging.info(this, "script finished successfully");
        _finished = true;
        _onFinished(this);
    }

    void _requestContainerContent(final ContainerContent c, final MessageChannel channel)
    {
        c.requests++;
        final String type = c.firstLevel != null? "first level" : "parent";
        final DcpMediaContainerMsg newMc = DcpMediaContainerMsg.copy(c.firstLevel != null? c.firstLevel! : c.parent);
        newMc.setAid("");
        newMc.setStart(0);
        newMc.setEnd(DcpMediaContainerMsg.CONTAINER_CONTENT);
        Logging.info(this, "request container content for " + type + " item: " + newMc.toString());
        channel.sendIscp(newMc);
    }

    bool _startNext(MessageChannel channel)
    {
        final ContainerContent? newContainer = _items.firstWhereOrNull((c) => c.requests == 0);
        if (newContainer != null)
        {
            Logging.info(this, "request data for the next container");
            _requestContainerContent(newContainer, channel);
            return true;
        }
        return false;
    }
}
