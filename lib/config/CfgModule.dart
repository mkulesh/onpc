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

import "package:shared_preferences/shared_preferences.dart";

import "../iscp/StateManager.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "Configuration.dart";

abstract class CfgModule
{
    final SharedPreferences preferences;

    CfgModule(this.preferences);

    void read();

    void setReceiverInformation(StateManager stateManager);

    String getString(Pair<String, String> par, {doLog = false})
    {
        String val = par.item2;
        try
        {
            final String? v = preferences.getString(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "  " + par.item1 + ": " + val);
        }
        return val;
    }

    String getStringDef(String name, String def)
    => getString(Pair<String, String>(name, def));

    int getInt(Pair<String, int> par, {doLog = false})
    {
        int val = par.item2;
        try
        {
            final int? v = preferences.getInt(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "  " + par.item1 + ": " + val.toString());
        }
        return val;
    }

    bool getBool(final Pair<String, bool> par, {doLog = false})
    {
        bool val = par.item2;
        try
        {
            final bool? v = preferences.getBool(par.item1);
            val = v != null ? v : par.item2;
        }
        on Exception
        {
            // nothing to do
        }
        if (doLog)
        {
            Logging.info(this, "  " + par.item1 + ": " + val.toString());
        }
        return val;
    }

    String getModelDependentParameter(final String par)
    => par + "_" + getString(Configuration.MODEL);

    Pair<String, int> getModelDependentInt(final Pair<String, int> par, {int zone = -1})
    {
        final String name = getModelDependentParameter(par.item1);
        return Pair<String, int>(zone >= 0 ? name + "_" + zone.toString() : name, par.item2);
    }

    void deleteParameter(final Pair<String, String> par, {String prefix = ""}) async
    {
        Logging.info(this, prefix + "deleting " + par.item1);
        await preferences.remove(par.item1);
    }

    void saveStringParameter(final Pair<String, String> par, final String value, {String prefix = ""}) async
    {
        Logging.info(this, prefix + "saving " + par.item1 + ": " + value);
        await preferences.setString(par.item1, value);
    }

    void saveIntegerParameter(final Pair<String, int> par, final int value, {String prefix = ""}) async
    {
        Logging.info(this, prefix + "saving " + par.item1 + ": " + value.toString());
        await preferences.setInt(par.item1, value);
    }

    void saveBoolParameter(final Pair<String, bool> par, final bool value, {String prefix = ""}) async
    {
        Logging.info(this, prefix + "saving " + par.item1 + ": " + value.toString());
        await preferences.setBool(par.item1, value);
    }

    List<String>? getTokens(final String par)
    {
        final String? cfg = preferences.getString(par);
        return (cfg == null || cfg.isEmpty) ? null : cfg.split(",");
    }

    void saveTokens(final String par, final String val)
    {
        Logging.info(this, "saving " + par + ": " + val);
        preferences.setString(par, val);
    }
}