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

class Drawables
{
    static const String BUTTONS_PATH = "lib/assets/buttons/";

    // Common images
    static const String amplifier = "lib/assets/amplifier.png";
    static const String cd_player = "lib/assets/cd_player.png";
    static const String drawer_header = "lib/assets/drawer_header.svg";
    static const String empty_cover = "lib/assets/empty_cover.svg";
    static const String timer_sand = "lib/assets/timer_sand.svg";

    // Buttons
    static const String cd_eject = BUTTONS_PATH + "cd_eject.svg";
    static const String cmd_delete = BUTTONS_PATH + "cmd_delete.svg";
    static const String cmd_down = BUTTONS_PATH + "cmd_down.svg";
    static const String cmd_fast_backward = BUTTONS_PATH + "cmd_fast_backward.svg";
    static const String cmd_fast_forward = BUTTONS_PATH + "cmd_fast_forward.svg";
    static const String cmd_firmware_update = BUTTONS_PATH + "cmd_firmware_update.svg";
    static const String cmd_friendly_name = BUTTONS_PATH + "cmd_friendly_name.svg";
    static const String cmd_left = BUTTONS_PATH + "cmd_left.svg";
    static const String cmd_multiroom_channel = BUTTONS_PATH + "cmd_multiroom_channel.svg";
    static const String cmd_multiroom_group = BUTTONS_PATH + "cmd_multiroom_group.svg";
    static const String cmd_next = BUTTONS_PATH + "cmd_next.svg";
    static const String cmd_pause = BUTTONS_PATH + "cmd_pause.svg";
    static const String cmd_play = BUTTONS_PATH + "cmd_play.svg";
    static const String cmd_previous = BUTTONS_PATH + "cmd_previous.svg";
    static const String cmd_quick_menu = BUTTONS_PATH + "cmd_quick_menu.svg";
    static const String cmd_random = BUTTONS_PATH + "cmd_random.svg";
    static const String cmd_return = BUTTONS_PATH + "cmd_return.svg";
    static const String cmd_right = BUTTONS_PATH + "cmd_right.svg";
    static const String cmd_select = BUTTONS_PATH + "cmd_select.svg";
    static const String cmd_setup = BUTTONS_PATH + "cmd_setup.svg";
    static const String cmd_stop = BUTTONS_PATH + "cmd_stop.svg";
    static const String cmd_top = BUTTONS_PATH + "cmd_top.svg";
    static const String cmd_track_menu = BUTTONS_PATH + "cmd_track_menu.svg";
    static const String cmd_up = BUTTONS_PATH + "cmd_up.svg";
    static const String cmd_sort = BUTTONS_PATH + "cmd_sort.svg";
    static const String drawer_about = BUTTONS_PATH + "drawer_about.svg";
    static const String drawer_app_settings = BUTTONS_PATH + "drawer_app_settings.svg";
    static const String drawer_connect = BUTTONS_PATH + "drawer_connect.svg";
    static const String drawer_search = BUTTONS_PATH + "drawer_search.svg";

    static String drawerZone(String id)
    => BUTTONS_PATH + "drawer_zone_" + id + ".svg";

    static const String feed_ban = BUTTONS_PATH + "feed_ban.svg";
    static const String feed_dont_like = BUTTONS_PATH + "feed_dont_like.svg";
    static const String feed_like = BUTTONS_PATH + "feed_like.svg";
    static const String feed_love = BUTTONS_PATH + "feed_love.svg";
    static const String input_selector_down = BUTTONS_PATH + "input_selector_down.svg";
    static const String input_selector_up = BUTTONS_PATH + "input_selector_up.svg";
    static const String media_item_airplay = BUTTONS_PATH + "media_item_airplay.svg";
    static const String media_item_amazon = BUTTONS_PATH + "media_item_amazon.svg";
    static const String media_item_aux = BUTTONS_PATH + "media_item_aux.svg";
    static const String media_item_bluetooth = BUTTONS_PATH + "media_item_bluetooth.svg";
    static const String media_item_chromecast = BUTTONS_PATH + "media_item_chromecast.svg";
    static const String media_item_deezer = BUTTONS_PATH + "media_item_deezer.svg";
    static const String media_item_favorite = BUTTONS_PATH + "media_item_favorite.svg";
    static const String media_item_flare_connect = BUTTONS_PATH + "media_item_flare_connect.svg";
    static const String media_item_folder = BUTTONS_PATH + "media_item_folder.svg";
    static const String media_item_media_server = BUTTONS_PATH + "media_item_media_server.svg";
    static const String media_item_music = BUTTONS_PATH + "media_item_music.svg";
    static const String media_item_net = BUTTONS_PATH + "media_item_net.svg";
    static const String media_item_pandora = BUTTONS_PATH + "media_item_pandora.svg";
    static const String media_item_play_fi = BUTTONS_PATH + "media_item_play_fi.svg";
    static const String media_item_playqueue = BUTTONS_PATH + "media_item_playqueue.svg";
    static const String media_item_play = BUTTONS_PATH + "media_item_play.svg";
    static const String media_item_radio_am = BUTTONS_PATH + "media_item_radio_am.svg";
    static const String media_item_radio_dab = BUTTONS_PATH + "media_item_radio_dab.svg";
    static const String media_item_radio_digital = BUTTONS_PATH + "media_item_radio_digital.svg";
    static const String media_item_radio_fm = BUTTONS_PATH + "media_item_radio_fm.svg";
    static const String media_item_radio = BUTTONS_PATH + "media_item_radio.svg";
    static const String media_item_search = BUTTONS_PATH + "media_item_search.svg";
    static const String media_item_spotify = BUTTONS_PATH + "media_item_spotify.svg";
    static const String media_item_tape = BUTTONS_PATH + "media_item_tape.svg";
    static const String media_item_tidal = BUTTONS_PATH + "media_item_tidal.svg";
    static const String media_item_tunein = BUTTONS_PATH + "media_item_tunein.svg";
    static const String media_item_tv = BUTTONS_PATH + "media_item_tv.svg";
    static const String media_item_unknown = BUTTONS_PATH + "media_item_unknown.svg";
    static const String media_item_usb = BUTTONS_PATH + "media_item_usb.svg";
    static const String menu_power_standby = BUTTONS_PATH + "menu_power_standby.svg";
    static const String media_item_disc_player = BUTTONS_PATH + "media_item_disc_player.svg";
    static const String media_item_toslink = BUTTONS_PATH + "media_item_toslink.svg";

    static String drawerMultiroomDevice(int id)
    => BUTTONS_PATH + "multiroom_device_" + id.toString() + ".svg";

    static const String pref_app_theme = BUTTONS_PATH + "pref_app_theme.svg";
    static const String pref_auto_power = BUTTONS_PATH + "pref_auto_power.svg";
    static const String pref_device_selectors = BUTTONS_PATH + "pref_device_selectors.svg";
    static const String pref_exit_confirm = BUTTONS_PATH + "pref_exit_confirm.svg";
    static const String pref_friendly_name = BUTTONS_PATH + "pref_friendly_name.svg";
    static const String pref_keep_screen_on = BUTTONS_PATH + "pref_keep_screen_on.svg";
    static const String pref_language = BUTTONS_PATH + "pref_language.svg";
    static const String pref_listening_modes = BUTTONS_PATH + "pref_listening_modes.svg";
    static const String pref_network_services = BUTTONS_PATH + "pref_network_services.svg";
    static const String pref_ri_amplifier = BUTTONS_PATH + "pref_ri_amplifier.svg";
    static const String pref_ri_disc_player = BUTTONS_PATH + "pref_ri_disc_player.svg";
    static const String pref_sound_control = BUTTONS_PATH + "pref_sound_control.svg";
    static const String pref_text_size = BUTTONS_PATH + "pref_text_size.svg";
    static const String pref_volume_keys = BUTTONS_PATH + "pref_volume_keys.svg";
    static const String pref_advanced_queue = BUTTONS_PATH + "pref_advanced_queue.svg";
    static const String pref_developer_mode = BUTTONS_PATH + "pref_developer_mode.svg";
    static const String repeat_all = BUTTONS_PATH + "repeat_all.svg";
    static const String repeat_folder = BUTTONS_PATH + "repeat_folder.svg";
    static const String repeat_off = BUTTONS_PATH + "repeat_off.svg";
    static const String repeat_once = BUTTONS_PATH + "repeat_once.svg";
    static const String volume_amp_down = BUTTONS_PATH + "volume_amp_down.svg";
    static const String volume_amp_muting = BUTTONS_PATH + "volume_amp_muting.svg";
    static const String volume_amp_slider = BUTTONS_PATH + "volume_amp_slider.svg";
    static const String volume_amp_up = BUTTONS_PATH + "volume_amp_up.svg";
    static const String volume_audio_control = BUTTONS_PATH + "volume_audio_control.svg";
    static const String volume_max_limit = BUTTONS_PATH + "volume_max_limit.svg";
    static const String wrap_around = BUTTONS_PATH + "wrap_around.svg";
}
