/*
 * Enhanced Controller for Onkyo and Pioneer
 * Copyright (C) 2018-2020. Mikhail Kulesh
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

package com.mkulesh.onpc.config;

import android.content.SharedPreferences;

import com.mkulesh.onpc.utils.Utils;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class CfgFavoriteShortcuts
{
    private static final String FAVORITE_SHORTCUT_TAG = "favoriteShortcut";
    private static final String FAVORITE_SHORTCUT_NUMBER = "flutter.favorite_shortcut_number";
    private static final String FAVORITE_SHORTCUT_ITEM = "flutter.favorite_shortcut_item";

    /**
     * Helper methods for enumerations based on char parameter
     */
    public interface StringParameterIf
    {
        String getCode();
    }

    private static StringParameterIf searchParameter(String code, StringParameterIf[] values, StringParameterIf defValue)
    {
        if (code == null)
        {
            return defValue;
        }
        for (StringParameterIf t : values)
        {
            if (t.getCode().toUpperCase().equals(code.toUpperCase()))
            {
                return t;
            }
        }
        return defValue;
    }

    public enum InputType implements StringParameterIf
    {
        VIDEO1("00"),
        VIDEO2("01"),
        VIDEO3("02"),
        VIDEO4("03"),
        VIDEO5("04"),
        VIDEO6("05"),
        VIDEO7("06"),
        EXTRA1("07"),
        EXTRA2("08"),
        BD_DVD("10"),
        STRM_BOX("11"),
        TV("12"),
        TAPE1("20"),
        TAPE2("21"),
        PHONO("22"),
        TV_CD("23"),
        FM("24"),
        AM("25"),
        TUNER("26"),
        MUSIC_SERVER("27"),
        INTERNET_RADIO("28"),
        USB_FRONT("29"),
        USB_REAR("2A"),
        NET("2B"),
        USB_TOGGLE("2C"),
        AIRPLAY("2D"),
        BLUETOOTH("2E"),
        USB_DAC_IN("2F"),
        LINE("41"),
        LINE2("42"),
        OPTICAL("44"),
        COAXIAL("45"),
        UNIVERSAL_PORT("40"),
        MULTI_CH("30"),
        XM("31"),
        SIRIUS("32"),
        DAB("33"),
        HDMI_5("55"),
        HDMI_6("56"),
        HDMI_7("57"),
        NONE("XX");

        final String code;

        InputType(String code)
        {
            this.code = code;
        }

        public String getCode()
        {
            return code;
        }
    }

    /*
     * Service icon
     * "00":Music Server (DLNA), "01":My Favorite, "02":vTuner,
     * "03":SiriusXM, "04":Pandora,
     * "05":Rhapsody, "06":Last.fm, "07":Napster, "08":Slacker, "09":Mediafly,
     * "0A":Spotify, "0B":AUPEO!,
     * "0C":radiko, "0D":e-onkyo, "0E":TuneIn, "0F":MP3tunes, "10":Simfy,
     * "11":Home Media, "12":Deezer, "13":iHeartRadio, "18":Airplay,
     * “1A”: onkyo Music, “1B”:TIDAL, "1D":PlayQueue,
     * “40”:Chromecast built-in, “41”:FireConnect, "42":Play-Fi,
     * "F0": USB/USB(Front), "F1: USB(Rear), "F2":Internet Radio
     * "F3":NET, "F4":Bluetooth
     */
    public enum ServiceType implements StringParameterIf
    {
        // Note: some names are device-specific, see comments
        // We use the names when ListInfoMsg is processed as a fallback is no ReceiverInformationMsg
        // exists for given device
        UNKNOWN("XX", ""),
        MUSIC_SERVER("00", "DLNA"), // TX-8050
        FAVORITE("01", "My Favorites"), // TX-8050
        VTUNER("02", "vTuner Internet Radio"), // TX-8050
        SIRIUSXM("03", "SiriusXM Internet Radio"), // TX-8050
        PANDORA("04", "Pandora Internet Radio"), // TX-NR616
        RHAPSODY("05", "Rhapsody"), // TX-NR616
        LAST_FM("06", "Last.fm Internet Radio"), // TX-8050, TX-NR616
        NAPSTER("07", "Napster"),
        SLACKER("08", "Slacker Personal Radio"), // TX-NR616
        MEDIAFLY("09", "Mediafly"),
        SPOTIFY("0A", "Spotify"), // TX-NR616
        AUPEO("0B", "AUPEO! PERSONAL RADIO"), // TX-8050, TX-NR616
        RADIKO("0C", "Radiko"),
        E_ONKYO("0D", "e-onkyo"),
        TUNEIN_RADIO("0E", "TuneIn"),
        MP3TUNES("0F", "mp3tunes"), // TX-NR616
        SIMFY("10", "Simfy"),
        HOME_MEDIA("11", "Home Media"), // TX-NR616
        DEEZER("12", "Deezer"),
        IHEARTRADIO("13", "iHeartRadio"),
        AIRPLAY("18", "Airplay"),
        ONKYO_MUSIC("1A", "onkyo music"),
        TIDAL("1B", "Tidal"),
        AMAZON_MUSIC("1C", "AmazonMusic"),
        PLAYQUEUE("1D", "Play Queue"),
        CHROMECAST("40", "Chromecast built-in"),
        FIRECONNECT("41", "FireConnect"),
        PLAY_FI("42", "DTS Play-Fi"),
        FLARECONNECT("43", "FlareConnect"),
        USB_FRONT("F0", "USB(Front)"),
        USB_REAR("F1", "USB(Rear)"),
        INTERNET_RADIO("F2", "Internet radio"),
        NET("F3", "NET"),
        BLUETOOTH("F4", "Bluetooth");

        private final String code;
        private final String name;

        ServiceType(final String code, final String name)
        {
            this.code = code;
            this.name = name;
        }

        public String getCode()
        {
            return code;
        }

        public String getName()
        {
            return name;
        }
    }

    public static class Shortcut
    {
        public final int id;
        final InputType input;
        final ServiceType service;
        final String item;
        public final String alias;
        final List<String> pathItems = new ArrayList<>();

        Shortcut(final Element e)
        {
            this.id = Utils.parseIntAttribute(e, "id", 0);
            this.input = (InputType) searchParameter(
                    e.getAttribute("input"), InputType.values(), InputType.NONE);
            this.service = (ServiceType) searchParameter(
                    e.getAttribute("service"), ServiceType.values(), ServiceType.UNKNOWN);
            this.item = e.getAttribute("item");
            this.alias = e.getAttribute("alias");
            for (Node dir = e.getFirstChild(); dir != null; dir = dir.getNextSibling())
            {
                if (dir instanceof Element)
                {
                    if (((Element) dir).getTagName().equals("dir"))
                    {
                        this.pathItems.add(((Element) dir).getAttribute("name"));
                    }
                }
            }
        }
    }

    private final ArrayList<Shortcut> shortcuts = new ArrayList<>();

    public void read(SharedPreferences preferences)
    {
        shortcuts.clear();
        final long fcNumber = preferences.getLong(FAVORITE_SHORTCUT_NUMBER, 0);
        for (long i = 0; i < fcNumber; i++)
        {
            final String key = FAVORITE_SHORTCUT_ITEM + "_" + i;
            Utils.openXml(preferences.getString(key, ""), (final Element elem) ->
            {
                if (elem.getTagName().equals(FAVORITE_SHORTCUT_TAG))
                {
                    shortcuts.add(new Shortcut(elem));
                }
            });
        }
    }

    public final List<Shortcut> getShortcuts()
    {
        return shortcuts;
    }
}
