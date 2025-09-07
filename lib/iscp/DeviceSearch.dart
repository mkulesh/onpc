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

import '../utils/Logging.dart';
import 'DeviceSearchIscp.dart';
import 'DeviceSearchSsdp.dart';
import 'messages/BroadcastResponseMsg.dart';

typedef OnRequest = void Function(int engineId, int requestCount);
typedef OnStop = void Function();

abstract class SearchEngineIf
{
    int get id;
    void start(int retryDelay);
    void stop();
    bool get isStopped;
}

class DeviceSearch
{
    // Delay between individual requests by search engines
    static const int RETRY_DELAY = 3;

    // All engines must reach this count to stop the search
    static const int REQUEST_COUNT = 5;

    final OnDeviceFound onDeviceFound;
    final OnStop onStop;
    final List<SearchEngineIf> _searchEngines = [];
    final Map<int, int> _engineRequestCounts = {};

    bool _limited = true;

    set limited(bool value)
    {
        _limited = value;
    }

    DeviceSearch(this.onDeviceFound, this.onStop, {bool iscp = true, bool ssdp = true})
    {
        if (iscp)
        {
            _searchEngines.add(DeviceSearchIscp(0, onDeviceFound, _onRequest));
        }
        if (ssdp)
        {
            _searchEngines.add(DeviceSearchSsdp(1, onDeviceFound, _onRequest));
        }
        for (var engine in _searchEngines)
        {
            _engineRequestCounts[engine.id] = 0;
            engine.start(RETRY_DELAY);
        }
    }

    /// Called by individual search engines to report their request activity.
    /// If all active search engines have reported at least [REQUEST_COUNT] requests,
    /// this method will automatically call [stop()] to stop all search operations.
    void _onRequest(int engineId, int requestCount)
    {
        if (_engineRequestCounts.containsKey(engineId))
        {
            _engineRequestCounts[engineId] = requestCount;
            if (_limited && _engineRequestCounts.values.every((count) => count >= REQUEST_COUNT))
            {
                Logging.info(this, "All engines reached desired request count: " + REQUEST_COUNT.toString());
                onStop();
            }
        }
    }

    void stop()
    {
        for (var engine in _searchEngines)
        {
            engine.stop();
        }
        _engineRequestCounts.clear();
    }

    bool get isStopped
    => _searchEngines.isEmpty ? true : _searchEngines.every((engine) => engine.isStopped);
}
