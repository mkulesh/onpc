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

// Control elements
enum AppControl
{
    DIVIDER,
    LISTENING_MODE_LIST,
    VOLUME_CONTROL,
    TRACK_FILE_INFO,
    TRACK_COVER,
    TRACK_TIME,
    TRACK_CAPTION,
    PLAY_CONTROL,
    SHORTCUTS,
    INPUT_SELECTOR,
    MEDIA_LIST,
    SETUP_OP_CMD,
    SETUP_NAV_CMD,
    LISTENING_MODE_BTN,
    DEVICE_INFO,
    DEVICE_SETTINGS,
    RI_AMPLIFIER,
    RI_CD_PLAYER,
}

class CfgTabSettings
{
    final List<AppControl> controlsPortrait;
    final List<AppControl> controlsLandscapeLeft;
    final List<AppControl> controlsLandscapeRight;

    CfgTabSettings(
    {
        this.controlsPortrait,
        this.controlsLandscapeLeft,
        this.controlsLandscapeRight
    });
}