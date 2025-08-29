/*
 * Enhanced Music Controller
 * Copyright (C) 2019-2024 by Mikhail Kulesh
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
    static const String drawer_header = "lib/assets/drawer_header.svg";
    static const String empty_cover = "lib/assets/empty_cover.svg";
    static const String timer_sand = "lib/assets/timer_sand.svg";

    // RI devices
    static const List<String> ri_amplifier_models = [
        "A-9000R(S)", "A-9000R(B)", "A-9010", "A-9110", "A-9130", "A-9150", "P-3000R"
    ];
    static String ri_amplifier(String model)
    => "lib/assets/ri/" + model + ".png";

    static const List<String> ri_cd_models = [
        "C-7000(S)", "C-7000(B)", "C-7030", "DX-C390"
    ];
    static String ri_cd_player(String model)
    => "lib/assets/ri/" + model + ".png";

    static const String ri_md_player = "lib/assets/ri/MD-2321.png";
    static const String ri_tape_deck = "lib/assets/ri/TA-6511.png";

    // Buttons
    static const String menu_power_standby = BUTTONS_PATH + "menu_power_standby.svg";
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
    static const String cmd_home = BUTTONS_PATH + "cmd_home.svg";
    static const String cmd_right = BUTTONS_PATH + "cmd_right.svg";
    static const String cmd_select = BUTTONS_PATH + "cmd_select.svg";
    static const String cmd_setup = BUTTONS_PATH + "cmd_setup.svg";
    static const String cmd_stop = BUTTONS_PATH + "cmd_stop.svg";
    static const String cmd_top = BUTTONS_PATH + "cmd_top.svg";
    static const String cmd_track_menu = BUTTONS_PATH + "cmd_track_menu.svg";
    static const String cmd_up = BUTTONS_PATH + "cmd_up.svg";
    static const String cmd_sort = BUTTONS_PATH + "cmd_sort.svg";
    static const String cmd_rds_info = BUTTONS_PATH + "cmd_rds_info.svg";
    static const String cmd_help = BUTTONS_PATH + "cmd_help.svg";
    static const String cmd_search = BUTTONS_PATH + "cmd_search.svg";

    static const String drawer_about = BUTTONS_PATH + "drawer_about.svg";
    static const String drawer_tab_layout = BUTTONS_PATH + "drawer_tab_layout.svg";
    static const String drawer_app_settings = BUTTONS_PATH + "drawer_app_settings.svg";
    static const String drawer_connect = BUTTONS_PATH + "drawer_connect.svg";
    static const String drawer_favorite_device = BUTTONS_PATH + "drawer_favorite_device.svg";
    static const String drawer_found_device = BUTTONS_PATH + "drawer_found_device.svg"; // audio-video
    static const String drawer_edit_item = BUTTONS_PATH + "drawer_edit_item.svg"; // pencil-outline
    static const String drawer_favorite_shortcut = BUTTONS_PATH + "drawer_favorite_shortcut.svg"; // pencil-outline
    static const String drawer_all_standby = BUTTONS_PATH + "drawer_all_standby.svg";

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
    static const String media_item_lastfm = BUTTONS_PATH + "media_item_lastfm.svg";
    static const String media_item_play_fi = BUTTONS_PATH + "media_item_play_fi.svg";
    static const String media_item_playlist = BUTTONS_PATH + "media_item_playlist.svg";
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
    static const String media_item_disc_player = BUTTONS_PATH + "media_item_disc_player.svg";
    static const String media_item_toslink = BUTTONS_PATH + "media_item_toslink.svg";
    static const String media_item_filter = BUTTONS_PATH + "media_item_filter.svg";
    static const String media_item_vhs = BUTTONS_PATH + "media_item_vhs.svg";
    static const String media_item_sat = BUTTONS_PATH + "media_item_sat.svg";
    static const String media_item_game = BUTTONS_PATH + "media_item_game.svg";
    static const String media_item_pc = BUTTONS_PATH + "media_item_pc.svg";
    static const String media_item_hdmi = BUTTONS_PATH + "media_item_hdmi.svg";
    static const String media_item_mplayer = BUTTONS_PATH + "media_item_mplayer.svg";
    static const String media_item_phono = BUTTONS_PATH + "media_item_phono.svg";
    static const String media_item_rca = BUTTONS_PATH + "media_item_rca.svg";
    static const String media_item_source = BUTTONS_PATH + "media_item_source.svg";
    static const String media_item_napster = BUTTONS_PATH + "media_item_napster.svg";
    static const String media_item_soundcloud = BUTTONS_PATH + "media_item_soundcloud.svg";
    static const String media_item_history = BUTTONS_PATH + "media_item_history.svg";
    static const String media_item_folder_play = BUTTONS_PATH + "media_item_folder_play.svg";

    static const String pref_app_theme = BUTTONS_PATH + "pref_app_theme.svg";
    static const String pref_widget_theme = BUTTONS_PATH + "pref_widget_theme.svg";
    static const String pref_widget_transparency = BUTTONS_PATH + "pref_widget_transparency.svg";
    static const String pref_visible_tabs = BUTTONS_PATH + "pref_visible_tabs.svg";
    static const String pref_auto_power = BUTTONS_PATH + "pref_auto_power.svg";
    static const String pref_device_selectors = BUTTONS_PATH + "pref_device_selectors.svg";
    static const String pref_exit_confirm = BUTTONS_PATH + "pref_exit_confirm.svg";
    static const String pref_friendly_name = BUTTONS_PATH + "pref_friendly_name.svg";
    static const String pref_keep_screen_on = BUTTONS_PATH + "pref_keep_screen_on.svg";
    static const String pref_show_when_locked = BUTTONS_PATH + "pref_show_when_locked.svg";
    static const String pref_language = BUTTONS_PATH + "pref_language.svg";
    static const String pref_listening_modes = BUTTONS_PATH + "pref_listening_modes.svg";
    static const String pref_network_services = BUTTONS_PATH + "pref_network_services.svg";
    static const String pref_ri_amplifier = BUTTONS_PATH + "pref_ri_amplifier.svg";
    static const String pref_ri_disc_player = BUTTONS_PATH + "pref_ri_disc_player.svg";
    static const String pref_sound_control = BUTTONS_PATH + "pref_sound_control.svg";
    static const String pref_volume_unit = BUTTONS_PATH + "pref_volume_unit.svg";
    static const String pref_text_size = BUTTONS_PATH + "pref_text_size.svg";
    static const String pref_text_bold = BUTTONS_PATH + "pref_text_bold.svg";
    static const String pref_text_italic = BUTTONS_PATH + "pref_text_italic.svg";
    static const String pref_text_underline = BUTTONS_PATH + "pref_text_underline.svg";
    static const String pref_text_shadow = BUTTONS_PATH + "pref_text_shadow.svg";
    static const String pref_volume_keys = BUTTONS_PATH + "pref_volume_keys.svg";
    static const String pref_advanced_queue = BUTTONS_PATH + "pref_advanced_queue.svg";
    static const String pref_cover_click = BUTTONS_PATH + "pref_cover_click.svg";
    static const String pref_usb_ri_interface = BUTTONS_PATH + "pref_usb_ri_interface.svg";
    static const String pref_developer_mode = BUTTONS_PATH + "pref_developer_mode.svg";
    static const String repeat_all = BUTTONS_PATH + "repeat_all.svg";
    static const String repeat_folder = BUTTONS_PATH + "repeat_folder.svg";
    static const String repeat_off = BUTTONS_PATH + "repeat_off.svg";
    static const String repeat_once = BUTTONS_PATH + "repeat_once.svg";
    static const String volume_amp_down = BUTTONS_PATH + "volume_amp_down.svg";
    static const String volume_amp_muting = BUTTONS_PATH + "volume_amp_muting.svg";
    static const String volume_amp_up = BUTTONS_PATH + "volume_amp_up.svg";

    static const String audio_control = BUTTONS_PATH + "audio_control.svg";
    static const String audio_control_current_zone = BUTTONS_PATH + "audio_control_current_zone.svg";
    static const String audio_control_all_zones = BUTTONS_PATH + "audio_control_all_zones.svg";
    static const String audio_control_channel_level = BUTTONS_PATH + "audio_control_channel_level.svg";
    static const String audio_control_equalizer = BUTTONS_PATH + "audio_control_equalizer.svg";
    static const String audio_control_max_level = BUTTONS_PATH + "audio_control_max_level.svg";

    static const String numeric_0 = BUTTONS_PATH + "numeric_0.svg";
    static const String numeric_1 = BUTTONS_PATH + "numeric_1.svg";
    static const String numeric_2 = BUTTONS_PATH + "numeric_2.svg";
    static const String numeric_3 = BUTTONS_PATH + "numeric_3.svg";
    static const String numeric_4 = BUTTONS_PATH + "numeric_4.svg";
    static const String numeric_5 = BUTTONS_PATH + "numeric_5.svg";
    static const String numeric_6 = BUTTONS_PATH + "numeric_6.svg";
    static const String numeric_7 = BUTTONS_PATH + "numeric_7.svg";
    static const String numeric_8 = BUTTONS_PATH + "numeric_8.svg";
    static const String numeric_9 = BUTTONS_PATH + "numeric_9.svg";
    static const String numeric_greater_9 = BUTTONS_PATH + "numeric_greater_9.svg";
    static const String numeric_clean = BUTTONS_PATH + "numeric_clean.svg";
    static const String numeric_negative_1 = BUTTONS_PATH + "numeric_negative_1.svg";
    static const String numeric_positive_1 = BUTTONS_PATH + "numeric_positive_1.svg";

    static const String keyboard_shortcuts = BUTTONS_PATH + "keyboard_shortcuts.svg";
    static const String keyboard_shortcut_update = BUTTONS_PATH + "keyboard_shortcut_update.svg";
    static const String keyboard_shortcut_delete = BUTTONS_PATH + "keyboard_shortcut_delete.svg";
}
