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

enum TextLabelParName
{
    ARTIST,
    ALBUM,
    TRACK_TITLE
}

class TextLabelStyle
{
    static const int DEF_SCALE = 100;
    static const bool DEF_STYLE = false;

    late int scale;
    late bool bold, italic, underline, shadow;

    // Default style
    TextLabelStyle({
        this.scale = DEF_SCALE,
        this.bold = DEF_STYLE,
        this.italic = DEF_STYLE,
        this.underline = DEF_STYLE,
        this.shadow = DEF_STYLE
    });

    // Explicit style
    TextLabelStyle.explicit(this.scale, this.bold, this.italic, this.underline, this.shadow);

    // From tokens
    TextLabelStyle.tokens(final List<String> tokens)
    {
        this.scale = _getIntToken(tokens, 0, DEF_SCALE);
        this.bold = _getBoolToken(tokens, 1, DEF_STYLE);
        this.italic = _getBoolToken(tokens, 2, DEF_STYLE);
        this.underline = _getBoolToken(tokens, 3, DEF_STYLE);
        this.shadow = _getBoolToken(tokens, 4, DEF_STYLE);
    }

    @override
    String toString()
    => scale.toString() + "," + bold.toString() + "," + italic.toString() + "," + underline.toString() + "," + shadow.toString();

    double get doubleScale
    => scale / 100.0;

    int _getIntToken(List<String> tokens, int idx, int defValue)
    {
        final int? val = idx < tokens.length ? int.tryParse(tokens[idx]) : null;
        return val ?? defValue;
    }

    bool _getBoolToken(List<String> tokens, int idx, bool defValue)
    {
        final bool? val = idx < tokens.length ? tokens[idx].toLowerCase() == "true" : null;
        return val ?? defValue;
    }
}