/*                    ---- CAUTION! ----                    */
/* This is an auto-generated file! Do not edit it manually. */

/* Class collects all strings that can be shown to the user */
class Strings
{
    /* All supported languages */

    static const List<String> app_languages = [
        /*en*/ "en",
        /*ru*/ "ru",
        /*de*/ "de",
        /*fr*/ "fr",
        /*pl*/ "pl"];

    /* Current language */

    static int _language = 0;
    static int get language => _language;
    static void setLanguage(String language)
    {
        switch(language)
        {
            case "en": _language = 0; break;
            case "ru": _language = 1; break;
            case "de": _language = 2; break;
            case "fr": _language = 3; break;
            case "pl": _language = 4; break;
            default: _language = 0; break;
        }
    }

    /* Non-translatable attributes */

    static const String dashed_string = "---";
    static const String models_integra = "Onkyo/Pioneer/Integra";
    static const String models_denon = "Denon/Marantz";
    static const String drawer_premium_link = "https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus";
    static const String drawer_desktop_link = "https://www.microsoft.com/store/apps/9P9V57CZ8JG3";
    static const String pref_cover_click_default = "display-mode";
    static const String pref_sound_control_default = "device";
    static const String pref_theme_default = "indigo-orange";
    static const String pref_language_default = "system";
    static const String pref_text_size_default = "normal";
    static const String listening_mode_mode_00 = "Stereo";
    static const String listening_mode_mode_01 = "Direct";
    static const String listening_mode_mode_02 = "Surround";
    static const String listening_mode_mode_03 = "Game-RPG";
    static const String listening_mode_mode_04 = "THX";
    static const String listening_mode_mode_05 = "Game-Action";
    static const String listening_mode_mode_06 = "Game-Rock";
    static const String listening_mode_mode_07 = "Mono Movie";
    static const String listening_mode_mode_08 = "Orchestra";
    static const String listening_mode_mode_09 = "Unplugged";
    static const String listening_mode_mode_0a = "Studio-Mix";
    static const String listening_mode_mode_0b = "TV Logic";
    static const String listening_mode_mode_0c = "All Ch Stereo";
    static const String listening_mode_mode_0d = "Theater-Dimensional";
    static const String listening_mode_mode_0e = "Game-Sports";
    static const String listening_mode_mode_0f = "Mono";
    static const String listening_mode_mode_11 = "Pure Audio";
    static const String listening_mode_mode_12 = "Multiplex";
    static const String listening_mode_mode_13 = "Full Mono";
    static const String listening_mode_mode_14 = "Surround Enhancer";
    static const String listening_mode_mode_15 = "DTS Surround Sensation";
    static const String listening_mode_mode_16 = "Audyssey DSX";
    static const String listening_mode_mode_17 = "DTS Virtual:X";
    static const String listening_mode_mode_1f = "Whole House Mode";
    static const String listening_mode_mode_40 = "Dolby Digital";
    static const String listening_mode_mode_41 = "Dolby EX/DTS ES";
    static const String listening_mode_mode_42 = "THX Cinema";
    static const String listening_mode_mode_43 = "THX Surround EX";
    static const String listening_mode_mode_44 = "THX Music";
    static const String listening_mode_mode_45 = "THX Games";
    static const String listening_mode_mode_50 = "THX U(2)/S(2)/I/S Cinema";
    static const String listening_mode_mode_51 = "THX MusicMode";
    static const String listening_mode_mode_52 = "THX Games Mode";
    static const String listening_mode_mode_80 = "Dolby Surround";
    static const String listening_mode_mode_81 = "Dolby Music";
    static const String listening_mode_mode_82 = "DTS Neural:X";
    static const String listening_mode_mode_83 = "DTS Music";
    static const String listening_mode_mode_84 = "Dolby THX Cinema";
    static const String listening_mode_mode_85 = "DTS THX Cinema";
    static const String listening_mode_mode_86 = "Dolby Game";
    static const String listening_mode_mode_87 = "Neural Surround";
    static const String listening_mode_mode_88 = "Neural THX";
    static const String listening_mode_mode_89 = "Dolby THX Games";
    static const String listening_mode_mode_8a = "DTS THX Games";
    static const String listening_mode_mode_8b = "Dolby THX Music";
    static const String listening_mode_mode_8c = "DTS THX Music";
    static const String listening_mode_mode_8d = "Neural THX Cinema";
    static const String listening_mode_mode_8e = "Neural THX Music";
    static const String listening_mode_mode_8f = "Neural THX Games";
    static const String listening_mode_mode_90 = "PLIIz Height";
    static const String listening_mode_mode_91 = "Neo:6 Cinema DTS Surround Sensation";
    static const String listening_mode_mode_92 = "Neo:6 Music DTS Surround Sensation";
    static const String listening_mode_mode_93 = "Neural Digital Music";
    static const String listening_mode_mode_94 = "PLIIz Height + THX Cinema";
    static const String listening_mode_mode_95 = "PLIIz Height + THX Music";
    static const String listening_mode_mode_96 = "PLIIz Height + THX Games";
    static const String listening_mode_mode_97 = "PLIIz Height + THX U2/S2 Cinema";
    static const String listening_mode_mode_98 = "PLIIz Height + THX U2/S2 Music";
    static const String listening_mode_mode_99 = "PLIIz Height + THX U2/S2 Games";
    static const String listening_mode_mode_9a = "Neo:X Game";
    static const String listening_mode_mode_a0 = "Dolby Movie + Audyssey DSX";
    static const String listening_mode_mode_a1 = "Dolby Music + Audyssey DSX";
    static const String listening_mode_mode_a2 = "Dolby Game + Audyssey DSX";
    static const String listening_mode_mode_a3 = "Neo:6 Cinema + Audyssey DSX";
    static const String listening_mode_mode_a4 = "Neo:6 Music + Audyssey DSX";
    static const String listening_mode_mode_a5 = "Neural Surround + Audyssey DSX";
    static const String listening_mode_mode_a6 = "Neural Digital Music + Audyssey DSX";
    static const String listening_mode_mode_a7 = "Dolby EX + Audyssey DSX";
    static const String listening_mode_mode_ff = "Auto Surround";
    static const String listening_mode_music = "MUSIC";
    static const String listening_mode_movie = "MOVIE";
    static const String listening_mode_game = "GAME";
    static const String listening_mode_stereo = "STEREO";
    static const String listening_mode_thx = "THX";
    static const String listening_mode_pure_direct = "Pure Direct";
    static const String listening_mode_auto = "Auto";
    static const String listening_mode_dts_surround = "DTS Surround";
    static const String listening_mode_auro3d = "Auro 3D";
    static const String listening_mode_auro2d_surr = "Auro 2D SURR";
    static const String listening_mode_mch_stereo = "MCH Stereo";
    static const String listening_mode_wide_screen = "Wide Screen";
    static const String listening_mode_super_stadium = "Super Stadium";
    static const String listening_mode_rock_arena = "Rock Arena";
    static const String listening_mode_jazz_club = "Jazz Club";
    static const String listening_mode_classic_concert = "Classic Concert";
    static const String listening_mode_mono_movie = "Mono Movie";
    static const String listening_mode_matrix = "Matrix";
    static const String listening_mode_video_game = "Video Game";
    static const String listening_mode_vitrual = "Virtual";

    /* Non-translatable arrays */

    static const List<String> pref_cover_click_codes = [
        "none",
        "display-mode",
        "audio-mute"];
    static const List<String> pref_sound_control_codes = [
        "none",
        "external-amplifier",
        "device",
        "device-slider",
        "device-btn-slider",
        "device-btn-above-slider",
        "auto"];
    static const List<String> pref_theme_codes = [
        "black-lime",
        "dim-gray-cyan",
        "dim-gray-yellow",
        "gray-deep-purple",
        "indigo-orange",
        "teal-deep-orange",
        "purple-green"];
    static const List<String> pref_language_codes = [
        "system",
        "en",
        "fr",
        "ru",
        "de",
        "pl"];
    static const List<String> pref_text_size_codes = [
        "small",
        "normal",
        "big",
        "huge"];

    /* Translatable attributes */

    static const List<String> l_app_name = [
        /*en*/ "Enhanced Music Controller Lite",
        /*ru*/ "Enhanced Music Controller Lite",
        /*de*/ "Enhanced Music Controller Lite",
        /*fr*/ "Enhanced Music Controller Lite",
        /*pl*/ "Enhanced Music Controller Lite"];
    static String get app_name => l_app_name[_language];

    static const List<String> l_app_name_pro = [
        /*en*/ "Enhanced Music Controller",
        /*ru*/ "Enhanced Music Controller",
        /*de*/ "Enhanced Music Controller",
        /*fr*/ "Enhanced Music Controller",
        /*pl*/ "Enhanced Music Controller"];
    static String get app_name_pro => l_app_name_pro[_language];

    static const List<String> l_app_short_name = [
        /*en*/ "Music Control",
        /*ru*/ "Music Control",
        /*de*/ "Music Control",
        /*fr*/ "Music Control",
        /*pl*/ "Music Control"];
    static String get app_short_name => l_app_short_name[_language];

    static const List<String> l_app_description = [
        /*en*/ "Enhanced AVR controller: listen to music properly!",
        /*ru*/ "Улучшенный AVR-контроллер: слушайте музыку правильно!",
        /*de*/ "Verbesserter AVR-Controller: Musik richtig hören!",
        /*fr*/ "Contrôleur AVR amélioré: Ecoutez votre musique correctement!",
        /*pl*/ "Ulepszony kontroler AVR: słuchaj muzyki poprawnie!"];
    static String get app_description => l_app_description[_language];

    static const List<String> l_state_not_connected = [
        /*en*/ "Not connected",
        /*ru*/ "Отсутствует соединение",
        /*de*/ "Nicht verbunden",
        /*fr*/ "Pas de connexion",
        /*pl*/ "Nie połączono"];
    static String get state_not_connected => l_state_not_connected[_language];

    static const List<String> l_state_standby = [
        /*en*/ "Standby",
        /*ru*/ "Ожидание",
        /*de*/ "Schlafmodus",
        /*fr*/ "Éteint",
        /*pl*/ "Standby"];
    static String get state_standby => l_state_standby[_language];

    static const List<String> l_action_exit_confirm = [
        /*en*/ "Press back button again to exit",
        /*ru*/ "Для выхода нажмите Назад дважды",
        /*de*/ "Zum Beenden erneut zurück drücken",
        /*fr*/ "Appuyez sur retour pour quitter",
        /*pl*/ "Naciśnij ponownie przycisk wstecz aby wyjść"];
    static String get action_exit_confirm => l_action_exit_confirm[_language];

    static const List<String> l_action_ok = [
        /*en*/ "OK",
        /*ru*/ "OK",
        /*de*/ "OK",
        /*fr*/ "OK",
        /*pl*/ "OK"];
    static String get action_ok => l_action_ok[_language];

    static const List<String> l_action_no = [
        /*en*/ "No",
        /*ru*/ "Нет",
        /*de*/ "Nein",
        /*fr*/ "Non",
        /*pl*/ "Nie"];
    static String get action_no => l_action_no[_language];

    static const List<String> l_action_cancel = [
        /*en*/ "Cancel",
        /*ru*/ "Отмена",
        /*de*/ "Abbrechen",
        /*fr*/ "Annuler",
        /*pl*/ "Wstecz"];
    static String get action_cancel => l_action_cancel[_language];

    static const List<String> l_action_context_mobile = [
        /*en*/ "using long click",
        /*ru*/ "используя долгое нажатие",
        /*de*/ "mit einem langen Klick",
        /*fr*/ "en utilisant un clic long",
        /*pl*/ "za pomocą długiego kliknięcia"];
    static String get action_context_mobile => l_action_context_mobile[_language];

    static const List<String> l_action_context_desktop = [
        /*en*/ "right mouse button",
        /*ru*/ "используя правую клавишу мыши",
        /*de*/ "mit rechte Maustaste",
        /*fr*/ "bouton droit de la souris",
        /*pl*/ "prawy przycisk myszy"];
    static String get action_context_desktop => l_action_context_desktop[_language];

    static const List<String> l_about_text = [
        /*en*/ """
# Enhanced AVR Controller
Listen to music properly!

Copyright © 2019-2024 by __Mikhail Kulesh__

This app allows remote control of a Network Player or a Network A/V Receiver via the local network.
The app supports Onkyo/Pioneer/Integra released in April 2016 or later and Denon/Marantz with build-in HEOS technology.
Its two most popular features are music playback and sound profile management.

## Links

Public repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

Versions: [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus), [macOS](https://apps.apple.com/app/id1490166845), [iOS](https://apps.apple.com/app/id1490166845), [Windows](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Used Open Source Libraries

* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)

Enjoy!""",
        /*ru*/ """
# Улучшенный AVR-контроллер
Слушайте музыку правильно!

Copyright © 2019-2024 by __Михаил Кулеш__

Это приложение позволяет удаленно управлять сетевым проигрывателем или сетевым AV-ресивером по локальной сети.
Приложение поддерживает Onkyo/Pioneer/Integra, выпущенные в апреле 2016 года или позже, и Denon/Marantz со встроенной технологией HEOS.
Основное предназначение программы - управление воспроизведением и звуковыми профилями.

## Ссылки

Репозиторий с исходным кодом: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

Версии: [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus), [macOS](https://apps.apple.com/app/id1490166845), [iOS](https://apps.apple.com/app/id1490166845), [Windows](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

## Лицензия

Данная программа является свободным программным обеспечением. Вы вправе распространять ее и/или модифицировать в соответствии с условиями версии 3 либо по вашему выбору с условиями более поздней версии Стандартной Общественной Лицензии GNU, опубликованной Free Software Foundation.

Мы распространяем данную программу в надежде на то, что она будет вам полезной, однако НЕ ПРЕДОСТАВЛЯЕМ НА НЕЕ НИКАКИХ ГАРАНТИЙ, в том числе ГАРАНТИИ ТОВАРНОГО СОСТОЯНИЯ ПРИ ПРОДАЖЕ и ПРИГОДНОСТИ ДЛЯ ИСПОЛЬЗОВАНИЯ В КОНКРЕТНЫХ ЦЕЛЯХ. Для получения более подробной информации ознакомьтесь со Стандартной Общественной Лицензией GNU.

Вместе с данной программой вы должны были получить экземпляр [Стандартной Общественной Лицензии GNU](https://www.gnu.org/licenses)

## Библиотеки с открытым исходным кодом

* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)""",
        /*de*/ """
# Verbesserter AVR-Controller
Musik richtig hören!

Copyright © 2019-2024 by __Mikhail Kulesh__

Diese App ermöglicht die Fernsteuerung eines Netzwerkplayers oder eines Netzwerk-A/V-Receivers über das lokale Netzwerk.
Die App unterstützt Onkyo/Pioneer/Integra, die im April 2016 oder später veröffentlicht wurden, und Denon/Marantz mit integrierter HEOS-Technologie.
Die beiden beliebtesten Funktionen sind Abspielsteuerung und Klangprofil Auswahl.

## Links

Öffentliches repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

Versionen: [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus), [macOS](https://apps.apple.com/app/id1490166845), [iOS](https://apps.apple.com/app/id1490166845), [Windows](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

## Lizenz

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Genutzte Open Source Bibliotheken

* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)""",
        /*fr*/ """
# Contrôleur AVR amélioré
Ecoutez votre musique correctement!

Copyright © 2019-2024 by __Mikhail Kulesh__

Cette application permet le contrôle à distance d\'un lecteur réseau ou d\'un récepteur réseau A/V via le réseau local.
L\'application prend en charge Onkyo/Pioneer/Integra sorti en avril 2016 ou plus tard et Denon/Marantz avec la technologie HEOS intégrée.
Ses deux principales fonctions sont la commande de la musique et la gestion des profils audios.

## Liens

Référentiel public: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

Versions: [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus), [macOS](https://apps.apple.com/app/id1490166845), [iOS](https://apps.apple.com/app/id1490166845), [Windows](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

## Licence

Ce programme est à usage gratuit: vous pouvez le distribuer et/ou le modifier celon les termes de GNU La "General Public License" telle que publiée par le "Free Software Foundation", sous la version 3 de la licence ou (à votre choix) toute version posterieure.

Ce programme est publié dans l\'espoir qu\'il soit utile, mais SANS GARANTIE; sans même la garantie implicite d\'une QUALITE MARCHANDE ou sa FIABILITE POUR UN USAGE QUELCONQUE. Voir GNU General Public License pour plus d\'information. Vous devez avoir reçu une copie de la GNU General Public License avec ce programme.

## Used Open Source Libraries

* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)
""",
        /*pl*/ """
# Enhanced AVR Controller
Listen to music properly!

Copyright © 2019-2024 by __Mikhail Kulesh__

This app allows remote control of a Network Player or a Network A/V Receiver via the local network.
The app supports Onkyo/Pioneer/Integra released in April 2016 or later and Denon/Marantz with build-in HEOS technology.
Its two most popular features are music playback and sound profile management.

## Links

Public repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

Versions: [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus), [macOS](https://apps.apple.com/app/id1490166845), [iOS](https://apps.apple.com/app/id1490166845), [Windows](https://www.microsoft.com/store/apps/9P9V57CZ8JG3)

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Used Open Source Libraries

* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)

Enjoy!"""];
    static String get about_text => l_about_text[_language];

    static const List<String> l_drawer_open = [
        /*en*/ "Open navigation drawer",
        /*ru*/ "Открыть панель навигатора",
        /*de*/ "Navigation drawer öffnen",
        /*fr*/ "Ouvrir le panneau de navigation",
        /*pl*/ "Okno nawigacji"];
    static String get drawer_open => l_drawer_open[_language];

    static const List<String> l_drawer_group_zone = [
        /*en*/ "Zone",
        /*ru*/ "Зона",
        /*de*/ "Zone",
        /*fr*/ "Zone",
        /*pl*/ "Strefa"];
    static String get drawer_group_zone => l_drawer_group_zone[_language];

    static const List<String> l_drawer_all_standby = [
        /*en*/ "All Zones standby",
        /*ru*/ "Выкл. все зоны",
        /*de*/ "Alle Zonen aus",
        /*fr*/ "Veille de toutes les zones",
        /*pl*/ "Wszystkie strefy czuwania"];
    static String get drawer_all_standby => l_drawer_all_standby[_language];

    static const List<String> l_drawer_multiroom = [
        /*en*/ "Group",
        /*ru*/ "Группа",
        /*de*/ "Gruppe",
        /*fr*/ "Groupe",
        /*pl*/ "Grupa"];
    static String get drawer_multiroom => l_drawer_multiroom[_language];

    static const List<String> l_drawer_device = [
        /*en*/ "Device",
        /*ru*/ "Устройство",
        /*de*/ "Gerät",
        /*fr*/ "Équipement",
        /*pl*/ "Urządzenie"];
    static String get drawer_device => l_drawer_device[_language];

    static const List<String> l_drawer_device_connect = [
        /*en*/ "Connect",
        /*ru*/ "Соединение",
        /*de*/ "Verbinden",
        /*fr*/ "Connecter",
        /*pl*/ "Połącz"];
    static String get drawer_device_connect => l_drawer_device_connect[_language];

    static const List<String> l_drawer_device_search = [
        /*en*/ "Search",
        /*ru*/ "Поиск",
        /*de*/ "Suchen",
        /*fr*/ "Recherche",
        /*pl*/ "Szukaj"];
    static String get drawer_device_search => l_drawer_device_search[_language];

    static const List<String> l_drawer_device_searching = [
        /*en*/ "Searching for compatible devices…",
        /*ru*/ "Поиск совестимых устройств…",
        /*de*/ "Suchen…",
        /*fr*/ "Recherche d\'équipements compatibles…",
        /*pl*/ "Wyszukiwanie kompatybilnych urządzeń…"];
    static String get drawer_device_searching => l_drawer_device_searching[_language];

    static const List<String> l_drawer_application = [
        /*en*/ "Application",
        /*ru*/ "Приложение",
        /*de*/ "Anwendung",
        /*fr*/ "Application",
        /*pl*/ "Aplikacja"];
    static String get drawer_application => l_drawer_application[_language];

    static const List<String> l_drawer_tab_layout = [
        /*en*/ "Tab layout",
        /*ru*/ "Вид вкладки",
        /*de*/ "Registerkartenlayout",
        /*fr*/ "Disposition des onglets",
        /*pl*/ "Układ kart"];
    static String get drawer_tab_layout => l_drawer_tab_layout[_language];

    static const List<String> l_drawer_app_settings = [
        /*en*/ "Settings",
        /*ru*/ "Настройки",
        /*de*/ "Einstellungen",
        /*fr*/ "Paramètres",
        /*pl*/ "Ustawienia"];
    static String get drawer_app_settings => l_drawer_app_settings[_language];

    static const List<String> l_drawer_about = [
        /*en*/ "About",
        /*ru*/ "О программе",
        /*de*/ "Über",
        /*fr*/ "À propos",
        /*pl*/ "Info"];
    static String get drawer_about => l_drawer_about[_language];

    static const List<String> l_drawer_premium = [
        /*en*/ "Get Premium version",
        /*ru*/ "Попробуйте \"Премиум\" версию",
        /*de*/ "Probieren Sie die Premium-Version aus",
        /*fr*/ "Essayez la version Premium",
        /*pl*/ "Wypróbuj wersję Premium"];
    static String get drawer_premium => l_drawer_premium[_language];

    static const List<String> l_drawer_desktop = [
        /*en*/ "Desktop version",
        /*ru*/ "Версия для ПК",
        /*de*/ "Desktop-Version",
        /*fr*/ "Version de bureau",
        /*pl*/ "Wersja na komputer"];
    static String get drawer_desktop => l_drawer_desktop[_language];

    static const List<String> l_connect_dialog_address = [
        /*en*/ "Address",
        /*ru*/ "Адрес",
        /*de*/ "Adresse",
        /*fr*/ "Adresse IP",
        /*pl*/ "Adres IP"];
    static String get connect_dialog_address => l_connect_dialog_address[_language];

    static const List<String> l_connect_dialog_port = [
        /*en*/ "Port (optional)",
        /*ru*/ "Порт (необязательно)",
        /*de*/ "Port (optional)",
        /*fr*/ "Port (optionnel)",
        /*pl*/ "Port (opcjonalnie)"];
    static String get connect_dialog_port => l_connect_dialog_port[_language];

    static const List<String> l_connect_dialog_save = [
        /*en*/ "Save connection",
        /*ru*/ "Сохранить соединение",
        /*de*/ "Verbindung speichern",
        /*fr*/ "Enregistrer la connexion",
        /*pl*/ "Zapisz połączenie"];
    static String get connect_dialog_save => l_connect_dialog_save[_language];

    static const List<String> l_favorite_connection_edit = [
        /*en*/ "Edit connection",
        /*ru*/ "Изменить соединение",
        /*de*/ "Verbindung bearbeiten",
        /*fr*/ "Modifier la connexion",
        /*pl*/ "Edytuj połączenie"];
    static String get favorite_connection_edit => l_favorite_connection_edit[_language];

    static const List<String> l_favorite_connection_identifier = [
        /*en*/ "MAC Address (optional)",
        /*ru*/ "MAC адрес (необязательно)",
        /*de*/ "MAC Adresse (optional)",
        /*fr*/ "Adresse MAC (optionnelle)",
        /*pl*/ "Adres MAC (opcjonalnie)"];
    static String get favorite_connection_identifier => l_favorite_connection_identifier[_language];

    static const List<String> l_favorite_shortcut_edit = [
        /*en*/ "Edit shortcut",
        /*ru*/ "Изменить ярлык",
        /*de*/ "Favorit bearbeiten",
        /*fr*/ "Modifier le raccourci",
        /*pl*/ "Edytuj skrót"];
    static String get favorite_shortcut_edit => l_favorite_shortcut_edit[_language];

    static const List<String> l_favorite_shortcut_create = [
        /*en*/ "Create shortcut",
        /*ru*/ "Создать ярлык",
        /*de*/ "Favorit erstellen",
        /*fr*/ "Créer un raccourci",
        /*pl*/ "Utwórz skrót"];
    static String get favorite_shortcut_create => l_favorite_shortcut_create[_language];

    static const List<String> l_favorite_shortcut_added = [
        /*en*/ "Shortcut added",
        /*ru*/ "Ярлык добавлен",
        /*de*/ "Favorit hinzugefügt",
        /*fr*/ "Raccourci ajouté",
        /*pl*/ "Dodano skrót"];
    static String get favorite_shortcut_added => l_favorite_shortcut_added[_language];

    static const List<String> l_favorite_shortcut_failed = [
        /*en*/ "Cannot create shortcut: navigate to the media item from the top level",
        /*ru*/ "Невозможно создать ярлык: перейдите к мультимедиа-элементу начиная с верхнего уровня",
        /*de*/ "Favorit kann nicht erstellt werden: Navigieren Sie von der obersten Ebene zum Medienelement",
        /*fr*/ "Impossible de créer un raccourci: accédez à l\'élément multimédia à partir du niveau supérieur",
        /*pl*/ "Nie można utworzyć skrótu: przejdź do elementu multimedialnego z najwyższego poziomu"];
    static String get favorite_shortcut_failed => l_favorite_shortcut_failed[_language];

    static const List<String> l_favorite_shortcut_howto = [
        /*en*/ "To add shortcut: open \"%s\" tab, navigate to a media item from the top level, open context menu (%s) and select \"%s\"",
        /*ru*/ "Чтобы добавить ярлык: откройте вкладку \"%s\", перейдите к мультимедиа-элементу начиная с верхнего уровня, откройте контекстное меню (%s) и выберите \"%s\"",
        /*de*/ "Bisher kein Favorit gesetzt. So fügen Sie einen Favoriten hinzu: Öffnen Sie die Registerkarte \"%s\", navigieren Sie von der obersten Ebene zu einem Medienelement, öffnen Sie das Kontextmenü (%s) und wählen Sie \"%s\".",
        /*fr*/ "Pour ajouter un raccourci: ouvrez l\'onglet \"%s\", accédez à un élément multimédia du niveau supérieur, ouvrez le menu contextuel (%s) et sélectionnez \"%s\"",
        /*pl*/ "Aby dodać skrót: otwórz zakładkę \"%s\", przejdź do elementu multimedialnego z najwyższego poziomu, otwórz menu kontekstowe (%s) i wybierz \"%s\""];
    static String get favorite_shortcut_howto => l_favorite_shortcut_howto[_language];

    static const List<String> l_favorite_copy_to_clipboard = [
        /*en*/ "Copy to clipboard",
        /*ru*/ "Скопировать в буфер обмена",
        /*de*/ "In die Zwischenablage kopieren",
        /*fr*/ "Copier dans le presse-papier",
        /*pl*/ "Skopiuj do schowka"];
    static String get favorite_copy_to_clipboard => l_favorite_copy_to_clipboard[_language];

    static const List<String> l_menu_power_standby = [
        /*en*/ "On/Standby",
        /*ru*/ "Вкл/выкл",
        /*de*/ "An/Standby",
        /*fr*/ "marche/arrêt",
        /*pl*/ "On/Standby"];
    static String get menu_power_standby => l_menu_power_standby[_language];

    static const List<String> l_menu_receiver_information = [
        /*en*/ "Receiver information",
        /*ru*/ "Информация об устройстве",
        /*de*/ "Receiver Informationen",
        /*fr*/ "Information du récepteur",
        /*pl*/ "Informacje o urządzeniu"];
    static String get menu_receiver_information => l_menu_receiver_information[_language];

    static const List<String> l_menu_latest_logging = [
        /*en*/ "Latest logging",
        /*ru*/ "Лог приложения",
        /*de*/ "Letztes Log",
        /*fr*/ "Dernière entrée",
        /*pl*/ "Ostatnie logowanie"];
    static String get menu_latest_logging => l_menu_latest_logging[_language];

    static const List<String> l_menu_switch_off_group = [
        /*en*/ "Switch off all devices in the group?",
        /*ru*/ "Выключить все устройства в группе?",
        /*de*/ "Alle Geräte in der Gruppe ausschalten?",
        /*fr*/ "Éteindre tous les appareils du groupe?",
        /*pl*/ "Wyłączyć wszystkie urządzenia w grupie?"];
    static String get menu_switch_off_group => l_menu_switch_off_group[_language];

    static const List<String> l_shortcut_power_on = [
        /*en*/ "Power On",
        /*ru*/ "Включить",
        /*de*/ "Einschalten",
        /*fr*/ "Allumer",
        /*pl*/ "Zasilanie włączone"];
    static String get shortcut_power_on => l_shortcut_power_on[_language];

    static const List<String> l_pref_category_widget = [
        /*en*/ "Widget options",
        /*ru*/ "Настройки виджета",
        /*de*/ "Widget Optionen",
        /*fr*/ "Options des widgets",
        /*pl*/ "Opcje widgetów"];
    static String get pref_category_widget => l_pref_category_widget[_language];

    static const List<String> l_pref_widget_theme = [
        /*en*/ "Widget theme",
        /*ru*/ "Тема виджета",
        /*de*/ "Widget Thema",
        /*fr*/ "Widget Thème",
        /*pl*/ "Widget motyw"];
    static String get pref_widget_theme => l_pref_widget_theme[_language];

    static const List<String> l_pref_widget_transparency = [
        /*en*/ "Transparency",
        /*ru*/ "Прозрачность",
        /*de*/ "Transparenz",
        /*fr*/ "Transparence",
        /*pl*/ "Przezroczystość"];
    static String get pref_widget_transparency => l_pref_widget_transparency[_language];

    static const List<String> l_pref_category_device_options = [
        /*en*/ "Device options",
        /*ru*/ "Настройки устройства",
        /*de*/ "Gerät Optionen",
        /*fr*/ "Options dispositif",
        /*pl*/ "Opcje urządzenia"];
    static String get pref_category_device_options => l_pref_category_device_options[_language];

    static const List<String> l_pref_category_advanced_options = [
        /*en*/ "Advanced",
        /*ru*/ "Дополнительно",
        /*de*/ "Erweitert",
        /*fr*/ "Avancé",
        /*pl*/ "Zaawansowane"];
    static String get pref_category_advanced_options => l_pref_category_advanced_options[_language];

    static const List<String> l_pref_volume_title = [
        /*en*/ "Volume keys turning",
        /*ru*/ "Управление громкостью",
        /*de*/ "Lautstärketasten verwenden",
        /*fr*/ "Boutons volume",
        /*pl*/ "Przyciski głośności"];
    static String get pref_volume_title => l_pref_volume_title[_language];

    static const List<String> l_pref_volume_summary = [
        /*en*/ "Use volume keys to change master volume on remote device",
        /*ru*/ "Используйте кнопки управления громкостью для изменения уровня звука на удаленном устройстве",
        /*de*/ "Lautstärketasten des Handys verwenden um Master-Lautstärke zu ändern",
        /*fr*/ "Utiliser les boutons volume pour modifier le volume de l\'appareil connecté",
        /*pl*/ "Użyj klawiszy głośności, aby zmienić głośność główną na urządzeniu zdalnym"];
    static String get pref_volume_summary => l_pref_volume_summary[_language];

    static const List<String> l_pref_back_as_return = [
        /*en*/ "Back button as \"Return\"",
        /*ru*/ "Кнопка возврата как \"Назад\"",
        /*de*/ "Zurück-Taste in Medien",
        /*fr*/ "Bouton retour",
        /*pl*/ "Przycisk Wstecz jako \"Powrót\""];
    static String get pref_back_as_return => l_pref_back_as_return[_language];

    static const List<String> l_pref_back_as_return_summary = [
        /*en*/ "Use back button to switch to the parent level in the media list",
        /*ru*/ "Использовать кнопку возврата для перехода на предыдущий уровень в медиатеке",
        /*de*/ "Zurück-Taste verwenden, um in Medien den übergeordneten Ordner zu wählen",
        /*fr*/ "Utiliser le bouton Retour pour remonter au niveau parent de la liste des médias",
        /*pl*/ "Użyj przycisku Wstecz, aby przełączyć na poziom nadrzędny na liście multimediów"];
    static String get pref_back_as_return_summary => l_pref_back_as_return_summary[_language];

    static const List<String> l_pref_advanced_queue = [
        /*en*/ "Advanced play queue options",
        /*ru*/ "Расширенные возможности Play Queue",
        /*de*/ "Erweiterte Optionen von Play Queue",
        /*fr*/ "Files d\'attentes avancées",
        /*pl*/ "Zaawansowane opcje kolejki odtwarzania"];
    static String get pref_advanced_queue => l_pref_advanced_queue[_language];

    static const List<String> l_pref_advanced_queue_summary = [
        /*en*/ "Experimental: use advanced play queue features",
        /*ru*/ "Использовать экспериментальные возможности очереди воспроизведения",
        /*de*/ "Experimentell: fortgeschrittene Funktionen in Play Queue verwenden",
        /*fr*/ "Expérimental: gestion évoluée des files d\'attentes",
        /*pl*/ "Eksperymentalna: Korzystaj z zaawansowanych funkcji kolejki odtwarzania"];
    static String get pref_advanced_queue_summary => l_pref_advanced_queue_summary[_language];

    static const List<String> l_pref_keep_playback_mode = [
        /*en*/ "Keep playback mode",
        /*ru*/ "Режим воспроизведения",
        /*de*/ "Abspielmodus behalten",
        /*fr*/ "Maintenir le mode lecture",
        /*pl*/ "Zachowaj tryb odtwarzania"];
    static String get pref_keep_playback_mode => l_pref_keep_playback_mode[_language];

    static const List<String> l_pref_keep_playback_mode_summary = [
        /*en*/ "Always keep playback mode in MEDIA tab while playing",
        /*ru*/ "Во вкладке КАНАЛЫ всегда оставаться в режиме воспроизведения.",
        /*de*/ "Während die Wiedergabe aktiv ist, Abspielmodus in MEDIEN behalten",
        /*fr*/ "Toujours conserver le mode lecture dans l\'onglet SOURCE quand l\'écoute est en cours",
        /*pl*/ "Zawsze zachowuj tryb odtwarzania na karcie MEDIA podczas odtwarzania"];
    static String get pref_keep_playback_mode_summary => l_pref_keep_playback_mode_summary[_language];

    static const List<String> l_pref_exit_confirm = [
        /*en*/ "Press back button twice for exit",
        /*ru*/ "Для выхода нажмите \"Назад\" дважды",
        /*de*/ "Zweimal zurück zum Beenden",
        /*fr*/ "Bouton retour deux fois pour quitter",
        /*pl*/ "Naciśnij dwukrotnie przycisk Wstecz, aby wyjść"];
    static String get pref_exit_confirm => l_pref_exit_confirm[_language];

    static const List<String> l_pref_keep_screen_on = [
        /*en*/ "Keep the screen turned on",
        /*ru*/ "Не гасить экран",
        /*de*/ "Bildschirm aktiv lassen",
        /*fr*/ "Écran toujours allumé",
        /*pl*/ "Ekran zawsze włączony"];
    static String get pref_keep_screen_on => l_pref_keep_screen_on[_language];

    static const List<String> l_pref_show_when_locked = [
        /*en*/ "On top of the lock screen",
        /*ru*/ "Поверх экрана блокировки",
        /*de*/ "Oben auf dem Sperrbildschirm",
        /*fr*/ "En haut de l\'écran de verrouillage",
        /*pl*/ "Na górze ekranu blokady"];
    static String get pref_show_when_locked => l_pref_show_when_locked[_language];

    static const List<String> l_pref_show_when_locked_summary = [
        /*en*/ "App can start on-top of the lock screen",
        /*ru*/ "Приложение может запускаться поверх экрана блокировки",
        /*de*/ "Die App kann oben auf dem Sperrbildschirm gestartet werden",
        /*fr*/ "L\'application peut démarrer en haut de l\'écran de verrouillage",
        /*pl*/ "Aplikację można uruchomić na ekranie blokady"];
    static String get pref_show_when_locked_summary => l_pref_show_when_locked_summary[_language];

    static const List<String> l_pref_developer_mode = [
        /*en*/ "Developer options",
        /*ru*/ "Для разработчика",
        /*de*/ "Entwicklereinstellungen",
        /*fr*/ "Options développeurs",
        /*pl*/ "Opcje deweloperskie"];
    static String get pref_developer_mode => l_pref_developer_mode[_language];

    static const List<String> l_pref_device_selectors = [
        /*en*/ "Input selectors",
        /*ru*/ "Входные каналы",
        /*de*/ "Eingangskanäle",
        /*fr*/ "Sélection des sources",
        /*pl*/ "Wybór wejścia"];
    static String get pref_device_selectors => l_pref_device_selectors[_language];

    static const List<String> l_pref_listening_modes = [
        /*en*/ "Listening modes",
        /*ru*/ "Звуковые профили",
        /*de*/ "Klangprofile",
        /*fr*/ "Modes d\'écoutes",
        /*pl*/ "Tryb dźwięku"];
    static String get pref_listening_modes => l_pref_listening_modes[_language];

    static const List<String> l_pref_network_services = [
        /*en*/ "Network services",
        /*ru*/ "Сетевые сервисы",
        /*de*/ "Netzwerkdienste",
        /*fr*/ "Sources réseau",
        /*pl*/ "Usługi sieciowe"];
    static String get pref_network_services => l_pref_network_services[_language];

    static const List<String> l_pref_usb_ri_interface = [
        /*en*/ "Use USB-RI interface",
        /*ru*/ "Использовать интерфейс USB-RI",
        /*de*/ "USB-RI-Schnittstelle verwenden",
        /*fr*/ "Utiliser l\'interface USB-RI",
        /*pl*/ "Użyj interfejsu USB-RI"];
    static String get pref_usb_ri_interface => l_pref_usb_ri_interface[_language];

    static const List<String> l_pref_usb_ri_interface_none = [
        /*en*/ "None",
        /*ru*/ "Нет",
        /*de*/ "Keine",
        /*fr*/ "Aucun",
        /*pl*/ "Brak"];
    static String get pref_usb_ri_interface_none => l_pref_usb_ri_interface_none[_language];

    static const List<String> l_pref_column_separator = [
        /*en*/ "Position of column separator (%)",
        /*ru*/ "Положение разделителя столбцов (%)",
        /*de*/ "Position des Spaltentrenners (%)",
        /*fr*/ "Position du séparateur de colonnes (%)",
        /*pl*/ "Pozycja separatora kolumn (%)"];
    static String get pref_column_separator => l_pref_column_separator[_language];

    static const List<String> l_pref_keyboard_shortcuts = [
        /*en*/ "Global keyboard shortcuts",
        /*ru*/ "Глобальные сочетания клавиш",
        /*de*/ "Globale Tastaturkürzel",
        /*fr*/ "Raccourcis clavier globaux",
        /*pl*/ "Globalne skróty klawiaturowe"];
    static String get pref_keyboard_shortcuts => l_pref_keyboard_shortcuts[_language];

    static const List<String> l_pref_item_update = [
        /*en*/ "Edit",
        /*ru*/ "Изменить",
        /*de*/ "Bearbeiten",
        /*fr*/ "Modifier",
        /*pl*/ "Edytuj"];
    static String get pref_item_update => l_pref_item_update[_language];

    static const List<String> l_pref_item_delete = [
        /*en*/ "Delete",
        /*ru*/ "Удалить",
        /*de*/ "Löschen",
        /*fr*/ "Supprimer",
        /*pl*/ "Usuń"];
    static String get pref_item_delete => l_pref_item_delete[_language];

    static const List<String> l_pref_item_name = [
        /*en*/ "Name",
        /*ru*/ "Имя",
        /*de*/ "Name",
        /*fr*/ "Nom",
        /*pl*/ "Nazwa"];
    static String get pref_item_name => l_pref_item_name[_language];

    static const List<String> l_pref_auto_power = [
        /*en*/ "Switch-on remote device on app startup",
        /*ru*/ "Включить удаленное устройство при запуске приложения",
        /*de*/ "Remote-Gerät beim Start der App einschalten",
        /*fr*/ "Allumer le dispositif au démarrage de l\'application",
        /*pl*/ "Włącz zdalne urządzenie podczas uruchamiania aplikacji"];
    static String get pref_auto_power => l_pref_auto_power[_language];

    static const List<String> l_pref_friendly_names = [
        /*en*/ "Friendly selector and device names",
        /*ru*/ "Удобные названия каналов и устройства",
        /*de*/ "Lesbare Kanal- und Gerätenamen",
        /*fr*/ "Noms personnalisés des sources et dispositifs",
        /*pl*/ "Nazwa urządzenia"];
    static String get pref_friendly_names => l_pref_friendly_names[_language];

    static const List<String> l_pref_friendly_names_summary_on = [
        /*en*/ "Use friendly names provided by remote device",
        /*ru*/ "Использовать удобные названия, предоставленные удалённым устройством",
        /*de*/ "Lesbare Namen des Onkyo-Geräts nutzen",
        /*fr*/ "Utiliser les noms personnalisés émis par le dispositif",
        /*pl*/ "Używaj nazwy dostarczonej przez zdalne urządzenie"];
    static String get pref_friendly_names_summary_on => l_pref_friendly_names_summary_on[_language];

    static const List<String> l_pref_friendly_names_summary_off = [
        /*en*/ "Use build-in names",
        /*ru*/ "Использовать встроенные названия",
        /*de*/ "Namen des Protokolls nutzen",
        /*fr*/ "Utiliser les noms génériques",
        /*pl*/ "Użyj wbudowanych nazw"];
    static String get pref_friendly_names_summary_off => l_pref_friendly_names_summary_off[_language];

    static const List<String> l_pref_force_audio_control = [
        /*en*/ "Audio control always available",
        /*ru*/ "Контроль звука всегда доступен",
        /*de*/ "Audiosteuerung immer verfügbar",
        /*fr*/ "Contrôle audio toujours disponible",
        /*pl*/ "Kontrola audio zawsze dostępna"];
    static String get pref_force_audio_control => l_pref_force_audio_control[_language];

    static const List<String> l_pref_volume_unit = [
        /*en*/ "Master volume unit",
        /*ru*/ "Обозначение уровня громкости",
        /*de*/ "Lautstärkeeinheit",
        /*fr*/ "Unité de volume principale",
        /*pl*/ "Jednostka głośności głównej"];
    static String get pref_volume_unit => l_pref_volume_unit[_language];

    static const List<String> l_pref_volume_unit_absolute = [
        /*en*/ "Absolute",
        /*ru*/ "Абсолютное",
        /*de*/ "Absolute",
        /*fr*/ "Absolue",
        /*pl*/ "Absolutny"];
    static String get pref_volume_unit_absolute => l_pref_volume_unit_absolute[_language];

    static const List<String> l_pref_volume_unit_relative = [
        /*en*/ "Relative (dB)",
        /*ru*/ "Относительное (дБ)",
        /*de*/ "Relativ (dB)",
        /*fr*/ "Relative (dB)",
        /*pl*/ "Względny (dB)"];
    static String get pref_volume_unit_relative => l_pref_volume_unit_relative[_language];

    static const List<String> l_pref_volume_unit_zero = [
        /*en*/ "Zero (0 dB) level",
        /*ru*/ "Нулевой (0 дБ) уровень",
        /*de*/ "Nullpegel (0 dB)",
        /*fr*/ "Niveau zéro (0 dB)",
        /*pl*/ "Poziom zerowy (0 dB)"];
    static String get pref_volume_unit_zero => l_pref_volume_unit_zero[_language];

    static const List<String> l_pref_cover_click = [
        /*en*/ "Album\'s cover click behaviour",
        /*ru*/ "Нажатие на обложку альбома",
        /*de*/ "Klickverhalten des Albumcovers",
        /*fr*/ "Comportement du clic sur la couverture de l\'album",
        /*pl*/ "Zachowanie kliknięcia okładki albumu"];
    static String get pref_cover_click => l_pref_cover_click[_language];

    static const List<String> l_pref_sound_control = [
        /*en*/ "Sound control",
        /*ru*/ "Управление звуком",
        /*de*/ "Lautstärkekontrolle",
        /*fr*/ "Contrôle du son",
        /*pl*/ "Kontrola dźwięku"];
    static String get pref_sound_control => l_pref_sound_control[_language];

    static const List<String> l_pref_theme = [
        /*en*/ "Theme",
        /*ru*/ "Тема",
        /*de*/ "Thema",
        /*fr*/ "Thème",
        /*pl*/ "Motyw"];
    static String get pref_theme => l_pref_theme[_language];

    static const List<String> l_pref_language = [
        /*en*/ "App language",
        /*ru*/ "Язык приложения",
        /*de*/ "App Sprache",
        /*fr*/ "Langue",
        /*pl*/ "Wybór języka"];
    static String get pref_language => l_pref_language[_language];

    static const List<String> l_pref_text_size = [
        /*en*/ "Text and buttons size",
        /*ru*/ "Размер кнопок и текста",
        /*de*/ "Beschriftungs- und Tastengröße",
        /*fr*/ "Taille texte et boutons",
        /*pl*/ "Rozmiar tekstu i przycisków"];
    static String get pref_text_size => l_pref_text_size[_language];

    static const List<String> l_pref_visible_tabs = [
        /*en*/ "Visible tabs",
        /*ru*/ "Видимые вкладки",
        /*de*/ "Sichtbare Registerkarten",
        /*fr*/ "Onglets visibles",
        /*pl*/ "Widoczne zakładki"];
    static String get pref_visible_tabs => l_pref_visible_tabs[_language];

    static const List<String> l_app_control_divider = [
        /*en*/ "Divider",
        /*ru*/ "Разделитель",
        /*de*/ "Teiler",
        /*fr*/ "Diviseur",
        /*pl*/ "Rozdzielacz"];
    static String get app_control_divider => l_app_control_divider[_language];

    static const List<String> l_app_control_listening_mode_list = [
        /*en*/ "Listening mode: list",
        /*ru*/ "Звуковой профиль: список",
        /*de*/ "Hörmodus: Liste",
        /*fr*/ "Mode d\'écoute: liste",
        /*pl*/ "Tryb odsłuchu: lista"];
    static String get app_control_listening_mode_list => l_app_control_listening_mode_list[_language];

    static const List<String> l_app_control_listening_mode_switch = [
        /*en*/ "Listening mode: switch",
        /*ru*/ "Звуковой профиль: переключатель",
        /*de*/ "Hörmodus: Schalter",
        /*fr*/ "Mode d\'écoute: commutateur",
        /*pl*/ "Tryb odsłuchu: przełącznik"];
    static String get app_control_listening_mode_switch => l_app_control_listening_mode_switch[_language];

    static const List<String> l_app_control_listening_mode_groups = [
        /*en*/ "Listening mode: groups",
        /*ru*/ "Звуковой профиль: группы",
        /*de*/ "Hörmodus: Gruppen",
        /*fr*/ "Mode d\'écoute: groupes",
        /*pl*/ "Tryb odsłuchu: grupy"];
    static String get app_control_listening_mode_groups => l_app_control_listening_mode_groups[_language];

    static const List<String> l_app_control_audio_control = [
        /*en*/ "Audio control",
        /*ru*/ "Контроль звука",
        /*de*/ "Audiosteuerung",
        /*fr*/ "Réglages Audio",
        /*pl*/ "Sterowanie dźwiękiem"];
    static String get app_control_audio_control => l_app_control_audio_control[_language];

    static const List<String> l_app_control_track_file_info = [
        /*en*/ "File information",
        /*ru*/ "Описание файла",
        /*de*/ "Dateiinformationen",
        /*fr*/ "Informations sur le fichier",
        /*pl*/ "Informacje o pliku"];
    static String get app_control_track_file_info => l_app_control_track_file_info[_language];

    static const List<String> l_app_control_track_cover = [
        /*en*/ "Album cover",
        /*ru*/ "Картинка альбома",
        /*de*/ "Album-Cover",
        /*fr*/ "Couverture de l\'album",
        /*pl*/ "Okładka albumu"];
    static String get app_control_track_cover => l_app_control_track_cover[_language];

    static const List<String> l_app_control_track_time = [
        /*en*/ "Time control",
        /*ru*/ "Контроль времени",
        /*de*/ "Zeitsteuerung",
        /*fr*/ "Contrôle du temps",
        /*pl*/ "Kontrola czasu"];
    static String get app_control_track_time => l_app_control_track_time[_language];

    static const List<String> l_app_control_track_caption = [
        /*en*/ "Song description",
        /*ru*/ "Описание трека",
        /*de*/ "Songbeschreibung",
        /*fr*/ "Description de la chanson",
        /*pl*/ "Opis piosenki"];
    static String get app_control_track_caption => l_app_control_track_caption[_language];

    static const List<String> l_app_control_play_control = [
        /*en*/ "Playback controls",
        /*ru*/ "Контроль воспроизведения",
        /*de*/ "Wiedergabesteuerung",
        /*fr*/ "Commandes de lecture",
        /*pl*/ "Sterowanie odtwarzaniem"];
    static String get app_control_play_control => l_app_control_play_control[_language];

    static const List<String> l_app_control_shortcuts = [
        /*en*/ "Shortcuts list",
        /*ru*/ "Список ярлыков",
        /*de*/ "Favoritenliste",
        /*fr*/ "Liste des raccourcis",
        /*pl*/ "Lista skrótów"];
    static String get app_control_shortcuts => l_app_control_shortcuts[_language];

    static const List<String> l_app_control_input_selector = [
        /*en*/ "Input selector",
        /*ru*/ "Выбор канала",
        /*de*/ "Eingangswahlschalter",
        /*fr*/ "Sélecteur d\'entrée",
        /*pl*/ "Selektor wejść"];
    static String get app_control_input_selector => l_app_control_input_selector[_language];

    static const List<String> l_app_control_media_list = [
        /*en*/ "Media list",
        /*ru*/ "Список треков",
        /*de*/ "Medienliste",
        /*fr*/ "Liste des médias",
        /*pl*/ "Lista mediów"];
    static String get app_control_media_list => l_app_control_media_list[_language];

    static const List<String> l_app_control_setup_op_cmd = [
        /*en*/ "Setup buttons",
        /*ru*/ "Кнопки настройки",
        /*de*/ "Setup-Tasten",
        /*fr*/ "Boutons de configuration",
        /*pl*/ "Przyciski konfiguracji"];
    static String get app_control_setup_op_cmd => l_app_control_setup_op_cmd[_language];

    static const List<String> l_app_control_setup_nav_cmd = [
        /*en*/ "Navigation buttons",
        /*ru*/ "Кнопки курсора",
        /*de*/ "Navigationstasten",
        /*fr*/ "Boutons de navigation",
        /*pl*/ "Przyciski nawigacyjne"];
    static String get app_control_setup_nav_cmd => l_app_control_setup_nav_cmd[_language];

    static const List<String> l_app_control_device_info = [
        /*en*/ "Device information",
        /*ru*/ "Информация об устройстве",
        /*de*/ "Geräteinformation",
        /*fr*/ "Informations sur l\'appareil",
        /*pl*/ "Informacje o urządzeniu"];
    static String get app_control_device_info => l_app_control_device_info[_language];

    static const List<String> l_app_control_device_settings = [
        /*en*/ "Device settings",
        /*ru*/ "Настройки устройства",
        /*de*/ "Geräteeinstellungen",
        /*fr*/ "Réglages de l\'appareil",
        /*pl*/ "Ustawienia urządzenia"];
    static String get app_control_device_settings => l_app_control_device_settings[_language];

    static const List<String> l_app_control_ri_amplifier = [
        /*en*/ "Amplifier (RI)",
        /*ru*/ "Усилитель (RI)",
        /*de*/ "Verstärker (RI)",
        /*fr*/ "Amplificateur (RI)",
        /*pl*/ "Wzmacniacz (RI)"];
    static String get app_control_ri_amplifier => l_app_control_ri_amplifier[_language];

    static const List<String> l_app_control_ri_cd_player = [
        /*en*/ "CD Player (RI)",
        /*ru*/ "CD-проигрыватель (RI)",
        /*de*/ "CD Player (RI)",
        /*fr*/ "CD Player (RI)",
        /*pl*/ "CD Player (RI)"];
    static String get app_control_ri_cd_player => l_app_control_ri_cd_player[_language];

    static const List<String> l_app_control_ri_md_player = [
        /*en*/ "MD Player (RI)",
        /*ru*/ "MD-проигрыватель (RI)",
        /*de*/ "MD Player (RI)",
        /*fr*/ "MD Player (RI)",
        /*pl*/ "MD Player (RI)"];
    static String get app_control_ri_md_player => l_app_control_ri_md_player[_language];

    static const List<String> l_app_control_ri_tape_deck = [
        /*en*/ "Tape Deck (RI)",
        /*ru*/ "Магнитофон (RI)",
        /*de*/ "Tape Deck (RI)",
        /*fr*/ "Tape Deck (RI)",
        /*pl*/ "Tape Deck (RI)"];
    static String get app_control_ri_tape_deck => l_app_control_ri_tape_deck[_language];

    static const List<String> l_tv_display_mode = [
        /*en*/ "Display mode on device",
        /*ru*/ "Режим отображения на дисплее устройства",
        /*de*/ "Anzeigemodus am Gerät",
        /*fr*/ "Mode affichage sur le dispositif",
        /*pl*/ "Tryb wyświetlania na urządzeniu"];
    static String get tv_display_mode => l_tv_display_mode[_language];

    static const List<String> l_amp_cmd_volume_up = [
        /*en*/ "Volume level up",
        /*ru*/ "Увеличить громкость усилителя",
        /*de*/ "Lauter",
        /*fr*/ "Niveau volume haut",
        /*pl*/ "Poziom głośności w górę"];
    static String get amp_cmd_volume_up => l_amp_cmd_volume_up[_language];

    static const List<String> l_amp_cmd_volume_down = [
        /*en*/ "Volume level down",
        /*ru*/ "Понизить громкость усилителя",
        /*de*/ "Leiser",
        /*fr*/ "Niveau volume bas",
        /*pl*/ "Poziom głośności w dół"];
    static String get amp_cmd_volume_down => l_amp_cmd_volume_down[_language];

    static const List<String> l_amp_cmd_selector_up = [
        /*en*/ "Selector position wrap-around up",
        /*ru*/ "Выбрать следующий входной канал",
        /*de*/ "Auswahl weiter",
        /*fr*/ "Molette de sélection haut",
        /*pl*/ "Głośniej"];
    static String get amp_cmd_selector_up => l_amp_cmd_selector_up[_language];

    static const List<String> l_amp_cmd_selector_down = [
        /*en*/ "Selector position wrap-around down",
        /*ru*/ "Выбрать предыдущий входной канал",
        /*de*/ "Auswahl zurück",
        /*fr*/ "Molette de sélection bas",
        /*pl*/ "Ciszej"];
    static String get amp_cmd_selector_down => l_amp_cmd_selector_down[_language];

    static const List<String> l_amp_cmd_audio_muting_off = [
        /*en*/ "Amplifier audio muting off",
        /*ru*/ "Выключить звук усилителя",
        /*de*/ "Verstärker Ton einschalten",
        /*fr*/ "Silence désactivé",
        /*pl*/ "Wyciszenie dźwięku wzmacniacza wyłączone"];
    static String get amp_cmd_audio_muting_off => l_amp_cmd_audio_muting_off[_language];

    static const List<String> l_amp_cmd_audio_muting_on = [
        /*en*/ "Amplifier audio muting on",
        /*ru*/ "Включить звук усилителя",
        /*de*/ "Verstärker stummschalten",
        /*fr*/ "Silence activé",
        /*pl*/ "Wyciszenie dźwięku wzmacniacza włączone"];
    static String get amp_cmd_audio_muting_on => l_amp_cmd_audio_muting_on[_language];

    static const List<String> l_amp_cmd_audio_muting_toggle = [
        /*en*/ "Sets amplifier audio muting wrap-around",
        /*ru*/ "Вкл/выкл звука усилителя",
        /*de*/ "Verstärker Stummschaltung wechseln",
        /*fr*/ "Interrupteur mode silence",
        /*pl*/ "Wyciszenie"];
    static String get amp_cmd_audio_muting_toggle => l_amp_cmd_audio_muting_toggle[_language];

    static const List<String> l_amp_cmd_system_on = [
        /*en*/ "Amplifier on",
        /*ru*/ "Усилитель включен",
        /*de*/ "RI Gerät anschalten",
        /*fr*/ "Ampli Marche",
        /*pl*/ "Wzmacniacz On"];
    static String get amp_cmd_system_on => l_amp_cmd_system_on[_language];

    static const List<String> l_amp_cmd_system_standby = [
        /*en*/ "Amplifier standby",
        /*ru*/ "Усилитель выключен",
        /*de*/ "RI Gerät standby",
        /*fr*/ "Ampli Arrêt",
        /*pl*/ "Wzmacniacz standby"];
    static String get amp_cmd_system_standby => l_amp_cmd_system_standby[_language];

    static const List<String> l_amp_cmd_system_on_toggle = [
        /*en*/ "Amplifier on/standby toggle",
        /*ru*/ "Усилитель вкл/выкл",
        /*de*/ "RI Gerät an/aus wechseln",
        /*fr*/ "Ampli marche/arrêt",
        /*pl*/ "Przełącznik wzmacniacza On/Standby "];
    static String get amp_cmd_system_on_toggle => l_amp_cmd_system_on_toggle[_language];

    static const List<String> l_cd_cmd_power = [
        /*en*/ "CD player on/standby toggle",
        /*ru*/ "CD-проигрыватель вкл/выкл",
        /*de*/ "CD Spieler an/standby",
        /*fr*/ "CD player marche/arrêt",
        /*pl*/ "Przełącznik CD player On/Standby "];
    static String get cd_cmd_power => l_cd_cmd_power[_language];

    static const List<String> l_cd_cmd_track = [
        /*en*/ "Next track",
        /*ru*/ "Следующий трек",
        /*de*/ "Nächster Titel",
        /*fr*/ "Morceau suivant",
        /*pl*/ "Następny utwór"];
    static String get cd_cmd_track => l_cd_cmd_track[_language];

    static const List<String> l_cd_cmd_play = [
        /*en*/ "Play",
        /*ru*/ "Воспроизведение",
        /*de*/ "Wiedergabe",
        /*fr*/ "Lecture",
        /*pl*/ "Play"];
    static String get cd_cmd_play => l_cd_cmd_play[_language];

    static const List<String> l_cd_cmd_stop = [
        /*en*/ "Stop",
        /*ru*/ "Стоп",
        /*de*/ "Stopp",
        /*fr*/ "Stop",
        /*pl*/ "Stop"];
    static String get cd_cmd_stop => l_cd_cmd_stop[_language];

    static const List<String> l_cd_cmd_pause = [
        /*en*/ "Pause",
        /*ru*/ "Пауза",
        /*de*/ "Pause",
        /*fr*/ "Pause",
        /*pl*/ "Pause"];
    static String get cd_cmd_pause => l_cd_cmd_pause[_language];

    static const List<String> l_cd_cmd_skip_f = [
        /*en*/ "Skip forward",
        /*ru*/ "Пропуск трека вперед",
        /*de*/ "Vorwärts springen",
        /*fr*/ "Avance rapide",
        /*pl*/ "Do przodu"];
    static String get cd_cmd_skip_f => l_cd_cmd_skip_f[_language];

    static const List<String> l_cd_cmd_skip_r = [
        /*en*/ "Skip backwards",
        /*ru*/ "Пропуск трека назад",
        /*de*/ "Zurück springen",
        /*fr*/ "Retour rapide",
        /*pl*/ "Do tyłu"];
    static String get cd_cmd_skip_r => l_cd_cmd_skip_r[_language];

    static const List<String> l_cd_cmd_memory = [
        /*en*/ "Memory",
        /*ru*/ "Память",
        /*de*/ "Speicher",
        /*fr*/ "Mémoire",
        /*pl*/ "Pamięć"];
    static String get cd_cmd_memory => l_cd_cmd_memory[_language];

    static const List<String> l_cd_cmd_clear = [
        /*en*/ "Clear",
        /*ru*/ "Очистка",
        /*de*/ "Leeren",
        /*fr*/ "Effacer",
        /*pl*/ "Usuń"];
    static String get cd_cmd_clear => l_cd_cmd_clear[_language];

    static const List<String> l_cd_cmd_repeat = [
        /*en*/ "Repeat",
        /*ru*/ "Повтор",
        /*de*/ "Wiederholen",
        /*fr*/ "Répéter",
        /*pl*/ "Powtórz"];
    static String get cd_cmd_repeat => l_cd_cmd_repeat[_language];

    static const List<String> l_cd_cmd_random = [
        /*en*/ "Random",
        /*ru*/ "Случайно",
        /*de*/ "Zufall",
        /*fr*/ "Aléatoire",
        /*pl*/ "Losowo"];
    static String get cd_cmd_random => l_cd_cmd_random[_language];

    static const List<String> l_cd_cmd_disp = [
        /*en*/ "Display",
        /*ru*/ "Режим отображения на дисплее",
        /*de*/ "Anzeige",
        /*fr*/ "Affichage",
        /*pl*/ "Wyświetl"];
    static String get cd_cmd_disp => l_cd_cmd_disp[_language];

    static const List<String> l_cd_cmd_d_mode = [
        /*en*/ "Disk mode",
        /*ru*/ "Режим диска",
        /*de*/ "Disk Modus",
        /*fr*/ "Mode",
        /*pl*/ "Tryb"];
    static String get cd_cmd_d_mode => l_cd_cmd_d_mode[_language];

    static const List<String> l_cd_cmd_ff = [
        /*en*/ "FF key",
        /*ru*/ "Перемотка вперед",
        /*de*/ "FF Taste",
        /*fr*/ "Touche FF",
        /*pl*/ "Przycisk FF"];
    static String get cd_cmd_ff => l_cd_cmd_ff[_language];

    static const List<String> l_cd_cmd_rew = [
        /*en*/ "REW key",
        /*ru*/ "Перемотка назад",
        /*de*/ "REW Taste",
        /*fr*/ "Touche REW",
        /*pl*/ "Przycisk REW"];
    static String get cd_cmd_rew => l_cd_cmd_rew[_language];

    static const List<String> l_cd_cmd_op_cl = [
        /*en*/ "Open/Close",
        /*ru*/ "Открыть/закрыть",
        /*de*/ "Öffnen/schließen",
        /*fr*/ "Ouvrir/Fermer",
        /*pl*/ "Wysuń/Zamknij"];
    static String get cd_cmd_op_cl => l_cd_cmd_op_cl[_language];

    static const List<String> l_cd_cmd_number_1 = [
        /*en*/ "Number 1",
        /*ru*/ "Номер 1",
        /*de*/ "Nummer 1",
        /*fr*/ "Num 1",
        /*pl*/ "Numer 1"];
    static String get cd_cmd_number_1 => l_cd_cmd_number_1[_language];

    static const List<String> l_cd_cmd_number_2 = [
        /*en*/ "Number 2",
        /*ru*/ "Номер 2",
        /*de*/ "Nummer 2",
        /*fr*/ "Num 2",
        /*pl*/ "Numer 2"];
    static String get cd_cmd_number_2 => l_cd_cmd_number_2[_language];

    static const List<String> l_cd_cmd_number_3 = [
        /*en*/ "Number 3",
        /*ru*/ "Номер 3",
        /*de*/ "Nummer 3",
        /*fr*/ "Num 3",
        /*pl*/ "Numer 3"];
    static String get cd_cmd_number_3 => l_cd_cmd_number_3[_language];

    static const List<String> l_cd_cmd_number_4 = [
        /*en*/ "Number 4",
        /*ru*/ "Номер 4",
        /*de*/ "Nummer 4",
        /*fr*/ "Num 4",
        /*pl*/ "Numer 4"];
    static String get cd_cmd_number_4 => l_cd_cmd_number_4[_language];

    static const List<String> l_cd_cmd_number_5 = [
        /*en*/ "Number 5",
        /*ru*/ "Номер 5",
        /*de*/ "Nummer 5",
        /*fr*/ "Num 5",
        /*pl*/ "Numer 5"];
    static String get cd_cmd_number_5 => l_cd_cmd_number_5[_language];

    static const List<String> l_cd_cmd_number_6 = [
        /*en*/ "Number 6",
        /*ru*/ "Номер 6",
        /*de*/ "Nummer 6",
        /*fr*/ "Num 6",
        /*pl*/ "Numer 6"];
    static String get cd_cmd_number_6 => l_cd_cmd_number_6[_language];

    static const List<String> l_cd_cmd_number_7 = [
        /*en*/ "Number 7",
        /*ru*/ "Номер 7",
        /*de*/ "Nummer 7",
        /*fr*/ "Num 7",
        /*pl*/ "Numer 7"];
    static String get cd_cmd_number_7 => l_cd_cmd_number_7[_language];

    static const List<String> l_cd_cmd_number_8 = [
        /*en*/ "Number 8",
        /*ru*/ "Номер 8",
        /*de*/ "Nummer 8",
        /*fr*/ "Num 8",
        /*pl*/ "Numer 8"];
    static String get cd_cmd_number_8 => l_cd_cmd_number_8[_language];

    static const List<String> l_cd_cmd_number_9 = [
        /*en*/ "Number 9",
        /*ru*/ "Номер 9",
        /*de*/ "Nummer 9",
        /*fr*/ "Num 9",
        /*pl*/ "Numer 9"];
    static String get cd_cmd_number_9 => l_cd_cmd_number_9[_language];

    static const List<String> l_cd_cmd_number_0 = [
        /*en*/ "Number 0",
        /*ru*/ "Номер 0",
        /*de*/ "Nummer 0",
        /*fr*/ "Num 0",
        /*pl*/ "Numer 0"];
    static String get cd_cmd_number_0 => l_cd_cmd_number_0[_language];

    static const List<String> l_cd_cmd_number_10 = [
        /*en*/ "Number 10",
        /*ru*/ "Номер 10",
        /*de*/ "Nummer 10",
        /*fr*/ "Num 10",
        /*pl*/ "Numer 10"];
    static String get cd_cmd_number_10 => l_cd_cmd_number_10[_language];

    static const List<String> l_cd_cmd_number_greater_10 = [
        /*en*/ "Number greater 10",
        /*ru*/ "Номер больше 10",
        /*de*/ "Nummer größer 10",
        /*fr*/ "Num supp. à 10",
        /*pl*/ "Powyżej 10"];
    static String get cd_cmd_number_greater_10 => l_cd_cmd_number_greater_10[_language];

    static const List<String> l_cd_cmd_disc_f = [
        /*en*/ "Next Disk",
        /*ru*/ "Следующий диск",
        /*de*/ "Nächste Disk",
        /*fr*/ "Disque suivant",
        /*pl*/ "Następny dysk"];
    static String get cd_cmd_disc_f => l_cd_cmd_disc_f[_language];

    static const List<String> l_cd_cmd_disc_r = [
        /*en*/ "Previous disk",
        /*ru*/ "Предыдущий диск",
        /*de*/ "Vorherige Disk",
        /*fr*/ "Disque précédent",
        /*pl*/ "Poprzedni dysk"];
    static String get cd_cmd_disc_r => l_cd_cmd_disc_r[_language];

    static const List<String> l_cd_cmd_disc1 = [
        /*en*/ "Disk 1",
        /*ru*/ "Диск 1",
        /*de*/ "Disk 1",
        /*fr*/ "Disque 1",
        /*pl*/ "Dysk 1"];
    static String get cd_cmd_disc1 => l_cd_cmd_disc1[_language];

    static const List<String> l_cd_cmd_disc2 = [
        /*en*/ "Disk 2",
        /*ru*/ "Диск 2",
        /*de*/ "Disk 2",
        /*fr*/ "Disque 2",
        /*pl*/ "Dysk 2"];
    static String get cd_cmd_disc2 => l_cd_cmd_disc2[_language];

    static const List<String> l_cd_cmd_disc3 = [
        /*en*/ "Disk 3",
        /*ru*/ "Диск 3",
        /*de*/ "Disk 3",
        /*fr*/ "Disque 3",
        /*pl*/ "Dysk 3"];
    static String get cd_cmd_disc3 => l_cd_cmd_disc3[_language];

    static const List<String> l_cd_cmd_disc4 = [
        /*en*/ "Disk 4",
        /*ru*/ "Диск 4",
        /*de*/ "Disk 4",
        /*fr*/ "Disque 4",
        /*pl*/ "Dysk 4"];
    static String get cd_cmd_disc4 => l_cd_cmd_disc4[_language];

    static const List<String> l_cd_cmd_disc5 = [
        /*en*/ "Disk 5",
        /*ru*/ "Диск 5",
        /*de*/ "Disk 5",
        /*fr*/ "Disque 5",
        /*pl*/ "Dysk 5"];
    static String get cd_cmd_disc5 => l_cd_cmd_disc5[_language];

    static const List<String> l_cd_cmd_disc6 = [
        /*en*/ "Disk 6",
        /*ru*/ "Диск 6",
        /*de*/ "Disk 6",
        /*fr*/ "Disque 6",
        /*pl*/ "Dysk 6"];
    static String get cd_cmd_disc6 => l_cd_cmd_disc6[_language];

    static const List<String> l_tape_cmd_play_ff = [
        /*en*/ "Play forward",
        /*ru*/ "Воспроизведение вперед",
        /*de*/ "Wiedergabe vorwärts",
        /*fr*/ "Play forward",
        /*pl*/ "Play forward"];
    static String get tape_cmd_play_ff => l_tape_cmd_play_ff[_language];

    static const List<String> l_tape_cmd_play_rew = [
        /*en*/ "Play backwards",
        /*ru*/ "Воспроизведение назад",
        /*de*/ "Wiedergabe rückwärts",
        /*fr*/ "Play backwards",
        /*pl*/ "Play backwards"];
    static String get tape_cmd_play_rew => l_tape_cmd_play_rew[_language];

    static const List<String> l_tape_cmd_stop = [
        /*en*/ "Stop",
        /*ru*/ "Стоп",
        /*de*/ "Stopp",
        /*fr*/ "Stop",
        /*pl*/ "Stop"];
    static String get tape_cmd_stop => l_tape_cmd_stop[_language];

    static const List<String> l_tape_cmd_record = [
        /*en*/ "Record/Pause",
        /*ru*/ "Запись/Пауза",
        /*de*/ "Aufnahme/Pause",
        /*fr*/ "Record/Pause",
        /*pl*/ "Record/Pause"];
    static String get tape_cmd_record => l_tape_cmd_record[_language];

    static const List<String> l_tape_cmd_ff = [
        /*en*/ "Skip forward",
        /*ru*/ "Перемотка вперед",
        /*de*/ "Vorwärts springen",
        /*fr*/ "Skip forward",
        /*pl*/ "Skip forward"];
    static String get tape_cmd_ff => l_tape_cmd_ff[_language];

    static const List<String> l_tape_cmd_rew = [
        /*en*/ "Skip backwards",
        /*ru*/ "Перемотка назад",
        /*de*/ "Zurück springen",
        /*fr*/ "Skip backwards",
        /*pl*/ "Skip backwards"];
    static String get tape_cmd_rew => l_tape_cmd_rew[_language];

    static const List<String> l_audio_muting_none = [
        /*en*/ "N/A",
        /*ru*/ "Нет",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get audio_muting_none => l_audio_muting_none[_language];

    static const List<String> l_audio_muting_off = [
        /*en*/ "Player audio muting off",
        /*ru*/ "Выключить звук устройства",
        /*de*/ "Ton Stumm aus",
        /*fr*/ "Audio silence désactivé",
        /*pl*/ "Wyciszenie off"];
    static String get audio_muting_off => l_audio_muting_off[_language];

    static const List<String> l_audio_muting_on = [
        /*en*/ "Player audio muting on",
        /*ru*/ "Включить звук устройства",
        /*de*/ "Ton Stumm an",
        /*fr*/ "Audio silence activé",
        /*pl*/ "Wyciszenie on"];
    static String get audio_muting_on => l_audio_muting_on[_language];

    static const List<String> l_audio_muting_toggle = [
        /*en*/ "Sets player audio muting wrap-around",
        /*ru*/ "Вкл/выкл звука устройства",
        /*de*/ "Stummschaltung wechseln",
        /*fr*/ "Interrupteur silence audio",
        /*pl*/ "Sets player audio muting wrap-around"];
    static String get audio_muting_toggle => l_audio_muting_toggle[_language];

    static const List<String> l_tone_bass = [
        /*en*/ "Bass",
        /*ru*/ "Тембр НЧ",
        /*de*/ "Bass",
        /*fr*/ "Basses",
        /*pl*/ "Bass"];
    static String get tone_bass => l_tone_bass[_language];

    static const List<String> l_tone_treble = [
        /*en*/ "Treble",
        /*ru*/ "Тембр ВЧ",
        /*de*/ "Höhen",
        /*fr*/ "Aigües",
        /*pl*/ "Treble"];
    static String get tone_treble => l_tone_treble[_language];

    static const List<String> l_subwoofer_level = [
        /*en*/ "Subwoofer level",
        /*ru*/ "Уровень сабвуфера",
        /*de*/ "Subwoofer-Pegel",
        /*fr*/ "Niveau Subwoofer",
        /*pl*/ "Subwoofer level"];
    static String get subwoofer_level => l_subwoofer_level[_language];

    static const List<String> l_center_level = [
        /*en*/ "Center level",
        /*ru*/ "Уровень центра",
        /*de*/ "Center-Lautstärke",
        /*fr*/ "Niveau Centre",
        /*pl*/ "Center level"];
    static String get center_level => l_center_level[_language];

    static const List<String> l_master_volume = [
        /*en*/ "Master volume",
        /*ru*/ "Громкость",
        /*de*/ "Haupt-Lautstärke",
        /*fr*/ "Volume principal",
        /*pl*/ "Master volume"];
    static String get master_volume => l_master_volume[_language];

    static const List<String> l_master_volume_up = [
        /*en*/ "Sets volume level up",
        /*ru*/ "Увеличить громкость",
        /*de*/ "Lauter",
        /*fr*/ "Niveau volume haut",
        /*pl*/ "Głośność poziom wyżej"];
    static String get master_volume_up => l_master_volume_up[_language];

    static const List<String> l_master_volume_down = [
        /*en*/ "Sets volume level down",
        /*ru*/ "Понизить громкость",
        /*de*/ "Leiser",
        /*fr*/ "Niveau volume bas",
        /*pl*/ "Głośność poziom  niżej"];
    static String get master_volume_down => l_master_volume_down[_language];

    static const List<String> l_master_volume_up1 = [
        /*en*/ "Sets volume level up 1dB step",
        /*ru*/ "Повысить громкость на 1dB",
        /*de*/ "1dB lauter",
        /*fr*/ "Augmentation volume d\'1dB",
        /*pl*/ "Głośniej o 1dB"];
    static String get master_volume_up1 => l_master_volume_up1[_language];

    static const List<String> l_master_volume_down1 = [
        /*en*/ "Sets volume level down 1dB step",
        /*ru*/ "Понизить громкость на 1dB",
        /*de*/ "1dB leiser",
        /*fr*/ "Diminution volume d\'1dB",
        /*pl*/ "Ciszej o 1dB"];
    static String get master_volume_down1 => l_master_volume_down1[_language];

    static const List<String> l_tone_direct = [
        /*en*/ "Tone Direct",
        /*ru*/ "DIRECT",
        /*de*/ "Ton Direct",
        /*fr*/ "DIRECT",
        /*pl*/ "Tone Direct"];
    static String get tone_direct => l_tone_direct[_language];

    static const List<String> l_master_volume_restrict = [
        /*en*/ "Restrict volume level",
        /*ru*/ "Ограничить максимальную громкость",
        /*de*/ "Lautstärke einschränken",
        /*fr*/ "Restreindre le volume",
        /*pl*/ "Ogranicz poziom głośności"];
    static String get master_volume_restrict => l_master_volume_restrict[_language];

    static const List<String> l_master_volume_max = [
        /*en*/ "Maximum",
        /*ru*/ "Максимум",
        /*de*/ "Maximum",
        /*fr*/ "Maximum",
        /*pl*/ "Maksymalny"];
    static String get master_volume_max => l_master_volume_max[_language];

    static const List<String> l_equalizer = [
        /*en*/ "Equalizer",
        /*ru*/ "Эквалайзер",
        /*de*/ "Equalizer",
        /*fr*/ "Equalizer",
        /*pl*/ "Equalizer"];
    static String get equalizer => l_equalizer[_language];

    static const List<String> l_audio_balance = [
        /*en*/ "Balance",
        /*ru*/ "Баланс",
        /*de*/ "Balance",
        /*fr*/ "Balance",
        /*pl*/ "Balance"];
    static String get audio_balance => l_audio_balance[_language];

    static const List<String> l_preset_command_up = [
        /*en*/ "Sets preset wrap-around up",
        /*ru*/ "Следующий канал",
        /*de*/ "Nächster gespeicherter Sender",
        /*fr*/ "Présélection haut",
        /*pl*/ "Zapamiętane \"+\""];
    static String get preset_command_up => l_preset_command_up[_language];

    static const List<String> l_preset_command_down = [
        /*en*/ "Sets preset wrap-around down",
        /*ru*/ "Предыдущий канал",
        /*de*/ "Vorheriger gespeicherter Sender",
        /*fr*/ "Présélection bas",
        /*pl*/ "Zapamiętane \"-\""];
    static String get preset_command_down => l_preset_command_down[_language];

    static const List<String> l_cmd_preset_memory = [
        /*en*/ "Preset memory",
        /*ru*/ "Сохранить канал",
        /*de*/ "Sender speichern",
        /*fr*/ "Enregistrer la station",
        /*pl*/ "Zapisz stację"];
    static String get cmd_preset_memory => l_cmd_preset_memory[_language];

    static const List<String> l_cmd_preset_memory_number = [
        /*en*/ "Preset",
        /*ru*/ "Номер канала",
        /*de*/ "Speichernummer",
        /*fr*/ "Présélection",
        /*pl*/ "Zapamiętane"];
    static String get cmd_preset_memory_number => l_cmd_preset_memory_number[_language];

    static const List<String> l_number_picker_decrease = [
        /*en*/ "Decrease value",
        /*ru*/ "Уменьшить значение",
        /*de*/ "Wert verringern",
        /*fr*/ "Diminuer la valeur",
        /*pl*/ "Zmniejsz wartość"];
    static String get number_picker_decrease => l_number_picker_decrease[_language];

    static const List<String> l_number_picker_increase = [
        /*en*/ "Increase value",
        /*ru*/ "Увеличить значение",
        /*de*/ "Wert erhöhen",
        /*fr*/ "Augmenter la valeur",
        /*pl*/ "Zwiększ wartość"];
    static String get number_picker_increase => l_number_picker_increase[_language];

    static const List<String> l_tuning_command_up = [
        /*en*/ "Sets tuning frequency wrap-around up",
        /*ru*/ "Повысить частоту приема",
        /*de*/ "Nächsten Sender suchen",
        /*fr*/ "Changement fréquence haut",
        /*pl*/ "Strojenie \"+\""];
    static String get tuning_command_up => l_tuning_command_up[_language];

    static const List<String> l_tuning_command_down = [
        /*en*/ "Sets tuning frequency wrap-around down",
        /*ru*/ "Понизить частоту приема",
        /*de*/ "Vorherigen Sender suchen",
        /*fr*/ "Changement fréquence bas",
        /*pl*/ "Strojenie \"-\""];
    static String get tuning_command_down => l_tuning_command_down[_language];

    static const List<String> l_cmd_description_play = [
        /*en*/ "Play",
        /*ru*/ "Воспроизведение",
        /*de*/ "Abspielen",
        /*fr*/ "Lecture",
        /*pl*/ "Play"];
    static String get cmd_description_play => l_cmd_description_play[_language];

    static const List<String> l_cmd_description_stop = [
        /*en*/ "Stop",
        /*ru*/ "Стоп",
        /*de*/ "Stopp",
        /*fr*/ "Stop",
        /*pl*/ "Stop"];
    static String get cmd_description_stop => l_cmd_description_stop[_language];

    static const List<String> l_cmd_description_pause = [
        /*en*/ "Pause",
        /*ru*/ "Пауза",
        /*de*/ "Pause",
        /*fr*/ "Pause",
        /*pl*/ "Pause"];
    static String get cmd_description_pause => l_cmd_description_pause[_language];

    static const List<String> l_cmd_description_p_p = [
        /*en*/ "Play/Pause",
        /*ru*/ "Воспроизведение/Пауза",
        /*de*/ "Abspielen/Pause",
        /*fr*/ "Lecture/Pause",
        /*pl*/ "Play/Pause"];
    static String get cmd_description_p_p => l_cmd_description_p_p[_language];

    static const List<String> l_cmd_description_trup = [
        /*en*/ "Track Up",
        /*ru*/ "Следующий трек",
        /*de*/ "nächster Titel",
        /*fr*/ "Piste haut",
        /*pl*/ "Kolejna"];
    static String get cmd_description_trup => l_cmd_description_trup[_language];

    static const List<String> l_cmd_description_trdn = [
        /*en*/ "Track Down",
        /*ru*/ "Предыдущий трек",
        /*de*/ "vorheriger Titel",
        /*fr*/ "Piste bas",
        /*pl*/ "Poprzednia"];
    static String get cmd_description_trdn => l_cmd_description_trdn[_language];

    static const List<String> l_cmd_description_ff = [
        /*en*/ "FF Key(Continuous)",
        /*ru*/ "Перемотка вперед",
        /*de*/ "FF Taste(fortlaufend)",
        /*fr*/ "Avancer (maintenir)",
        /*pl*/ "FF (przewiń)"];
    static String get cmd_description_ff => l_cmd_description_ff[_language];

    static const List<String> l_cmd_description_rew = [
        /*en*/ "REW Key(Continuous)",
        /*ru*/ "Перемотка назад",
        /*de*/ "REW Taste(fortlaufend)",
        /*fr*/ "Reculer (maintenir)",
        /*pl*/ "REW (przewiń)"];
    static String get cmd_description_rew => l_cmd_description_rew[_language];

    static const List<String> l_cmd_description_repeat = [
        /*en*/ "Repeat",
        /*ru*/ "Повтор",
        /*de*/ "Wiederholen",
        /*fr*/ "Répétition",
        /*pl*/ "Powtórz"];
    static String get cmd_description_repeat => l_cmd_description_repeat[_language];

    static const List<String> l_cmd_description_random = [
        /*en*/ "Random",
        /*ru*/ "Случайно",
        /*de*/ "Zufall",
        /*fr*/ "Aléatoire",
        /*pl*/ "Losowo"];
    static String get cmd_description_random => l_cmd_description_random[_language];

    static const List<String> l_cmd_description_rep_shf = [
        /*en*/ "Repeat/Shuffle",
        /*ru*/ "Повтор/случайно",
        /*de*/ "Wiederholen/Zufall",
        /*fr*/ "Répétition/Aléatoire",
        /*pl*/ "Powtórz/Losowo"];
    static String get cmd_description_rep_shf => l_cmd_description_rep_shf[_language];

    static const List<String> l_cmd_description_display = [
        /*en*/ "Display",
        /*ru*/ "Режим отображения на дисплее устройства",
        /*de*/ "Anzeige",
        /*fr*/ "Affichage",
        /*pl*/ "Wyświetl"];
    static String get cmd_description_display => l_cmd_description_display[_language];

    static const List<String> l_cmd_description_album = [
        /*en*/ "Album",
        /*ru*/ "Альбом",
        /*de*/ "Album",
        /*fr*/ "Album",
        /*pl*/ "Album"];
    static String get cmd_description_album => l_cmd_description_album[_language];

    static const List<String> l_cmd_description_artist = [
        /*en*/ "Artist",
        /*ru*/ "Артист",
        /*de*/ "Künstler",
        /*fr*/ "Artiste",
        /*pl*/ "Artysta"];
    static String get cmd_description_artist => l_cmd_description_artist[_language];

    static const List<String> l_cmd_description_genre = [
        /*en*/ "Genre",
        /*ru*/ "Жанр",
        /*de*/ "Genre",
        /*fr*/ "Genre",
        /*pl*/ "Rodzaj"];
    static String get cmd_description_genre => l_cmd_description_genre[_language];

    static const List<String> l_cmd_description_playlist = [
        /*en*/ "Playlist",
        /*ru*/ "Список",
        /*de*/ "Abspielliste",
        /*fr*/ "Playlist",
        /*pl*/ "Lista odtwarzania"];
    static String get cmd_description_playlist => l_cmd_description_playlist[_language];

    static const List<String> l_cmd_description_right = [
        /*en*/ "Right",
        /*ru*/ "Вправо",
        /*de*/ "Nächstes",
        /*fr*/ "Droite",
        /*pl*/ "Prawo"];
    static String get cmd_description_right => l_cmd_description_right[_language];

    static const List<String> l_cmd_description_left = [
        /*en*/ "Left",
        /*ru*/ "Влево",
        /*de*/ "Vorheriges",
        /*fr*/ "Gauche",
        /*pl*/ "Lewo"];
    static String get cmd_description_left => l_cmd_description_left[_language];

    static const List<String> l_cmd_description_up = [
        /*en*/ "Up",
        /*ru*/ "Вверх",
        /*de*/ "Hoch",
        /*fr*/ "Haut",
        /*pl*/ "Góra"];
    static String get cmd_description_up => l_cmd_description_up[_language];

    static const List<String> l_cmd_description_down = [
        /*en*/ "Down",
        /*ru*/ "Вниз",
        /*de*/ "Runter",
        /*fr*/ "Bas",
        /*pl*/ "Dół"];
    static String get cmd_description_down => l_cmd_description_down[_language];

    static const List<String> l_cmd_description_select = [
        /*en*/ "Select",
        /*ru*/ "Выбор",
        /*de*/ "Auswählen",
        /*fr*/ "Sélection",
        /*pl*/ "Wybór"];
    static String get cmd_description_select => l_cmd_description_select[_language];

    static const List<String> l_cmd_description_key_0 = [
        /*en*/ "0",
        /*ru*/ "Номер 0",
        /*de*/ "0",
        /*fr*/ "0",
        /*pl*/ "0"];
    static String get cmd_description_key_0 => l_cmd_description_key_0[_language];

    static const List<String> l_cmd_description_key_1 = [
        /*en*/ "1",
        /*ru*/ "Номер 1",
        /*de*/ "1",
        /*fr*/ "1",
        /*pl*/ "1"];
    static String get cmd_description_key_1 => l_cmd_description_key_1[_language];

    static const List<String> l_cmd_description_key_2 = [
        /*en*/ "2",
        /*ru*/ "Номер 2",
        /*de*/ "2",
        /*fr*/ "2",
        /*pl*/ "2"];
    static String get cmd_description_key_2 => l_cmd_description_key_2[_language];

    static const List<String> l_cmd_description_key_3 = [
        /*en*/ "3",
        /*ru*/ "Номер 3",
        /*de*/ "3",
        /*fr*/ "3",
        /*pl*/ "3"];
    static String get cmd_description_key_3 => l_cmd_description_key_3[_language];

    static const List<String> l_cmd_description_key_4 = [
        /*en*/ "4",
        /*ru*/ "Номер 4",
        /*de*/ "4",
        /*fr*/ "4",
        /*pl*/ "4"];
    static String get cmd_description_key_4 => l_cmd_description_key_4[_language];

    static const List<String> l_cmd_description_key_5 = [
        /*en*/ "5",
        /*ru*/ "Номер 5",
        /*de*/ "5",
        /*fr*/ "5",
        /*pl*/ "5"];
    static String get cmd_description_key_5 => l_cmd_description_key_5[_language];

    static const List<String> l_cmd_description_key_6 = [
        /*en*/ "6",
        /*ru*/ "Номер 6",
        /*de*/ "6",
        /*fr*/ "6",
        /*pl*/ "6"];
    static String get cmd_description_key_6 => l_cmd_description_key_6[_language];

    static const List<String> l_cmd_description_key_7 = [
        /*en*/ "7",
        /*ru*/ "Номер 7",
        /*de*/ "7",
        /*fr*/ "7",
        /*pl*/ "7"];
    static String get cmd_description_key_7 => l_cmd_description_key_7[_language];

    static const List<String> l_cmd_description_key_8 = [
        /*en*/ "8",
        /*ru*/ "Номер 8",
        /*de*/ "8",
        /*fr*/ "8",
        /*pl*/ "8"];
    static String get cmd_description_key_8 => l_cmd_description_key_8[_language];

    static const List<String> l_cmd_description_key_9 = [
        /*en*/ "9",
        /*ru*/ "Номер 9",
        /*de*/ "9",
        /*fr*/ "9",
        /*pl*/ "9"];
    static String get cmd_description_key_9 => l_cmd_description_key_9[_language];

    static const List<String> l_cmd_description_delete = [
        /*en*/ "Delete",
        /*ru*/ "Удалить",
        /*de*/ "Entfernen",
        /*fr*/ "Effacer",
        /*pl*/ "Usuń"];
    static String get cmd_description_delete => l_cmd_description_delete[_language];

    static const List<String> l_cmd_description_caps = [
        /*en*/ "Caps",
        /*ru*/ "Регистр",
        /*de*/ "Großbuchstaben",
        /*fr*/ "Maj",
        /*pl*/ "Caps"];
    static String get cmd_description_caps => l_cmd_description_caps[_language];

    static const List<String> l_cmd_description_location = [
        /*en*/ "Location",
        /*ru*/ "Расположение",
        /*de*/ "Ort",
        /*fr*/ "Lieu",
        /*pl*/ "Lokalizacja"];
    static String get cmd_description_location => l_cmd_description_location[_language];

    static const List<String> l_cmd_description_language = [
        /*en*/ "Language",
        /*ru*/ "Язык",
        /*de*/ "Sprache",
        /*fr*/ "Langue",
        /*pl*/ "Język"];
    static String get cmd_description_language => l_cmd_description_language[_language];

    static const List<String> l_cmd_description_setup = [
        /*en*/ "Setup",
        /*ru*/ "Настройки",
        /*de*/ "Einrichten",
        /*fr*/ "Paramètres",
        /*pl*/ "Ustawienia"];
    static String get cmd_description_setup => l_cmd_description_setup[_language];

    static const List<String> l_cmd_description_return = [
        /*en*/ "Return",
        /*ru*/ "Назад",
        /*de*/ "Zurück",
        /*fr*/ "Retour",
        /*pl*/ "Powrót"];
    static String get cmd_description_return => l_cmd_description_return[_language];

    static const List<String> l_cmd_description_chup = [
        /*en*/ "Ch Up(For Iradio)",
        /*ru*/ "Следующий канал для Iradio",
        /*de*/ "Vorheriger Kanal (Iradio)",
        /*fr*/ "Ch haut(Iradio)",
        /*pl*/ "Zmień kanał na kolejny(Iradio)"];
    static String get cmd_description_chup => l_cmd_description_chup[_language];

    static const List<String> l_cmd_description_chdn = [
        /*en*/ "Ch Down(For Iradio)",
        /*ru*/ "Предыдущий канал для Iradio",
        /*de*/ "Nächster Kanal (Iradio)",
        /*fr*/ "Ch bas(Iradio)",
        /*pl*/ "Zmień kanał na poprzedni(Iradio)"];
    static String get cmd_description_chdn => l_cmd_description_chdn[_language];

    static const List<String> l_cmd_description_menu = [
        /*en*/ "Menu",
        /*ru*/ "Меню",
        /*de*/ "Menü",
        /*fr*/ "Menu",
        /*pl*/ "Menu"];
    static String get cmd_description_menu => l_cmd_description_menu[_language];

    static const List<String> l_cmd_description_home = [
        /*en*/ "Home",
        /*ru*/ "Домой",
        /*de*/ "Home",
        /*fr*/ "Home",
        /*pl*/ "Home"];
    static String get cmd_description_home => l_cmd_description_home[_language];

    static const List<String> l_cmd_description_quick_menu = [
        /*en*/ "Quick menu",
        /*ru*/ "Меню",
        /*de*/ "Schnellmenü",
        /*fr*/ "Menu rapide",
        /*pl*/ "Szybkie Menu"];
    static String get cmd_description_quick_menu => l_cmd_description_quick_menu[_language];

    static const List<String> l_cmd_description_top = [
        /*en*/ "Top Menu",
        /*ru*/ "Наверх",
        /*de*/ "Hauptmenü",
        /*fr*/ "Haut Menu",
        /*pl*/ "Górne Menu"];
    static String get cmd_description_top => l_cmd_description_top[_language];

    static const List<String> l_cmd_description_mode = [
        /*en*/ "Mode(For Ipod)",
        /*ru*/ "Режим Ipod",
        /*de*/ "Modus (Ipod)",
        /*fr*/ "Mode(Pour Ipod)",
        /*pl*/ "Tryb(Dla Ipod)"];
    static String get cmd_description_mode => l_cmd_description_mode[_language];

    static const List<String> l_cmd_description_list = [
        /*en*/ "List/Playback",
        /*ru*/ "Переключение между списком и режимом воспроизведения",
        /*de*/ "Liste/Abspielen",
        /*fr*/ "Liste/Lecture",
        /*pl*/ "Lista/Odtwarzanie"];
    static String get cmd_description_list => l_cmd_description_list[_language];

    static const List<String> l_cmd_description_memory = [
        /*en*/ "Memory(Add Favorite)",
        /*ru*/ "Добавить в избранное",
        /*de*/ "Speichern(Favorit hinzufügen)",
        /*fr*/ "Mémoire (Ajout favoris)",
        /*pl*/ "Pamięć(Dodaj ulubione)"];
    static String get cmd_description_memory => l_cmd_description_memory[_language];

    static const List<String> l_cmd_description_f1 = [
        /*en*/ "Positive Feed Or Mark/Unmark",
        /*ru*/ "Нравится",
        /*de*/ "Positiv markieren/demarkieren",
        /*fr*/ "Positive Feed ou cocher/décocher",
        /*pl*/ "Positive Feed Lub Zaznacz/Odznacz"];
    static String get cmd_description_f1 => l_cmd_description_f1[_language];

    static const List<String> l_cmd_description_f2 = [
        /*en*/ "Negative Feed",
        /*ru*/ "Не нравится",
        /*de*/ "Negativ markieren",
        /*fr*/ "Negative Feed",
        /*pl*/ "Negative Feed"];
    static String get cmd_description_f2 => l_cmd_description_f2[_language];

    static const List<String> l_cmd_description_sort = [
        /*en*/ "Sort",
        /*ru*/ "Сортировать",
        /*de*/ "Sortierung",
        /*fr*/ "Ordre de sélection",
        /*pl*/ "Sortować"];
    static String get cmd_description_sort => l_cmd_description_sort[_language];

    static const List<String> l_cmd_track_menu = [
        /*en*/ "Track menu",
        /*ru*/ "Меню трека",
        /*de*/ "Titel Menü",
        /*fr*/ "Menu des pistes",
        /*pl*/ "Menu utworów"];
    static String get cmd_track_menu => l_cmd_track_menu[_language];

    static const List<String> l_cmd_rds_info = [
        /*en*/ "RDS info",
        /*ru*/ "Информация RDS",
        /*de*/ "RDS Info",
        /*fr*/ "RDS info",
        /*pl*/ "RDS info"];
    static String get cmd_rds_info => l_cmd_rds_info[_language];

    static const List<String> l_medialist_items = [
        /*en*/ "items",
        /*ru*/ "элементов",
        /*de*/ "Elemente",
        /*fr*/ "Éléments",
        /*pl*/ "Lista"];
    static String get medialist_items => l_medialist_items[_language];

    static const List<String> l_medialist_processing = [
        /*en*/ "Processing…",
        /*ru*/ "Ждите…",
        /*de*/ "Bearbeite…",
        /*fr*/ "Traitement…",
        /*pl*/ "Przetwarzanie…"];
    static String get medialist_processing => l_medialist_processing[_language];

    static const List<String> l_medialist_playback_mode = [
        /*en*/ "Playback mode",
        /*ru*/ "Режим воспроизведения",
        /*de*/ "Abspielmodus",
        /*fr*/ "Mode de lecture",
        /*pl*/ "Tryb odtwarzania"];
    static String get medialist_playback_mode => l_medialist_playback_mode[_language];

    static const List<String> l_medialist_no_items = [
        /*en*/ "No items",
        /*ru*/ "Список пуст",
        /*de*/ "Keine Elemente",
        /*fr*/ "Pas d\'éléments",
        /*pl*/ "Brak listy"];
    static String get medialist_no_items => l_medialist_no_items[_language];

    static const List<String> l_medialist_filter = [
        /*en*/ "Filter items",
        /*ru*/ "Фильтровать список",
        /*de*/ "Elemente filtern",
        /*fr*/ "Filtrer les éléments",
        /*pl*/ "Filtruj elementy"];
    static String get medialist_filter => l_medialist_filter[_language];

    static const List<String> l_medialist_search = [
        /*en*/ "Search",
        /*ru*/ "Поиск",
        /*de*/ "Suchen",
        /*fr*/ "Recherche",
        /*pl*/ "Szukaj"];
    static String get medialist_search => l_medialist_search[_language];

    static const List<String> l_medialist_search_artist = [
        /*en*/ "Artist",
        /*ru*/ "Артист",
        /*de*/ "Künstler",
        /*fr*/ "Artiste",
        /*pl*/ "Artysta"];
    static String get medialist_search_artist => l_medialist_search_artist[_language];

    static const List<String> l_medialist_search_album = [
        /*en*/ "Album",
        /*ru*/ "Альбом",
        /*de*/ "Album",
        /*fr*/ "Album",
        /*pl*/ "Album"];
    static String get medialist_search_album => l_medialist_search_album[_language];

    static const List<String> l_medialist_search_track = [
        /*en*/ "Track",
        /*ru*/ "Трек",
        /*de*/ "Track",
        /*fr*/ "Track",
        /*pl*/ "Track"];
    static String get medialist_search_track => l_medialist_search_track[_language];

    static const List<String> l_medialist_search_station = [
        /*en*/ "Station",
        /*ru*/ "Станция",
        /*de*/ "Station",
        /*fr*/ "Station",
        /*pl*/ "Station"];
    static String get medialist_search_station => l_medialist_search_station[_language];

    static const List<String> l_medialist_search_playlist = [
        /*en*/ "Playlist",
        /*ru*/ "Плейлист",
        /*de*/ "Wiedergabeliste",
        /*fr*/ "Playlist",
        /*pl*/ "Playlist"];
    static String get medialist_search_playlist => l_medialist_search_playlist[_language];

    static const List<String> l_input_selector_vcr_dvr = [
        /*en*/ "VCR/DVR",
        /*ru*/ "VCR/DVR",
        /*de*/ "VCR/DVR",
        /*fr*/ "VCR/DVR",
        /*pl*/ "VCR/DVR"];
    static String get input_selector_vcr_dvr => l_input_selector_vcr_dvr[_language];

    static const List<String> l_input_selector_cbl_sat = [
        /*en*/ "CBL/SAT",
        /*ru*/ "CBL/SAT",
        /*de*/ "CBL/SAT",
        /*fr*/ "CBL/SAT",
        /*pl*/ "CBL/SAT"];
    static String get input_selector_cbl_sat => l_input_selector_cbl_sat[_language];

    static const List<String> l_input_selector_game = [
        /*en*/ "GAME",
        /*ru*/ "GAME",
        /*de*/ "GAME",
        /*fr*/ "GAME",
        /*pl*/ "GAME"];
    static String get input_selector_game => l_input_selector_game[_language];

    static const List<String> l_input_selector_game1 = [
        /*en*/ "GAME1",
        /*ru*/ "GAME1",
        /*de*/ "GAME1",
        /*fr*/ "GAME1",
        /*pl*/ "GAME1"];
    static String get input_selector_game1 => l_input_selector_game1[_language];

    static const List<String> l_input_selector_aux = [
        /*en*/ "AUX",
        /*ru*/ "AUX",
        /*de*/ "AUX",
        /*fr*/ "AUX",
        /*pl*/ "AUX"];
    static String get input_selector_aux => l_input_selector_aux[_language];

    static const List<String> l_input_selector_aux1 = [
        /*en*/ "AUX1",
        /*ru*/ "AUX1",
        /*de*/ "AUX1",
        /*fr*/ "AUX1",
        /*pl*/ "AUX1"];
    static String get input_selector_aux1 => l_input_selector_aux1[_language];

    static const List<String> l_input_selector_aux2 = [
        /*en*/ "AUX2",
        /*ru*/ "AUX2",
        /*de*/ "AUX2",
        /*fr*/ "AUX2",
        /*pl*/ "AUX2"];
    static String get input_selector_aux2 => l_input_selector_aux2[_language];

    static const List<String> l_input_selector_aux3 = [
        /*en*/ "AUX3",
        /*ru*/ "AUX3",
        /*de*/ "AUX3",
        /*fr*/ "AUX3",
        /*pl*/ "AUX3"];
    static String get input_selector_aux3 => l_input_selector_aux3[_language];

    static const List<String> l_input_selector_aux4 = [
        /*en*/ "AUX4",
        /*ru*/ "AUX4",
        /*de*/ "AUX4",
        /*fr*/ "AUX4",
        /*pl*/ "AUX4"];
    static String get input_selector_aux4 => l_input_selector_aux4[_language];

    static const List<String> l_input_selector_aux5 = [
        /*en*/ "AUX5",
        /*ru*/ "AUX5",
        /*de*/ "AUX5",
        /*fr*/ "AUX5",
        /*pl*/ "AUX5"];
    static String get input_selector_aux5 => l_input_selector_aux5[_language];

    static const List<String> l_input_selector_aux6 = [
        /*en*/ "AUX6",
        /*ru*/ "AUX6",
        /*de*/ "AUX6",
        /*fr*/ "AUX6",
        /*pl*/ "AUX6"];
    static String get input_selector_aux6 => l_input_selector_aux6[_language];

    static const List<String> l_input_selector_aux7 = [
        /*en*/ "AUX7",
        /*ru*/ "AUX7",
        /*de*/ "AUX7",
        /*fr*/ "AUX7",
        /*pl*/ "AUX7"];
    static String get input_selector_aux7 => l_input_selector_aux7[_language];

    static const List<String> l_input_selector_pc = [
        /*en*/ "PC",
        /*ru*/ "PC",
        /*de*/ "PC",
        /*fr*/ "PC",
        /*pl*/ "PC"];
    static String get input_selector_pc => l_input_selector_pc[_language];

    static const List<String> l_input_selector_video7 = [
        /*en*/ "VIDEO 7",
        /*ru*/ "VIDEO 7",
        /*de*/ "VIDEO 7",
        /*fr*/ "VIDEO 7",
        /*pl*/ "VIDEO 7"];
    static String get input_selector_video7 => l_input_selector_video7[_language];

    static const List<String> l_input_selector_extra1 = [
        /*en*/ "EXTRA 1",
        /*ru*/ "EXTRA 1",
        /*de*/ "EXTRA 1",
        /*fr*/ "EXTRA 1",
        /*pl*/ "EXTRA 1"];
    static String get input_selector_extra1 => l_input_selector_extra1[_language];

    static const List<String> l_input_selector_extra2 = [
        /*en*/ "EXTRA 2",
        /*ru*/ "EXTRA 2",
        /*de*/ "EXTRA 2",
        /*fr*/ "EXTRA 2",
        /*pl*/ "EXTRA 2"];
    static String get input_selector_extra2 => l_input_selector_extra2[_language];

    static const List<String> l_input_selector_bd_dvd = [
        /*en*/ "BD/DVD",
        /*ru*/ "BD/DVD",
        /*de*/ "BD/DVD",
        /*fr*/ "BD/DVD",
        /*pl*/ "BD/DVD"];
    static String get input_selector_bd_dvd => l_input_selector_bd_dvd[_language];

    static const List<String> l_input_selector_strm_box = [
        /*en*/ "STRM BOX",
        /*ru*/ "STRM BOX",
        /*de*/ "STRM BOX",
        /*fr*/ "STRM BOX",
        /*pl*/ "STRM BOX"];
    static String get input_selector_strm_box => l_input_selector_strm_box[_language];

    static const List<String> l_input_selector_tv = [
        /*en*/ "TV",
        /*ru*/ "TV",
        /*de*/ "TV",
        /*fr*/ "TV",
        /*pl*/ "TV"];
    static String get input_selector_tv => l_input_selector_tv[_language];

    static const List<String> l_input_selector_tape1 = [
        /*en*/ "TAPE",
        /*ru*/ "TAPE",
        /*de*/ "TAPE",
        /*fr*/ "TAPE",
        /*pl*/ "TAPE"];
    static String get input_selector_tape1 => l_input_selector_tape1[_language];

    static const List<String> l_input_selector_tape2 = [
        /*en*/ "TAPE 2",
        /*ru*/ "TAPE 2",
        /*de*/ "TAPE 2",
        /*fr*/ "TAPE 2",
        /*pl*/ "TAPE 2"];
    static String get input_selector_tape2 => l_input_selector_tape2[_language];

    static const List<String> l_input_selector_phono = [
        /*en*/ "PHONO",
        /*ru*/ "PHONO",
        /*de*/ "PHONO",
        /*fr*/ "PHONO",
        /*pl*/ "PHONO"];
    static String get input_selector_phono => l_input_selector_phono[_language];

    static const List<String> l_input_selector_cd = [
        /*en*/ "CD",
        /*ru*/ "CD",
        /*de*/ "CD",
        /*fr*/ "CD",
        /*pl*/ "CD"];
    static String get input_selector_cd => l_input_selector_cd[_language];

    static const List<String> l_input_selector_fm = [
        /*en*/ "FM",
        /*ru*/ "FM",
        /*de*/ "FM",
        /*fr*/ "FM",
        /*pl*/ "FM"];
    static String get input_selector_fm => l_input_selector_fm[_language];

    static const List<String> l_input_selector_am = [
        /*en*/ "AM",
        /*ru*/ "AM",
        /*de*/ "AM",
        /*fr*/ "AM",
        /*pl*/ "AM"];
    static String get input_selector_am => l_input_selector_am[_language];

    static const List<String> l_input_selector_tuner = [
        /*en*/ "TUNER",
        /*ru*/ "TUNER",
        /*de*/ "TUNER",
        /*fr*/ "TUNER",
        /*pl*/ "TUNER"];
    static String get input_selector_tuner => l_input_selector_tuner[_language];

    static const List<String> l_input_selector_music_server = [
        /*en*/ "DLNA",
        /*ru*/ "DLNA",
        /*de*/ "DLNA",
        /*fr*/ "DLNA",
        /*pl*/ "DLNA"];
    static String get input_selector_music_server => l_input_selector_music_server[_language];

    static const List<String> l_input_selector_internet_radio = [
        /*en*/ "INTERNET RADIO",
        /*ru*/ "INTERNET RADIO",
        /*de*/ "INTERNET RADIO",
        /*fr*/ "INTERNET RADIO",
        /*pl*/ "INTERNET RADIO"];
    static String get input_selector_internet_radio => l_input_selector_internet_radio[_language];

    static const List<String> l_input_selector_usb_front = [
        /*en*/ "USB(F)",
        /*ru*/ "USB(F)",
        /*de*/ "USB(F)",
        /*fr*/ "USB(F)",
        /*pl*/ "USB(F)"];
    static String get input_selector_usb_front => l_input_selector_usb_front[_language];

    static const List<String> l_input_selector_usb_rear = [
        /*en*/ "USB(R)",
        /*ru*/ "USB(R)",
        /*de*/ "USB(R)",
        /*fr*/ "USB(R)",
        /*pl*/ "USB(R)"];
    static String get input_selector_usb_rear => l_input_selector_usb_rear[_language];

    static const List<String> l_input_selector_net = [
        /*en*/ "NET",
        /*ru*/ "NET",
        /*de*/ "NET",
        /*fr*/ "NET",
        /*pl*/ "NET"];
    static String get input_selector_net => l_input_selector_net[_language];

    static const List<String> l_input_selector_usb_toggle = [
        /*en*/ "USB TOGGLE",
        /*ru*/ "USB TOGGLE",
        /*de*/ "USB TOGGLE",
        /*fr*/ "USB TOGGLE",
        /*pl*/ "USB TOGGLE"];
    static String get input_selector_usb_toggle => l_input_selector_usb_toggle[_language];

    static const List<String> l_input_selector_airplay = [
        /*en*/ "AIRPLAY",
        /*ru*/ "AIRPLAY",
        /*de*/ "AIRPLAY",
        /*fr*/ "AIRPLAY",
        /*pl*/ "AIRPLAY"];
    static String get input_selector_airplay => l_input_selector_airplay[_language];

    static const List<String> l_input_selector_bluetooth = [
        /*en*/ "BLUETOOTH",
        /*ru*/ "BLUETOOTH",
        /*de*/ "BLUETOOTH",
        /*fr*/ "BLUETOOTH",
        /*pl*/ "BLUETOOTH"];
    static String get input_selector_bluetooth => l_input_selector_bluetooth[_language];

    static const List<String> l_input_selector_usb_dac_in = [
        /*en*/ "USB DAC",
        /*ru*/ "USB DAC",
        /*de*/ "USB DAC",
        /*fr*/ "USB DAC",
        /*pl*/ "USB DAC"];
    static String get input_selector_usb_dac_in => l_input_selector_usb_dac_in[_language];

    static const List<String> l_input_selector_line = [
        /*en*/ "LINE",
        /*ru*/ "LINE",
        /*de*/ "LINE",
        /*fr*/ "LINE",
        /*pl*/ "LINE"];
    static String get input_selector_line => l_input_selector_line[_language];

    static const List<String> l_input_selector_line2 = [
        /*en*/ "LINE 2",
        /*ru*/ "LINE 2",
        /*de*/ "LINE 2",
        /*fr*/ "LINE 2",
        /*pl*/ "LINE 2"];
    static String get input_selector_line2 => l_input_selector_line2[_language];

    static const List<String> l_input_selector_optical = [
        /*en*/ "OPTICAL",
        /*ru*/ "OPTICAL",
        /*de*/ "OPTICAL",
        /*fr*/ "OPTICAL",
        /*pl*/ "OPTICAL"];
    static String get input_selector_optical => l_input_selector_optical[_language];

    static const List<String> l_input_selector_coaxial = [
        /*en*/ "COAXIAL",
        /*ru*/ "COAXIAL",
        /*de*/ "COAXIAL",
        /*fr*/ "COAXIAL",
        /*pl*/ "COAXIAL"];
    static String get input_selector_coaxial => l_input_selector_coaxial[_language];

    static const List<String> l_input_selector_universal_port = [
        /*en*/ "UNIVERSAL PORT",
        /*ru*/ "UNIVERSAL PORT",
        /*de*/ "UNIVERSAL PORT",
        /*fr*/ "UNIVERSAL PORT",
        /*pl*/ "UNIVERSAL PORT"];
    static String get input_selector_universal_port => l_input_selector_universal_port[_language];

    static const List<String> l_input_selector_multi_ch = [
        /*en*/ "MULTI CH",
        /*ru*/ "MULTI CH",
        /*de*/ "MULTI CH",
        /*fr*/ "MULTI CH",
        /*pl*/ "MULTI CH"];
    static String get input_selector_multi_ch => l_input_selector_multi_ch[_language];

    static const List<String> l_input_selector_xm = [
        /*en*/ "XM",
        /*ru*/ "XM",
        /*de*/ "XM",
        /*fr*/ "XM",
        /*pl*/ "XM"];
    static String get input_selector_xm => l_input_selector_xm[_language];

    static const List<String> l_input_selector_sirius = [
        /*en*/ "SIRIUS",
        /*ru*/ "SIRIUS",
        /*de*/ "SIRIUS",
        /*fr*/ "SIRIUS",
        /*pl*/ "SIRIUS"];
    static String get input_selector_sirius => l_input_selector_sirius[_language];

    static const List<String> l_input_selector_dab = [
        /*en*/ "DAB",
        /*ru*/ "DAB",
        /*de*/ "DAB",
        /*fr*/ "DAB",
        /*pl*/ "DAB"];
    static String get input_selector_dab => l_input_selector_dab[_language];

    static const List<String> l_input_selector_hdmi_5 = [
        /*en*/ "HDMI 5",
        /*ru*/ "HDMI 5",
        /*de*/ "HDMI 5",
        /*fr*/ "HDMI 5",
        /*pl*/ "HDMI 5"];
    static String get input_selector_hdmi_5 => l_input_selector_hdmi_5[_language];

    static const List<String> l_input_selector_hdmi_6 = [
        /*en*/ "HDMI 6",
        /*ru*/ "HDMI 6",
        /*de*/ "HDMI 6",
        /*fr*/ "HDMI 6",
        /*pl*/ "HDMI 6"];
    static String get input_selector_hdmi_6 => l_input_selector_hdmi_6[_language];

    static const List<String> l_input_selector_hdmi_7 = [
        /*en*/ "HDMI 7",
        /*ru*/ "HDMI 7",
        /*de*/ "HDMI 7",
        /*fr*/ "HDMI 7",
        /*pl*/ "HDMI 7"];
    static String get input_selector_hdmi_7 => l_input_selector_hdmi_7[_language];

    static const List<String> l_input_selector_source = [
        /*en*/ "SOURCE",
        /*ru*/ "SOURCE",
        /*de*/ "SOURCE",
        /*fr*/ "SOURCE",
        /*pl*/ "SOURCE"];
    static String get input_selector_source => l_input_selector_source[_language];

    static const List<String> l_input_selector_dvd = [
        /*en*/ "DVD",
        /*ru*/ "DVD",
        /*de*/ "DVD",
        /*fr*/ "DVD",
        /*pl*/ "DVD"];
    static String get input_selector_dvd => l_input_selector_dvd[_language];

    static const List<String> l_input_selector_bd = [
        /*en*/ "BD",
        /*ru*/ "BD",
        /*de*/ "BD",
        /*fr*/ "BD",
        /*pl*/ "BD"];
    static String get input_selector_bd => l_input_selector_bd[_language];

    static const List<String> l_input_selector_mplayer = [
        /*en*/ "MEDIA PLAYER",
        /*ru*/ "MEDIA PLAYER",
        /*de*/ "MEDIA PLAYER",
        /*fr*/ "MEDIA PLAYER",
        /*pl*/ "MEDIA PLAYER"];
    static String get input_selector_mplayer => l_input_selector_mplayer[_language];

    static const List<String> l_service_music_server = [
        /*en*/ "Music Server (DLNA)",
        /*ru*/ "Домашний музыкальный сервер",
        /*de*/ "Musik Server (DLNA)",
        /*fr*/ "Music Server (DLNA)",
        /*pl*/ "Music Server (DLNA)"];
    static String get service_music_server => l_service_music_server[_language];

    static const List<String> l_service_favorite = [
        /*en*/ "Favorite",
        /*ru*/ "Любимые",
        /*de*/ "Favoriten",
        /*fr*/ "Favorite",
        /*pl*/ "Favorite"];
    static String get service_favorite => l_service_favorite[_language];

    static const List<String> l_service_vtuner = [
        /*en*/ "vTuner",
        /*ru*/ "vTuner",
        /*de*/ "vTuner",
        /*fr*/ "vTuner",
        /*pl*/ "vTuner"];
    static String get service_vtuner => l_service_vtuner[_language];

    static const List<String> l_service_siriusxm = [
        /*en*/ "SiriusXM",
        /*ru*/ "SiriusXM",
        /*de*/ "SiriusXM",
        /*fr*/ "SiriusXM",
        /*pl*/ "SiriusXM"];
    static String get service_siriusxm => l_service_siriusxm[_language];

    static const List<String> l_service_pandora = [
        /*en*/ "Pandora",
        /*ru*/ "Pandora",
        /*de*/ "Pandora",
        /*fr*/ "Pandora",
        /*pl*/ "Pandora"];
    static String get service_pandora => l_service_pandora[_language];

    static const List<String> l_service_rhapsody = [
        /*en*/ "Rhapsody",
        /*ru*/ "Rhapsody",
        /*de*/ "Rhapsody",
        /*fr*/ "Rhapsody",
        /*pl*/ "Rhapsody"];
    static String get service_rhapsody => l_service_rhapsody[_language];

    static const List<String> l_service_last = [
        /*en*/ "Last.fm",
        /*ru*/ "Last.fm",
        /*de*/ "Last.fm",
        /*fr*/ "Last.fm",
        /*pl*/ "Last.fm"];
    static String get service_last => l_service_last[_language];

    static const List<String> l_service_napster = [
        /*en*/ "Napster",
        /*ru*/ "Napster",
        /*de*/ "Napster",
        /*fr*/ "Napster",
        /*pl*/ "Napster"];
    static String get service_napster => l_service_napster[_language];

    static const List<String> l_service_slacker = [
        /*en*/ "Slacker",
        /*ru*/ "Slacker",
        /*de*/ "Slacker",
        /*fr*/ "Slacker",
        /*pl*/ "Slacker"];
    static String get service_slacker => l_service_slacker[_language];

    static const List<String> l_service_mediafly = [
        /*en*/ "Mediafly",
        /*ru*/ "Mediafly",
        /*de*/ "Mediafly",
        /*fr*/ "Mediafly",
        /*pl*/ "Mediafly"];
    static String get service_mediafly => l_service_mediafly[_language];

    static const List<String> l_service_spotify = [
        /*en*/ "Spotify",
        /*ru*/ "Spotify",
        /*de*/ "Spotify",
        /*fr*/ "Spotify",
        /*pl*/ "Spotify"];
    static String get service_spotify => l_service_spotify[_language];

    static const List<String> l_service_spotify_missing_app = [
        /*en*/ "Spotify app is not found on the device",
        /*ru*/ "Приложение Spotify не найдено на устройстве",
        /*de*/ "Die Spotify-App ist auf dem Gerät nicht gefunden",
        /*fr*/ "L\'application Spotify est introuvable sur l\'appareil",
        /*pl*/ "Na urządzeniu nie znaleziono aplikacji Spotify"];
    static String get service_spotify_missing_app => l_service_spotify_missing_app[_language];

    static const List<String> l_service_aupeo = [
        /*en*/ "AUPEO!",
        /*ru*/ "AUPEO!",
        /*de*/ "AUPEO!",
        /*fr*/ "AUPEO!",
        /*pl*/ "AUPEO!"];
    static String get service_aupeo => l_service_aupeo[_language];

    static const List<String> l_service_radiko = [
        /*en*/ "Radiko",
        /*ru*/ "Radiko",
        /*de*/ "Radiko",
        /*fr*/ "Radiko",
        /*pl*/ "Radiko"];
    static String get service_radiko => l_service_radiko[_language];

    static const List<String> l_service_e_onkyo = [
        /*en*/ "e-onkyo",
        /*ru*/ "e-onkyo",
        /*de*/ "e-onkyo",
        /*fr*/ "e-onkyo",
        /*pl*/ "e-onkyo"];
    static String get service_e_onkyo => l_service_e_onkyo[_language];

    static const List<String> l_service_tunein_radio = [
        /*en*/ "TuneIn Radio",
        /*ru*/ "TuneIn Radio",
        /*de*/ "TuneIn Radio",
        /*fr*/ "TuneIn Radio",
        /*pl*/ "TuneIn Radio"];
    static String get service_tunein_radio => l_service_tunein_radio[_language];

    static const List<String> l_service_mp3tunes = [
        /*en*/ "mp3tunes",
        /*ru*/ "mp3tunes",
        /*de*/ "mp3tunes",
        /*fr*/ "mp3tunes",
        /*pl*/ "mp3tunes"];
    static String get service_mp3tunes => l_service_mp3tunes[_language];

    static const List<String> l_service_simfy = [
        /*en*/ "Simfy",
        /*ru*/ "Simfy",
        /*de*/ "Simfy",
        /*fr*/ "Simfy",
        /*pl*/ "Simfy"];
    static String get service_simfy => l_service_simfy[_language];

    static const List<String> l_service_home_media = [
        /*en*/ "Home Media",
        /*ru*/ "Home Media",
        /*de*/ "Home Media",
        /*fr*/ "Home Media",
        /*pl*/ "Home Media"];
    static String get service_home_media => l_service_home_media[_language];

    static const List<String> l_service_deezer = [
        /*en*/ "Deezer",
        /*ru*/ "Deezer",
        /*de*/ "Deezer",
        /*fr*/ "Deezer",
        /*pl*/ "Deezer"];
    static String get service_deezer => l_service_deezer[_language];

    static const List<String> l_service_iheartradio = [
        /*en*/ "iHeartRadio",
        /*ru*/ "iHeartRadio",
        /*de*/ "iHeartRadio",
        /*fr*/ "iHeartRadio",
        /*pl*/ "iHeartRadio"];
    static String get service_iheartradio => l_service_iheartradio[_language];

    static const List<String> l_service_airplay = [
        /*en*/ "AirPlay",
        /*ru*/ "AirPlay",
        /*de*/ "AirPlay",
        /*fr*/ "AirPlay",
        /*pl*/ "AirPlay"];
    static String get service_airplay => l_service_airplay[_language];

    static const List<String> l_service_onkyo_music = [
        /*en*/ "Onkyo Music",
        /*ru*/ "Onkyo Music",
        /*de*/ "Onkyo Music",
        /*fr*/ "Onkyo Music",
        /*pl*/ "Onkyo Music"];
    static String get service_onkyo_music => l_service_onkyo_music[_language];

    static const List<String> l_service_tidal = [
        /*en*/ "Tidal",
        /*ru*/ "Tidal",
        /*de*/ "Tidal",
        /*fr*/ "Tidal",
        /*pl*/ "Tidal"];
    static String get service_tidal => l_service_tidal[_language];

    static const List<String> l_service_amazon_music = [
        /*en*/ "Amazon Music",
        /*ru*/ "Amazon Music",
        /*de*/ "Amazon Music",
        /*fr*/ "Amazon Music",
        /*pl*/ "Amazon Music"];
    static String get service_amazon_music => l_service_amazon_music[_language];

    static const List<String> l_service_playqueue = [
        /*en*/ "Play Queue",
        /*ru*/ "Play Queue",
        /*de*/ "Play Queue",
        /*fr*/ "Play Queue",
        /*pl*/ "Play Queue"];
    static String get service_playqueue => l_service_playqueue[_language];

    static const List<String> l_service_chromecast = [
        /*en*/ "Chromecast",
        /*ru*/ "Chromecast",
        /*de*/ "Chromecast",
        /*fr*/ "Chromecast",
        /*pl*/ "Chromecast"];
    static String get service_chromecast => l_service_chromecast[_language];

    static const List<String> l_service_fireconnect = [
        /*en*/ "FireConnect",
        /*ru*/ "FireConnect",
        /*de*/ "FireConnect",
        /*fr*/ "FireConnect",
        /*pl*/ "FireConnect"];
    static String get service_fireconnect => l_service_fireconnect[_language];

    static const List<String> l_service_flareconnect = [
        /*en*/ "FlareConnect",
        /*ru*/ "FlareConnect",
        /*de*/ "FlareConnect",
        /*fr*/ "FlareConnect",
        /*pl*/ "FlareConnect"];
    static String get service_flareconnect => l_service_flareconnect[_language];

    static const List<String> l_service_usb_front = [
        /*en*/ "Front USB",
        /*ru*/ "Передний USB",
        /*de*/ "USB vorne",
        /*fr*/ "USB avant",
        /*pl*/ "Front USB"];
    static String get service_usb_front => l_service_usb_front[_language];

    static const List<String> l_service_usb_rear = [
        /*en*/ "Rear USB",
        /*ru*/ "Задний USB",
        /*de*/ "USB hinten",
        /*fr*/ "USB arrière",
        /*pl*/ "Rear USB"];
    static String get service_usb_rear => l_service_usb_rear[_language];

    static const List<String> l_service_internet_radio = [
        /*en*/ "Internet Radio",
        /*ru*/ "Internet Radio",
        /*de*/ "Internet Radio",
        /*fr*/ "Internet Radio",
        /*pl*/ "Internet Radio"];
    static String get service_internet_radio => l_service_internet_radio[_language];

    static const List<String> l_service_play_fi = [
        /*en*/ "Play-Fi",
        /*ru*/ "Play-Fi",
        /*de*/ "Play-Fi",
        /*fr*/ "Play-Fi",
        /*pl*/ "Play-Fi"];
    static String get service_play_fi => l_service_play_fi[_language];

    static const List<String> l_service_net = [
        /*en*/ "Network",
        /*ru*/ "Сеть",
        /*de*/ "Netzwerk",
        /*fr*/ "Network",
        /*pl*/ "Network"];
    static String get service_net => l_service_net[_language];

    static const List<String> l_service_bluetooth = [
        /*en*/ "Bluetooth",
        /*ru*/ "Bluetooth",
        /*de*/ "Bluetooth",
        /*fr*/ "Bluetooth",
        /*pl*/ "Bluetooth"];
    static String get service_bluetooth => l_service_bluetooth[_language];

    static const List<String> l_service_playlist = [
        /*en*/ "Play List",
        /*ru*/ "Плейлисты",
        /*de*/ "Play List",
        /*fr*/ "Play List",
        /*pl*/ "Play List"];
    static String get service_playlist => l_service_playlist[_language];

    static const List<String> l_service_soundcloud = [
        /*en*/ "Soundcloud",
        /*ru*/ "Soundcloud",
        /*de*/ "Soundcloud",
        /*fr*/ "Soundcloud",
        /*pl*/ "Soundcloud"];
    static String get service_soundcloud => l_service_soundcloud[_language];

    static const List<String> l_service_local_music = [
        /*en*/ "Local Music",
        /*ru*/ "Музыка на устройстве",
        /*de*/ "Local Music",
        /*fr*/ "Local Music",
        /*pl*/ "Local Music"];
    static String get service_local_music => l_service_local_music[_language];

    static const List<String> l_service_history = [
        /*en*/ "History",
        /*ru*/ "История",
        /*de*/ "History",
        /*fr*/ "History",
        /*pl*/ "History"];
    static String get service_history => l_service_history[_language];

    static const List<String> l_service_aux_input = [
        /*en*/ "AUX Input",
        /*ru*/ "AV Входы",
        /*de*/ "AUX Input",
        /*fr*/ "AUX Input",
        /*pl*/ "AUX Input"];
    static String get service_aux_input => l_service_aux_input[_language];

    static const List<String> l_playlist_options = [
        /*en*/ "Play queue",
        /*ru*/ "Очередь воспроизведения",
        /*de*/ "Abspielliste",
        /*fr*/ "File de lecture",
        /*pl*/ "Kolejka odtwarzania"];
    static String get playlist_options => l_playlist_options[_language];

    static const List<String> l_playlist_add = [
        /*en*/ "Add",
        /*ru*/ "Добавить",
        /*de*/ "Hinzufügen",
        /*fr*/ "Ajouter",
        /*pl*/ "Dodaj"];
    static String get playlist_add => l_playlist_add[_language];

    static const List<String> l_playlist_add_and_play = [
        /*en*/ "Add and play",
        /*ru*/ "Добавить и воспроизвести",
        /*de*/ "Hinzufügen und abspielen",
        /*fr*/ "Ajouter et lire",
        /*pl*/ "Dodaj i odtwórz"];
    static String get playlist_add_and_play => l_playlist_add_and_play[_language];

    static const List<String> l_playlist_replace = [
        /*en*/ "Replace",
        /*ru*/ "Заменить",
        /*de*/ "Ersetzen",
        /*fr*/ "Remplacer",
        /*pl*/ "Zastąp"];
    static String get playlist_replace => l_playlist_replace[_language];

    static const List<String> l_playlist_replace_and_play = [
        /*en*/ "Replace and play",
        /*ru*/ "Заменить и воспроизвести",
        /*de*/ "Ersetzen und abspielen",
        /*fr*/ "Remplacer et lire",
        /*pl*/ "Zastąp i odtwórz"];
    static String get playlist_replace_and_play => l_playlist_replace_and_play[_language];

    static const List<String> l_playlist_remove = [
        /*en*/ "Remove item",
        /*ru*/ "Удалить позицию",
        /*de*/ "Element entfernen",
        /*fr*/ "Supprimer élément",
        /*pl*/ "Usuń pozycję"];
    static String get playlist_remove => l_playlist_remove[_language];

    static const List<String> l_playlist_remove_all = [
        /*en*/ "Remove all",
        /*ru*/ "Удалить все",
        /*de*/ "Alle entfernen",
        /*fr*/ "Supprimer tout",
        /*pl*/ "Usuń wszystko"];
    static String get playlist_remove_all => l_playlist_remove_all[_language];

    static const List<String> l_playlist_move_from = [
        /*en*/ "Move from",
        /*ru*/ "Вырезать",
        /*de*/ "Verschiebe von",
        /*fr*/ "Déplacer depuis",
        /*pl*/ "Przenieś z"];
    static String get playlist_move_from => l_playlist_move_from[_language];

    static const List<String> l_playlist_move_to = [
        /*en*/ "Move to",
        /*ru*/ "Вставить",
        /*de*/ "Verschiebe nach",
        /*fr*/ "Déplacer vers",
        /*pl*/ "Przenieś do"];
    static String get playlist_move_to => l_playlist_move_to[_language];

    static const List<String> l_playlist_add_all = [
        /*en*/ "Add all",
        /*ru*/ "Добавить все",
        /*de*/ "Alle hinzufügen",
        /*fr*/ "Tout ajouter",
        /*pl*/ "Dodać wszystko"];
    static String get playlist_add_all => l_playlist_add_all[_language];

    static const List<String> l_playlist_add_and_play_all = [
        /*en*/ "Add and play all",
        /*ru*/ "Добавить и воспроизвести все",
        /*de*/ "Alle hinzufügen und abspielen",
        /*fr*/ "Ajouter et jouer tous",
        /*pl*/ "Dodaj i zagraj we wszystko"];
    static String get playlist_add_and_play_all => l_playlist_add_and_play_all[_language];

    static const List<String> l_playlist_replace_and_play_all = [
        /*en*/ "Replace and play all",
        /*ru*/ "Заменить и воспроизвести все",
        /*de*/ "Alle ersetzen und abspielen",
        /*fr*/ "Remplacez et jouez tous",
        /*pl*/ "Wymień i zagraj we wszystko"];
    static String get playlist_replace_and_play_all => l_playlist_replace_and_play_all[_language];

    static const List<String> l_playlist_add_to_heos_favourites = [
        /*en*/ "Add to HEOS Favorites",
        /*ru*/ "Добавить в Любимые HEOS",
        /*de*/ "Zu HEOS Favoriten hinzufügen",
        /*fr*/ "Ajouter aux favoris HEOS",
        /*pl*/ "Dodaj do ulubionych HEOS"];
    static String get playlist_add_to_heos_favourites => l_playlist_add_to_heos_favourites[_language];

    static const List<String> l_playlist_remove_from_heos_favourites = [
        /*en*/ "Remove from HEOS Favorites",
        /*ru*/ "Удалить из Любимых HEOS",
        /*de*/ "Aus HEOS Favoriten entfernen",
        /*fr*/ "Supprimer des favoris HEOS",
        /*pl*/ "Usuń z Ulubionych HEOS"];
    static String get playlist_remove_from_heos_favourites => l_playlist_remove_from_heos_favourites[_language];

    static const List<String> l_device_friendly_name = [
        /*en*/ "Friendly name",
        /*ru*/ "Удобное название",
        /*de*/ "Gewählter Name",
        /*fr*/ "Nom personnalisé",
        /*pl*/ "Nazwa"];
    static String get device_friendly_name => l_device_friendly_name[_language];

    static const List<String> l_device_change_friendly_name = [
        /*en*/ "Change friendly name",
        /*ru*/ "Изменить удобное название",
        /*de*/ "Namen bearbeiten",
        /*fr*/ "Changer le nom personnalisé",
        /*pl*/ "Zmień nazwę"];
    static String get device_change_friendly_name => l_device_change_friendly_name[_language];

    static const List<String> l_device_info = [
        /*en*/ "Device info",
        /*ru*/ "Информация",
        /*de*/ "Gerätinformationen",
        /*fr*/ "Information Dispositif",
        /*pl*/ "Informacja o urządzeniu"];
    static String get device_info => l_device_info[_language];

    static const List<String> l_device_brand = [
        /*en*/ "Brand",
        /*ru*/ "Производитель",
        /*de*/ "Marke",
        /*fr*/ "Marque",
        /*pl*/ "Marka"];
    static String get device_brand => l_device_brand[_language];

    static const List<String> l_device_model = [
        /*en*/ "Model",
        /*ru*/ "Модель",
        /*de*/ "Modell",
        /*fr*/ "Modèle",
        /*pl*/ "Model"];
    static String get device_model => l_device_model[_language];

    static const List<String> l_device_year = [
        /*en*/ "Year",
        /*ru*/ "Год",
        /*de*/ "Jahr",
        /*fr*/ "Année",
        /*pl*/ "Rok"];
    static String get device_year => l_device_year[_language];

    static const List<String> l_google_cast_version = [
        /*en*/ "Google Cast",
        /*ru*/ "Google Cast",
        /*de*/ "Google Cast",
        /*fr*/ "Google Cast",
        /*pl*/ "Google Cast"];
    static String get google_cast_version => l_google_cast_version[_language];

    static const List<String> l_device_settings = [
        /*en*/ "Settings",
        /*ru*/ "Настройки",
        /*de*/ "Einstellungen",
        /*fr*/ "Paramètres",
        /*pl*/ "Ustawienia"];
    static String get device_settings => l_device_settings[_language];

    static const List<String> l_device_parameter_help = [
        /*en*/ "Show parameter description",
        /*ru*/ "Показать описание параметра",
        /*de*/ "Parameterbeschreibung anzeigen",
        /*fr*/ "Afficher la description du paramètre",
        /*pl*/ "Pokaż opis parametru"];
    static String get device_parameter_help => l_device_parameter_help[_language];

    static const List<String> l_device_firmware = [
        /*en*/ "Firmware",
        /*ru*/ "Прошивка",
        /*de*/ "Firmware",
        /*fr*/ "Firmware",
        /*pl*/ "Firmware"];
    static String get device_firmware => l_device_firmware[_language];

    static const List<String> l_device_firmware_none = [
        /*en*/ "N/A",
        /*ru*/ "Неизвестно",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_firmware_none => l_device_firmware_none[_language];

    static const List<String> l_device_firmware_actual = [
        /*en*/ "Latest version",
        /*ru*/ "Актуальная версия",
        /*de*/ "Aktuellste Version",
        /*fr*/ "Dernière version",
        /*pl*/ "Ostatnia wersja"];
    static String get device_firmware_actual => l_device_firmware_actual[_language];

    static const List<String> l_device_firmware_new_version = [
        /*en*/ "New version exists",
        /*ru*/ "Обнаружена новая версия",
        /*de*/ "Es gibt eine neue Version",
        /*fr*/ "Nouvelle version disponible",
        /*pl*/ "Dostępna aktualizacja"];
    static String get device_firmware_new_version => l_device_firmware_new_version[_language];

    static const List<String> l_device_firmware_update_started = [
        /*en*/ "Update started, please wait",
        /*ru*/ "Обновление началось, ждите",
        /*de*/ "Update gestartet, bitte warten",
        /*fr*/ "Mise à jour en cours, patientez…",
        /*pl*/ "Aktualizacja rozpoczęta, proszę czekać"];
    static String get device_firmware_update_started => l_device_firmware_update_started[_language];

    static const List<String> l_device_firmware_update_complete = [
        /*en*/ "Update completed, please wait until device is rebooted and reconnect it",
        /*ru*/ "Обновление завершено",
        /*de*/ "Update abgeschlossen",
        /*fr*/ "Mise à jour terminée, merci d\'attendre le redémarrage et connecter de nouveau",
        /*pl*/ "Aktualizacja zakończona, poczekaj, aż urządzenie uruchomi się ponownie i podłącz się ponownie"];
    static String get device_firmware_update_complete => l_device_firmware_update_complete[_language];

    static const List<String> l_device_firmware_net = [
        /*en*/ "Start device update via network",
        /*ru*/ "Обновить устройство по сети",
        /*de*/ "Update über Netzwerk starten",
        /*fr*/ "Lancer la mise à jour par le réseau",
        /*pl*/ "Rozpocznij aktualizację urządzenia przez sieć"];
    static String get device_firmware_net => l_device_firmware_net[_language];

    static const List<String> l_device_firmware_confirm = [
        /*en*/ "Do you really want to download and install the actual firmware?",
        /*ru*/ "Вы действительно хотите скачать и установить актуальную прошивку?",
        /*de*/ "Möchten Sie wirklich die aktuelle Firmware herunterladen und installieren?",
        /*fr*/ "Voulez-vous vraiment télécharger et installer le firmware actuel?",
        /*pl*/ "Czy na pewno chcesz pobrać i zainstalować aktualne oprogramowanie?"];
    static String get device_firmware_confirm => l_device_firmware_confirm[_language];

    static const List<String> l_device_dimmer_level = [
        /*en*/ "Dimmer level",
        /*ru*/ "Яркость дисплея",
        /*de*/ "Anzeigehelligkeit",
        /*fr*/ "Niveau éclairage",
        /*pl*/ "Jasność wyświetlacza"];
    static String get device_dimmer_level => l_device_dimmer_level[_language];

    static const List<String> l_device_dimmer_level_none = [
        /*en*/ "N/A",
        /*ru*/ "Пусто",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_dimmer_level_none => l_device_dimmer_level_none[_language];

    static const List<String> l_device_dimmer_level_bright = [
        /*en*/ "Bright",
        /*ru*/ "Ярко",
        /*de*/ "Hell",
        /*fr*/ "Lumineux",
        /*pl*/ "Jasny"];
    static String get device_dimmer_level_bright => l_device_dimmer_level_bright[_language];

    static const List<String> l_device_dimmer_level_dim = [
        /*en*/ "Dim",
        /*ru*/ "Неярко",
        /*de*/ "Mittel",
        /*fr*/ "Doux",
        /*pl*/ "Średni"];
    static String get device_dimmer_level_dim => l_device_dimmer_level_dim[_language];

    static const List<String> l_device_dimmer_level_dark = [
        /*en*/ "Dark",
        /*ru*/ "Тускло",
        /*de*/ "Dunkel",
        /*fr*/ "Sombre",
        /*pl*/ "Ciemny"];
    static String get device_dimmer_level_dark => l_device_dimmer_level_dark[_language];

    static const List<String> l_device_dimmer_level_shut_off = [
        /*en*/ "Off",
        /*ru*/ "Выключено",
        /*de*/ "Aus",
        /*fr*/ "Éteint",
        /*pl*/ "Wyłączony"];
    static String get device_dimmer_level_shut_off => l_device_dimmer_level_shut_off[_language];

    static const List<String> l_device_dimmer_level_off = [
        /*en*/ "Off",
        /*ru*/ "Выключено",
        /*de*/ "Aus",
        /*fr*/ "Éteint",
        /*pl*/ "Wyłączony"];
    static String get device_dimmer_level_off => l_device_dimmer_level_off[_language];

    static const List<String> l_device_dimmer_level_toggle = [
        /*en*/ "Sets dimmer level wrap-around",
        /*ru*/ "Изменить яркость дисплея",
        /*de*/ "Helligkeitseinstellung wechseln",
        /*fr*/ "Changer niveau luminosité",
        /*pl*/ "Zmień na kolejny"];
    static String get device_dimmer_level_toggle => l_device_dimmer_level_toggle[_language];

    static const List<String> l_device_dimmer_level_help = [
        /*en*/ "You can change the brightness level of the device display.",
        /*ru*/ "Вы можете изменить уровень яркости дисплея устройства.",
        /*de*/ "Sie können die Helligkeitsstufe des Gerätedisplays ändern.",
        /*fr*/ "Vous pouvez modifier le niveau de luminosité de l\'écran de l\'appareil.",
        /*pl*/ "Możesz zmienić poziom jasności wyświetlacza urządzenia."];
    static String get device_dimmer_level_help => l_device_dimmer_level_help[_language];

    static const List<String> l_device_digital_filter = [
        /*en*/ "Digital filter",
        /*ru*/ "Цифровой фильтр",
        /*de*/ "Digitalfilter",
        /*fr*/ "Filtre Digital",
        /*pl*/ "Filtr cyfrowy"];
    static String get device_digital_filter => l_device_digital_filter[_language];

    static const List<String> l_device_digital_filter_none = [
        /*en*/ "N/A",
        /*ru*/ "Нет",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_digital_filter_none => l_device_digital_filter_none[_language];

    static const List<String> l_device_digital_filter_slow = [
        /*en*/ "Slow",
        /*ru*/ "Медленный",
        /*de*/ "Langsam",
        /*fr*/ "Lent",
        /*pl*/ "Wolny"];
    static String get device_digital_filter_slow => l_device_digital_filter_slow[_language];

    static const List<String> l_device_digital_filter_sharp = [
        /*en*/ "Sharp",
        /*ru*/ "Резкий",
        /*de*/ "Klar",
        /*fr*/ "Précis",
        /*pl*/ "Ostry"];
    static String get device_digital_filter_sharp => l_device_digital_filter_sharp[_language];

    static const List<String> l_device_digital_filter_short = [
        /*en*/ "Short",
        /*ru*/ "Короткий",
        /*de*/ "Kurz",
        /*fr*/ "Court",
        /*pl*/ "Krótki"];
    static String get device_digital_filter_short => l_device_digital_filter_short[_language];

    static const List<String> l_device_digital_filter_toggle = [
        /*en*/ "Sets digital filter wrap-around",
        /*ru*/ "Изменить цифровой фильтр",
        /*de*/ "Digitalfilter wechseln",
        /*fr*/ "Changer filtre digital",
        /*pl*/ "Zmień na kolejny"];
    static String get device_digital_filter_toggle => l_device_digital_filter_toggle[_language];

    static const List<String> l_device_digital_filter_help = [
        /*en*/ "You can switch the type of digital filter in the audio DAC. You can choose \"Slow\" (gives the sound a soft and fluid feel), \"Sharp\" (gives the sound more structure and firmer feel) or \"Short\" (auto).",
        /*ru*/ "Вы можете переключать тип цифрового фильтра в аудио ЦАП. Вы можете выбрать \"Медленный\" (придает звуку мягкость и плавность), \"Резкий\" (придает звуку более структурированный и твердый вид) или \"Короткий\" (авто).",
        /*de*/ "Sie können den Typ des digitalen Filters im Audio-DAC umschalten. Sie können \"Langsam\" (verleiht dem Klang ein weiches und flüssiges Gefühl), \"Klar\" (verleiht dem Klang mehr Struktur und ein festeres Gefühl) oder \"Kurz\" (automatisch) wählen.",
        /*fr*/ "Vous pouvez changer le type de filtre numérique dans le DAC audio. Vous pouvez choisir \"Lent\" (donne au son une sensation douce et fluide), \"Précis\" (donne au son plus de structure et une sensation plus ferme) ou \"Court\" (auto).",
        /*pl*/ "Możesz zmienić typ filtra cyfrowego w DAC audio. Możesz wybrać \"Wolny\" (nadaje dźwiękowi miękkie i płynne odczucie), \"Ostry\" (nadaje dźwiękowi bardziej strukturę i jędrność) lub \"Krótki\" (auto)."];
    static String get device_digital_filter_help => l_device_digital_filter_help[_language];

    static const List<String> l_device_two_way_switch_none = [
        /*en*/ "N/A",
        /*ru*/ "Нет",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_two_way_switch_none => l_device_two_way_switch_none[_language];

    static const List<String> l_device_two_way_switch_off = [
        /*en*/ "Off",
        /*ru*/ "Выкл",
        /*de*/ "Aus",
        /*fr*/ "Arrêt",
        /*pl*/ "Off"];
    static String get device_two_way_switch_off => l_device_two_way_switch_off[_language];

    static const List<String> l_device_two_way_switch_on = [
        /*en*/ "On",
        /*ru*/ "Вкл",
        /*de*/ "An",
        /*fr*/ "Marche",
        /*pl*/ "On"];
    static String get device_two_way_switch_on => l_device_two_way_switch_on[_language];

    static const List<String> l_device_two_way_switch_auto = [
        /*en*/ "Auto",
        /*ru*/ "Авто",
        /*de*/ "Auto",
        /*fr*/ "Auto",
        /*pl*/ "Auto"];
    static String get device_two_way_switch_auto => l_device_two_way_switch_auto[_language];

    static const List<String> l_device_two_way_switch_toggle = [
        /*en*/ "Toggle",
        /*ru*/ "Изменить",
        /*de*/ "Wechseln",
        /*fr*/ "Changer",
        /*pl*/ "Przełącznik"];
    static String get device_two_way_switch_toggle => l_device_two_way_switch_toggle[_language];

    static const List<String> l_device_music_optimizer = [
        /*en*/ "Music optimizer",
        /*ru*/ "Оптимизация звука",
        /*de*/ "Musikoptimierung",
        /*fr*/ "Optimiseur audio",
        /*pl*/ "Music optimizer"];
    static String get device_music_optimizer => l_device_music_optimizer[_language];

    static const List<String> l_device_music_optimizer_help = [
        /*en*/ "Improve the quality of the compressed audio. Playback sound of lossy compressed files such as MP3 will be improved. The setting is effective with 2 ch signals with a sampling frequency of 48 kHz or less. The setting is not effective in the bitstream signals.",
        /*ru*/ "Улучшить качество сжатого звука. Воспроизведение сжатых файлов с потерями, таких как MP3, будет улучшено. Настройка эффективна для 2-канальных сигналов с частотой дискретизации 48 кГц или меньше. Эта настройка не действует для несжатых потоковыx сигналов.",
        /*de*/ "Verbessern Sie die Qualität des komprimierten Audios. Der Wiedergabeton von verlustbehafteten komprimierten Dateien wie MP3 wird verbessert. Die Einstellung ist bei 2-Kanal-Signalen mit einer Abtastfrequenz von 48 kHz oder weniger wirksam. Die Einstellung ist bei den Bitstream-Signalen nicht wirksam.",
        /*fr*/ "Améliorer la qualité de l\'audio compressé. Le son de lecture des fichiers compressés avec perte tels que MP3 sera amélioré. Le réglage est efficace avec des signaux à 2 canaux avec une fréquence d\'échantillonnage de 48 kHz ou moins. Le réglage n\'est pas efficace dans les signaux de flux binaire.",
        /*pl*/ "Popraw jakość skompresowanego dźwięku. Poprawiony zostanie dźwięk odtwarzanych stratnych plików skompresowanych, takich jak MP3. To ustawienie jest skuteczne w przypadku sygnałów 2-kanałowych o częstotliwości próbkowania 48 kHz lub mniejszej. To ustawienie nie działa w przypadku sygnałów strumienia bitów."];
    static String get device_music_optimizer_help => l_device_music_optimizer_help[_language];

    static const List<String> l_device_auto_power = [
        /*en*/ "Auto power",
        /*ru*/ "Авто-отключение",
        /*de*/ "Auto an/aus",
        /*fr*/ "Allumage auto",
        /*pl*/ "Auto power"];
    static String get device_auto_power => l_device_auto_power[_language];

    static const List<String> l_device_auto_power_help = [
        /*en*/ "Allows the unit to enter standby automatically when the certain time of inactivity without any audio input elapses. The time value depends on the device model.",
        /*ru*/ "Позволяет устройству автоматически переходить в режим ожидания по истечении определенного времени бездействия (без сигнала на входе). Время задержки зависит от модели устройства.",
        /*de*/ "Ermöglicht dem Gerät, automatisch in den Standby-Modus zu wechseln, wenn eine bestimmte Zeit der Inaktivität ohne Audioeingang verstrichen ist. Der Zeitwert hängt vom Gerätemodell ab. ",
        /*fr*/ "Permet à l\'appareil de se mettre automatiquement en veille lorsqu\'un certain temps d\'inactivité sans aucune entrée audio s\'est écoulé. La valeur de temps dépend du modèle d\'appareil.",
        /*pl*/ "Umożliwia automatyczne przejście urządzenia w stan czuwania po upływie określonego czasu bezczynności bez żadnego sygnału wejściowego audio. Wartość czasu zależy od modelu urządzenia."];
    static String get device_auto_power_help => l_device_auto_power_help[_language];

    static const List<String> l_device_hdmi_cec = [
        /*en*/ "HDMI CEC",
        /*ru*/ "HDMI CEC",
        /*de*/ "HDMI CEC",
        /*fr*/ "HDMI CEC",
        /*pl*/ "HDMI CEC"];
    static String get device_hdmi_cec => l_device_hdmi_cec[_language];

    static const List<String> l_device_hdmi_cec_help = [
        /*en*/ "By connecting a device that complies with CEC (Consumer Electronics Control) of the HDMI standard using an HDMI cable, a variety of linked operations between devices are possible. This function enables various linking operations with players, such as switching input selectors interlocking with a player, adjusting the volume of this unit using the remote controller of a TV, and automatically switching this unit to standby when the TV is turned off.",
        /*ru*/ "При подключении устройства, соответствующего CEC (Consumer Electronics Control) стандарта HDMI, с помощью кабеля HDMI возможны различные связанные операции между устройствами. Эта функция позволяет выполнять различные операции привязки к проигрывателям, такие как переключение селекторов входа, связанных с проигрывателем, регулировка громкости данного устройства с помощью пульта дистанционного управления телевизора и автоматическое переключение этого устройства в режим ожидания при выключении телевизора.",
        /*de*/ "Durch Anschließen eines Geräts, das CEC (Consumer Electronics Control) des HDMI-Standards entspricht, über ein HDMI-Kabel ist eine Vielzahl von verknüpften Vorgängen zwischen Geräten möglich. Diese Funktion ermöglicht verschiedene Verknüpfungsoperationen mit Playern, wie z. B. das Umschalten von Eingangsselektoren, die mit einem Player gekoppelt sind, das Einstellen der Lautstärke dieses Geräts mit der Fernbedienung eines Fernsehgeräts und das automatische Umschalten dieses Geräts in den Standby-Modus, wenn das Fernsehgerät ausgeschaltet wird.",
        /*fr*/ "En connectant un appareil conforme à CEC (Consumer Electronics Control) de la norme HDMI à l\'aide d\'un câble HDMI, une variété d\'opérations liées entre les appareils est possible. Cette fonction permet diverses opérations de liaison avec des lecteurs, telles que la commutation de sélecteurs d\'entrée verrouillés avec un lecteur, le réglage du volume de cet appareil à l\'aide de la télécommande d\'un téléviseur et la mise automatiquement en veille de cet appareil lorsque le téléviseur est éteint.",
        /*pl*/ "Podłączając urządzenie zgodne ze standardem CEC (Consumer Electronics Control) za pomocą kabla HDMI, możliwe są różne operacje połączone między urządzeniami. Ta funkcja umożliwia różne operacje łączenia z odtwarzaczami, takie jak przełączanie selektorów wejścia sprzężonych z odtwarzaczem, regulacja głośności tego urządzenia za pomocą pilota telewizora oraz automatyczne przełączanie tego urządzenia w tryb gotowości, gdy telewizor jest wyłączony. "];
    static String get device_hdmi_cec_help => l_device_hdmi_cec_help[_language];

    static const List<String> l_device_phase_matching_bass = [
        /*en*/ "Phase Matching Bass",
        /*ru*/ "Phase Matching Bass",
        /*de*/ "Phase Matching Bass",
        /*fr*/ "Basses avec adaptation de phase",
        /*pl*/ "Phase Matching Bass"];
    static String get device_phase_matching_bass => l_device_phase_matching_bass[_language];

    static const List<String> l_device_phase_matching_bass_help = [
        /*en*/ "Phase Matching Bass function eliminates phase-shift between low- and mid-range frequency bands above 300 Hz. Bass response is enhanced without compromising vocal clarity, and that\'s something especially useful when playing music at low volume where bass and high-frequency sounds are more difficult to hear.",
        /*ru*/ "Функция Phase Matching Bass устраняет фазовый сдвиг между полосами низких и средних частот выше 300 Гц. Отклик басов усиливается без ущерба для чистоты голоса, и это особенно полезно при воспроизведении музыки на низкой громкости, когда басы и высокие частоты труднее расслышать.",
        /*de*/ "Die Phase-Matching-Bass-Boost-Funktion eliminiert Phasenverschiebungen zwischen niedrigen und mittleren Frequenzbändern über 300 Hz. Die Basswiedergabe wird verbessert, ohne die Stimmklarheit zu beeinträchtigen, und das ist besonders nützlich, wenn Sie Musik bei niedriger Lautstärke spielen, wo Bässe und hochfrequente Töne schwerer zu hören sind.",
        /*fr*/ "La fonction Phase Matching Bass Boost élimine le déphasage entre les bandes de fréquences basses et moyennes supérieures à 300 Hz. La réponse des basses est améliorée sans compromettre la clarté vocale, et c\'est quelque chose de particulièrement utile lors de la lecture de musique à faible volume où les sons graves et haute fréquence sont plus difficiles à entendre.",
        /*pl*/ "Funkcja Phase Matching Bass Boost eliminuje przesunięcie fazowe między niskimi i średnimi pasmami częstotliwości powyżej 300 Hz. Reakcja basów jest wzmocniona bez pogarszania czystości głosu, co jest szczególnie przydatne podczas odtwarzania muzyki przy niskim poziomie głośności, gdzie basy i dźwięki o wysokiej częstotliwości są trudniejsze do usłyszenia."];
    static String get device_phase_matching_bass_help => l_device_phase_matching_bass_help[_language];

    static const List<String> l_device_sleep_time = [
        /*en*/ "Sleep Time",
        /*ru*/ "Таймер сна",
        /*de*/ "Ruhemodus-Zeit",
        /*fr*/ "Arrêt automatique",
        /*pl*/ "Wyłącznik czasowy"];
    static String get device_sleep_time => l_device_sleep_time[_language];

    static const List<String> l_device_sleep_time_minutes = [
        /*en*/ "min",
        /*ru*/ "мин",
        /*de*/ "min",
        /*fr*/ "min",
        /*pl*/ "min"];
    static String get device_sleep_time_minutes => l_device_sleep_time_minutes[_language];

    static const List<String> l_device_sleep_time_help = [
        /*en*/ "Allows the device to enter standby automatically when the specified time given in minutes elapses.",
        /*ru*/ "Позволяет устройству автоматически переходить в режим ожидания по истечении указанного времени (в минутах).",
        /*de*/ "Ermöglicht dem Gerät, automatisch in den Standby-Modus zu wechseln, wenn die in Minuten angegebene Zeit verstrichen ist.",
        /*fr*/ "Permet à l\'appareil de se mettre en veille automatiquement lorsque le temps spécifié en minutes s\'est écoulé. ",
        /*pl*/ "Umożliwia automatyczne przejście urządzenia w stan czuwania po upływie określonego czasu podanego w minutach."];
    static String get device_sleep_time_help => l_device_sleep_time_help[_language];

    static const List<String> l_device_google_cast_analytics = [
        /*en*/ "Google Cast analytics",
        /*ru*/ "Аналитика Google Cast",
        /*de*/ "Google Cast analytics",
        /*fr*/ "Google Cast analytics",
        /*pl*/ "Google Cast analytics"];
    static String get device_google_cast_analytics => l_device_google_cast_analytics[_language];

    static const List<String> l_device_google_cast_analytics_help = [
        /*en*/ "Controls the collection of marketing and analytics data when using Google Cast. To protect your privacy, keep this setting always Off.",
        /*ru*/ "Контролирует сбор маркетинговых и аналитических данных при использовании Google Cast. Чтобы защитить вашу конфиденциальность, держите этот параметр всегда выключенным.",
        /*de*/ "Steuert die Erfassung von Marketing- und Analysedaten bei der Verwendung von Google Cast. Um Ihre Privatsphäre zu schützen, lassen Sie diese Einstellung immer deaktiviert.",
        /*fr*/ "Contrôle la collecte de données marketing et d\'analyse lors de l\'utilisation de Google Cast. Pour protéger votre vie privée, gardez ce paramètre toujours désactivé.",
        /*pl*/ "Kontroluje gromadzenie danych marketingowych i analitycznych podczas korzystania z Google Cast. Aby chronić swoją prywatność, pozostaw to ustawienie zawsze wyłączone."];
    static String get device_google_cast_analytics_help => l_device_google_cast_analytics_help[_language];

    static const List<String> l_speaker_a_command_toggle = [
        /*en*/ "Sets speaker A switch wrap-around",
        /*ru*/ "Вкл/выкл динамик A",
        /*de*/ "Lautsprecher A umschalten",
        /*fr*/ "Sélecteur Sortie A",
        /*pl*/ "Przełącz głośnik A na kolejny"];
    static String get speaker_a_command_toggle => l_speaker_a_command_toggle[_language];

    static const List<String> l_speaker_b_command_toggle = [
        /*en*/ "Sets speaker B switch wrap-around",
        /*ru*/ "Вкл/выкл динамик B",
        /*de*/ "Lautsprecher B umschalten",
        /*fr*/ "Sélecteur Sortie B",
        /*pl*/ "Przełącz głośnik B na kolejny"];
    static String get speaker_b_command_toggle => l_speaker_b_command_toggle[_language];

    static const List<String> l_speaker_ab_command = [
        /*en*/ "Speaker A/B",
        /*ru*/ "Динамик A/B",
        /*de*/ "Lautsprecher A/B",
        /*fr*/ "Sortie A/B",
        /*pl*/ "Głośnik A/B"];
    static String get speaker_ab_command => l_speaker_ab_command[_language];

    static const List<String> l_speaker_ab_command_toggle = [
        /*en*/ "Toggle between speakers",
        /*ru*/ "Переключить динамик",
        /*de*/ "Zwischen Lautsprechern wechseln",
        /*fr*/ "Changement sortie",
        /*pl*/ "Przełącz pomiędzy głośnikami"];
    static String get speaker_ab_command_toggle => l_speaker_ab_command_toggle[_language];

    static const List<String> l_speaker_ab_command_ab_off = [
        /*en*/ "Both off",
        /*ru*/ "оба выкл",
        /*de*/ "Beide aus",
        /*fr*/ "Toutes éteintes",
        /*pl*/ "Oba wyłączone"];
    static String get speaker_ab_command_ab_off => l_speaker_ab_command_ab_off[_language];

    static const List<String> l_speaker_ab_command_ab_on = [
        /*en*/ "Both on",
        /*ru*/ "оба вкл",
        /*de*/ "Beide an",
        /*fr*/ "Toutes allumées",
        /*pl*/ "Oba włączone"];
    static String get speaker_ab_command_ab_on => l_speaker_ab_command_ab_on[_language];

    static const List<String> l_speaker_ab_command_a_only = [
        /*en*/ "A only",
        /*ru*/ "только A",
        /*de*/ "nur A",
        /*fr*/ "A seulement",
        /*pl*/ "Tylko A"];
    static String get speaker_ab_command_a_only => l_speaker_ab_command_a_only[_language];

    static const List<String> l_speaker_ab_command_b_only = [
        /*en*/ "B only",
        /*ru*/ "только B",
        /*de*/ "nur B",
        /*fr*/ "B seulement",
        /*pl*/ "Tylko B"];
    static String get speaker_ab_command_b_only => l_speaker_ab_command_b_only[_language];

    static const List<String> l_speaker_ab_command_help = [
        /*en*/ "Speaker A/B selection. Works for Main zone and Zone 2 only.",
        /*ru*/ "Выбор динамика A/B. Работает только для основной зоны и зоны 2.",
        /*de*/ "Lautsprecher A/B-Auswahl. Funktioniert nur für Hauptzone und Zone 2. ",
        /*fr*/ "Sélection du haut-parleur A/B. Fonctionne uniquement pour la zone principale et la zone 2.",
        /*pl*/ "Wybór głośnika A/B. Działa tylko w strefie głównej i strefie 2. "];
    static String get speaker_ab_command_help => l_speaker_ab_command_help[_language];

    static const List<String> l_device_late_night = [
        /*en*/ "Late night mode",
        /*ru*/ "Режим \"Late night\"",
        /*de*/ "Late-Night-Modus",
        /*fr*/ "Mode nocturne",
        /*pl*/ "Tryb późnej nocy"];
    static String get device_late_night => l_device_late_night[_language];

    static const List<String> l_device_late_night_none = [
        /*en*/ "N/A",
        /*ru*/ "N/A",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_late_night_none => l_device_late_night_none[_language];

    static const List<String> l_device_late_night_off = [
        /*en*/ "Off",
        /*ru*/ "Выкл",
        /*de*/ "Aus",
        /*fr*/ "Arrêt",
        /*pl*/ "Off"];
    static String get device_late_night_off => l_device_late_night_off[_language];

    static const List<String> l_device_late_night_low = [
        /*en*/ "Low",
        /*ru*/ "Низкий",
        /*de*/ "Niedrig",
        /*fr*/ "Faible",
        /*pl*/ "Niska"];
    static String get device_late_night_low => l_device_late_night_low[_language];

    static const List<String> l_device_late_night_high = [
        /*en*/ "High",
        /*ru*/ "Высокий",
        /*de*/ "Hoch",
        /*fr*/ "Haute",
        /*pl*/ "Wysoki"];
    static String get device_late_night_high => l_device_late_night_high[_language];

    static const List<String> l_device_late_night_auto = [
        /*en*/ "Auto",
        /*ru*/ "Авто",
        /*de*/ "Auto",
        /*fr*/ "Auto",
        /*pl*/ "Auto"];
    static String get device_late_night_auto => l_device_late_night_auto[_language];

    static const List<String> l_device_late_night_disabled = [
        /*en*/ "Disabled",
        /*ru*/ "Недоступен",
        /*de*/ "Deaktiviert",
        /*fr*/ "Handicapé",
        /*pl*/ "Wyłączone"];
    static String get device_late_night_disabled => l_device_late_night_disabled[_language];

    static const List<String> l_device_late_night_up = [
        /*en*/ "Sets late night state wrap-around",
        /*ru*/ "Изменить режим \"Late night\"",
        /*de*/ "Sets late night wechseln",
        /*fr*/ "Changer le mode de nuit",
        /*pl*/ "Zmień tryb późnej nocy"];
    static String get device_late_night_up => l_device_late_night_up[_language];

    static const List<String> l_device_late_night_help = [
        /*en*/ "Make small sounds easily heard. It is useful when you need to reduce the volume while watching a movie late night.",
        /*ru*/ "Выборочное усиление звуков низкой громкости. Это полезно, когда вам нужно уменьшить громкость во время просмотра фильма поздно вечером.",
        /*de*/ "Machen Sie kleine Geräusche leicht hörbar. Dies ist nützlich, wenn Sie die Lautstärke reduzieren müssen, während Sie sich spät abends einen Film ansehen.",
        /*fr*/ "Faites de petits sons facilement audibles. Il est utile lorsque vous devez réduire le volume tout en regardant un film tard dans la nuit.",
        /*pl*/ "Spraw, by małe dźwięki były łatwo słyszalne. Jest to przydatne, gdy chcesz zmniejszyć głośność podczas oglądania filmu późnym wieczorem."];
    static String get device_late_night_help => l_device_late_night_help[_language];

    static const List<String> l_device_network_standby = [
        /*en*/ "Network standby",
        /*ru*/ "Включение по сети",
        /*de*/ "Netzwerk-Standby",
        /*fr*/ "Veille réseau",
        /*pl*/ "Tryb gotowości sieciowej"];
    static String get device_network_standby => l_device_network_standby[_language];

    static const List<String> l_device_network_standby_help = [
        /*en*/ "When this function is set to \"On\", you can turn on the power of the unit via network using an application such as Enhanced Music Controller that can control this unit.",
        /*ru*/ "Если для этой функции установлено значение \"Вкл\", вы можете включить питание устройства по сети с помощью приложения, которое может управлять этим устройством (такого как Enhanced Music Controller).",
        /*de*/ "Wenn diese Funktion auf \"An\" geschaltet ist, können Sie dieses Gerät mit einer Anwendung wie Enhanced Music Controller über das Netzwerk einschalten.",
        /*fr*/ "Lorsque cette fonction est réglée sur \"Marche\", vous pouvez mettre sous tension l\'appareil via le réseau en utilisant une application telle que Enhanced Music Controller qui peut commander cet appareil.",
        /*pl*/ "Gdy ta funkcja jest ustawiona na \"On\", możesz włączyć zasilanie urządzenia przez sieć za pomocą aplikacji, takiej jak Enhanced Music Controller, która może sterować tym urządzeniem."];
    static String get device_network_standby_help => l_device_network_standby_help[_language];

    static const List<String> l_device_network_standby_confirm = [
        /*en*/ "With this setting to \"Off\" it is not possible to power ON the device via network using the app. Continue?",
        /*ru*/ "Если для этого параметра установлено значение \"Выкл\", вы не сможете включить устройство по сети с помощью приложения. Продолжать?",
        /*de*/ "Mit dieser Einstellung auf \"Aus\" kann das Gerät nicht über das Netzwerk mit der App eingeschaltet werden. Fortsetzen?",
        /*fr*/ "Avec ce paramètre sur \"Arrêt\", vous ne pourrez pas allumer l\'appareil via le réseau à l\'aide de l\'application. Continuer?",
        /*pl*/ "Przy tym ustawieniu na \"Off\" nie będzie można włączyć urządzenia przez sieć za pomocą aplikacji. Kontynuować?"];
    static String get device_network_standby_confirm => l_device_network_standby_confirm[_language];

    static const List<String> l_privacy_policy_onkyo = [
        /*en*/ "Agree Onkyo Privacy Policy",
        /*ru*/ "Подтвердить соглашение Onkyo Privacy",
        /*de*/ "Onkyo Datenschutzerklärung zustimmen",
        /*fr*/ "Agree Onkyo Privacy Policy",
        /*pl*/ "Agree Onkyo Privacy Policy"];
    static String get privacy_policy_onkyo => l_privacy_policy_onkyo[_language];

    static const List<String> l_privacy_policy_google = [
        /*en*/ "Agree Google Cast License",
        /*ru*/ "Подтвердить лицензию Google Cast",
        /*de*/ "Google Cast Lizenz zustimmen",
        /*fr*/ "Agree Google Cast License",
        /*pl*/ "Agree Google Cast License"];
    static String get privacy_policy_google => l_privacy_policy_google[_language];

    static const List<String> l_privacy_policy_sue = [
        /*en*/ "Agree SUE - Privacy Policy",
        /*ru*/ "Подтвердить соглашение SUE-Privacy",
        /*de*/ "SUE - Datenschutzerklärung zustimmen",
        /*fr*/ "Agree SUE - Privacy Policy",
        /*pl*/ "Agree SUE - Privacy Policy"];
    static String get privacy_policy_sue => l_privacy_policy_sue[_language];

    static const List<String> l_device_dcp_eco_mode = [
        /*en*/ "ECO Mode",
        /*ru*/ "Режим экономии",
        /*de*/ "Energiesparmodus",
        /*fr*/ "Mode écologique",
        /*pl*/ "Tryb ekologiczny"];
    static String get device_dcp_eco_mode => l_device_dcp_eco_mode[_language];

    static const List<String> l_device_dcp_eco_mode_help = [
        /*en*/ "This mode can reduce the power consumption and heat generation of this unit when power on. This is done by reducing the power supply line to the power amplifier, in turn the maximum power output.",
        /*ru*/ "Этот режим может снизить потребляемую мощность и выделение тепла устройства при включенном питании. Это достигается уменьшением линии источника питания до усилителя мощности последовательно с максимальной выходной мощностью.",
        /*de*/ "Dieser Modus kann die Leistungsaufnahme und Wärmeentwicklung dieses Geräts in eingeschaltetem Zustand verringern. Dies wird durch die Drosselung der Stromversorgung an den Leistungsverstärker bei maximaler Leistungsabgabe erreicht.",
        /*fr*/ "Ce mode peut réduire la consommation d\'énergie et la production de chaleur de cet appareil lorsqu\'il est sous tension. Ceci est obtenu en réduisant la ligne d\'alimentation de l\'amplificateur de puissance, et par conséquent la puissance maximale de sortie.",
        /*pl*/ "Ten tryb może zmniejszyć pobór mocy i wytwarzanie ciepła tego urządzenia przy włączonym zasilaniu. Odbywa się to poprzez redukcję zasilania do wzmacniacza mocy, przy jednoczesnej maksymalnej mocy wyjściowej."];
    static String get device_dcp_eco_mode_help => l_device_dcp_eco_mode_help[_language];

    static const List<String> l_device_dcp_audio_restorer = [
        /*en*/ "Audio Restorer",
        /*ru*/ "Режим \"Restorer\"",
        /*de*/ "Audio Restorer",
        /*fr*/ "Audio Restorer",
        /*pl*/ "Audio Restorer"];
    static String get device_dcp_audio_restorer => l_device_dcp_audio_restorer[_language];

    static const List<String> l_device_dcp_audio_restorer_help = [
        /*en*/ "Compressed audio formats such as MP3, WMA (Windows Media Audio) and MPEG-4 AAC reduce the amount of data by eliminating signal components that are hard for the human ear to hear. The \"Restorer\" function generates the signals eliminated upon compression, restoring the sound to conditions near those of the original sound before compression. It also restores the original bass characteristics for a rich and expanded tonal range.",
        /*ru*/ "Форматы сжатого звука, например, MP3, WMA (Windows Media Audio) и MPEG-4 AAC сокращают объем данных путем устранения компонентов сигнала, которые с трудом воспринимаются человеческим слухом. Режим \"Restorer\" генерирует сигналы, удаленные при компрессии, восстанавливая состояние звукового сигнала, близкое к состоянию исходного звукового сигнала перед сжатием. Он также восстанавливает исходные характеристики басов для насыщенного и расширенного тонального диапазона.",
        /*de*/ "Komprimierte Audioformate wie z. B. MP3, WMA (Windows Media Audio) und MPEG-4 AAC reduzieren den Datenumfang, indem Signalkomponenten ausgelassen werden, die für das menschliche Ohr kaum wahrnehmbar sind. Die \"Restorer\"-Funktion stellt die Signale, die bei der Komprimierung gelöscht wurden, wieder her, sodass der Klang dem ursprünglichen Klang vor der Komprimierung sehr nahe kommt. Außerdem werden die ursprünglichen Basseigenschaften wiederhergestellt, sodass sich ein reicher und breiter Tonumfang ergibt.",
        /*fr*/ "Les formats audio compressés, tels que MP3, WMA (Windows Media Audio) et MPEG-4 AAC réduisent la quantité de données en éliminant des composants du signal difficilement audibles pour l\'oreille humaine. La fonction \"Restorer\" génère les signaux éliminés pendant la compression pour restaurer le son le plus proche de celui d\'origine. Elle restaure également les caractéristiques des basses d\'origine pour une plage tonale riche et étendue.",
        /*pl*/ "Skompresowane formaty audio jak MP3, WMA (Windows Media Audio) oraz MPEG-4 AAC redukują ilość danych poprzez eliminację składowych sygnału w zakresie trudnym do rozpoznawania przez ucho człowieka. Funkcja \"Restorer\" generuje sygnał eliminowany w trakcie kompresji, przywracając sygnałowi brzmienie zbliżone do sygnału oryginalnego. Przywracana jest również oryginalna charakterystyka niskich tonów, pozwalająca uzyskać bogaty i szeroki zakres tonalny."];
    static String get device_dcp_audio_restorer_help => l_device_dcp_audio_restorer_help[_language];

    static const List<String> l_device_dcp_audio_restorer_none = [
        /*en*/ "N/A",
        /*ru*/ "N/A",
        /*de*/ "N/A",
        /*fr*/ "N/A",
        /*pl*/ "N/A"];
    static String get device_dcp_audio_restorer_none => l_device_dcp_audio_restorer_none[_language];

    static const List<String> l_device_dcp_audio_restorer_off = [
        /*en*/ "Off",
        /*ru*/ "Выкл",
        /*de*/ "Aus",
        /*fr*/ "Arrêt",
        /*pl*/ "Off"];
    static String get device_dcp_audio_restorer_off => l_device_dcp_audio_restorer_off[_language];

    static const List<String> l_device_dcp_audio_restorer_low = [
        /*en*/ "Low",
        /*ru*/ "Низкий",
        /*de*/ "Niedrig",
        /*fr*/ "Faible",
        /*pl*/ "Niska"];
    static String get device_dcp_audio_restorer_low => l_device_dcp_audio_restorer_low[_language];

    static const List<String> l_device_dcp_audio_restorer_medium = [
        /*en*/ "Medium",
        /*ru*/ "Средний",
        /*de*/ "Mittel",
        /*fr*/ "Moyen",
        /*pl*/ "Średni"];
    static String get device_dcp_audio_restorer_medium => l_device_dcp_audio_restorer_medium[_language];

    static const List<String> l_device_dcp_audio_restorer_high = [
        /*en*/ "High",
        /*ru*/ "Высокий",
        /*de*/ "Hoch",
        /*fr*/ "Haute",
        /*pl*/ "Wysoki"];
    static String get device_dcp_audio_restorer_high => l_device_dcp_audio_restorer_high[_language];

    static const List<String> l_listening_mode_up = [
        /*en*/ "Sets listening mode wrap-around up",
        /*ru*/ "Следующий звуковой профиль",
        /*de*/ "Klangprofile durchwechseln",
        /*fr*/ "Changer mode d\'écoute",
        /*pl*/ "Zmień tryb na następny"];
    static String get listening_mode_up => l_listening_mode_up[_language];

    static const List<String> l_listening_mode_down = [
        /*en*/ "Sets listening mode wrap-around down",
        /*ru*/ "Предыдущий звуковой профиль",
        /*de*/ "Klangprofile durchwechseln",
        /*fr*/ "Changer mode d\'écoute",
        /*pl*/ "Zmień tryb na poprzedni"];
    static String get listening_mode_down => l_listening_mode_down[_language];

    static const List<String> l_remote_interface_power = [
        /*en*/ "Power",
        /*ru*/ "Питание",
        /*de*/ "An/Aus",
        /*fr*/ "Marche",
        /*pl*/ "Zasilanie"];
    static String get remote_interface_power => l_remote_interface_power[_language];

    static const List<String> l_remote_interface_common = [
        /*en*/ "Common",
        /*ru*/ "Общий",
        /*de*/ "Common",
        /*fr*/ "Commun",
        /*pl*/ "Wspólne"];
    static String get remote_interface_common => l_remote_interface_common[_language];

    static const List<String> l_remote_interface_input = [
        /*en*/ "Input",
        /*ru*/ "Вход",
        /*de*/ "Eingang",
        /*fr*/ "Entrée",
        /*pl*/ "Wejście"];
    static String get remote_interface_input => l_remote_interface_input[_language];

    static const List<String> l_remote_interface_volume = [
        /*en*/ "Volume",
        /*ru*/ "Громкость",
        /*de*/ "Lautstärke",
        /*fr*/ "Volume",
        /*pl*/ "Głośność"];
    static String get remote_interface_volume => l_remote_interface_volume[_language];

    static const List<String> l_remote_interface_playback = [
        /*en*/ "Playback",
        /*ru*/ "Воспроизведение",
        /*de*/ "Abspieler",
        /*fr*/ "Lecture",
        /*pl*/ "Odtwarzanie"];
    static String get remote_interface_playback => l_remote_interface_playback[_language];

    static const List<String> l_cmd_multiroom_group = [
        /*en*/ "Group/Ungroup devices",
        /*ru*/ "Сгруппировать/Разгруппировать",
        /*de*/ "Gruppieren/Aufheben",
        /*fr*/ "Grouper/dégrouper dispositifs",
        /*pl*/ "Grupuj/Rozgrupuj urządzenia"];
    static String get cmd_multiroom_group => l_cmd_multiroom_group[_language];

    static const List<String> l_cmd_multiroom_channel = [
        /*en*/ "Change speaker channel",
        /*ru*/ "Изменить канал колонок",
        /*de*/ "Lautsprecherkanal ändern",
        /*fr*/ "Changer le canal",
        /*pl*/ "Zmiana kanału głośnika"];
    static String get cmd_multiroom_channel => l_cmd_multiroom_channel[_language];

    static const List<String> l_multiroom_group = [
        /*en*/ "Group",
        /*ru*/ "Группа",
        /*de*/ "Gruppe",
        /*fr*/ "Grouper",
        /*pl*/ "Grupa"];
    static String get multiroom_group => l_multiroom_group[_language];

    static const List<String> l_multiroom_master = [
        /*en*/ "Master",
        /*ru*/ "Ведущий",
        /*de*/ "Master",
        /*fr*/ "Maître",
        /*pl*/ "Master"];
    static String get multiroom_master => l_multiroom_master[_language];

    static const List<String> l_multiroom_slave = [
        /*en*/ "Slave",
        /*ru*/ "Ведомый",
        /*de*/ "Slave",
        /*fr*/ "Esclave",
        /*pl*/ "Slave"];
    static String get multiroom_slave => l_multiroom_slave[_language];

    static const List<String> l_multiroom_none = [
        /*en*/ "Not attached",
        /*ru*/ "Не связан",
        /*de*/ "Nicht verbunden",
        /*fr*/ "Pas connecté",
        /*pl*/ "Nie dołączone"];
    static String get multiroom_none => l_multiroom_none[_language];

    static const List<String> l_multiroom_channel = [
        /*en*/ "Channel",
        /*ru*/ "Канал",
        /*de*/ "Kanal",
        /*fr*/ "Canal",
        /*pl*/ "Kanał"];
    static String get multiroom_channel => l_multiroom_channel[_language];

    static const List<String> l_av_info_dialog = [
        /*en*/ "Audio/Video info",
        /*ru*/ "Параметры аудио/видео",
        /*de*/ "Audio/Video Information",
        /*fr*/ "Audio/Video information",
        /*pl*/ "Audio/Video Informacja"];
    static String get av_info_dialog => l_av_info_dialog[_language];

    static const List<String> l_av_info_audio = [
        /*en*/ "Audio",
        /*ru*/ "Аудио",
        /*de*/ "Audio",
        /*fr*/ "Audio",
        /*pl*/ "Audio"];
    static String get av_info_audio => l_av_info_audio[_language];

    static const List<String> l_av_info_video = [
        /*en*/ "Video",
        /*ru*/ "Видео",
        /*de*/ "Video",
        /*fr*/ "Vidéo",
        /*pl*/ "Video"];
    static String get av_info_video => l_av_info_video[_language];

    static const List<String> l_av_info_input = [
        /*en*/ "Input: %s",
        /*ru*/ "Вход: %s",
        /*de*/ "Eingang: %s",
        /*fr*/ "Entrée: %s",
        /*pl*/ "Wejście: %s"];
    static String get av_info_input => l_av_info_input[_language];

    static const List<String> l_av_info_output = [
        /*en*/ "Output: %s",
        /*ru*/ "Выход: %s",
        /*de*/ "Ausgang: %s",
        /*fr*/ "Sortie: %s",
        /*pl*/ "Wyjście: %s"];
    static String get av_info_output => l_av_info_output[_language];

    static const List<String> l_error_invalid_device_address = [
        /*en*/ "Invalid device name or port",
        /*ru*/ "Неправильный адрес устройства или порт",
        /*de*/ "Ungültiger Gerätename oder Port",
        /*fr*/ "Nom ou port du dispositif invalide",
        /*pl*/ "Nieprawidłowa nazwa urządzenia lub port"];
    static String get error_invalid_device_address => l_error_invalid_device_address[_language];

    static const List<String> l_error_connection_no_network = [
        /*en*/ "No connection to the network",
        /*ru*/ "Нет соединения с сетью",
        /*de*/ "Keine Verbindung zum Netzwerk",
        /*fr*/ "Pas de connexion réseau",
        /*pl*/ "Brak połączenia z siecią"];
    static String get error_connection_no_network => l_error_connection_no_network[_language];

    static const List<String> l_error_connection_no_wifi = [
        /*en*/ "No connection to Wi-Fi. Please input remote device IP and port manually",
        /*ru*/ "Нет подключения к Wi-Fi. Введите адрес и порт устройства вручную",
        /*de*/ "Keine WLAN Verbindung, bitte IP und Port manuell eingeben",
        /*fr*/ "Pas de connexion Wi-Fi. Merci d\'entrer l\'IP et port du dispositif manuellement",
        /*pl*/ "Brak połączenia z Wi-Fi. Wprowadź ręcznie adres IP i port urządzenia zdalnego"];
    static String get error_connection_no_wifi => l_error_connection_no_wifi[_language];

    static const List<String> l_error_connection_no_response = [
        /*en*/ "Remote device %s not responding",
        /*ru*/ "Устойство %s не отвечает",
        /*de*/ "Remote-Gerät %s antwortet nicht",
        /*fr*/ "Dispositif distant %s ne répond pas",
        /*pl*/ "Urządzenie zdalne %s nie odpowiada"];
    static String get error_connection_no_response => l_error_connection_no_response[_language];

    /* Translatable arrays */

    static const List<List<String>> l_pref_cover_click_names = [
        /*en*/ ["None",
                "Display mode on device",
                "Audio muting"],
        /*ru*/ ["Нет действия",
                "Режим отображения на дисплее устройства",
                "Отключение звука"],
        /*de*/ ["Kein",
                "Anzeigemodus am Gerät",
                "Stummschalten des Tons"],
        /*fr*/ ["Aucun",
                "Mode affichage sur le dispositif",
                "Coupure du son"],
        /*pl*/ ["Nic",
                "Tryb wyświetlania na urządzeniu",
                "Wyciszenie dźwięku"]];
    static List<String> get pref_cover_click_names => l_pref_cover_click_names[_language];

    static const List<List<String>> l_pref_sound_control_names = [
        /*en*/ ["None",
                "External amplifier (RI)",
                "Device (Buttons)",
                "Device (Slider)",
                "Device (Buttons around Slider)",
                "Device (Buttons above Slider)",
                "Automatic"],
        /*ru*/ ["Нет",
                "Внешний усилитель (RI)",
                "Устройство (Кнопки)",
                "Устройство (Слайдер)",
                "Устройство (Слайдер между кнопками)",
                "Устройство (Кнопки над слайдером)",
                "Выбрать автоматически"],
        /*de*/ ["Keine",
                "Externer Verstärker (RI)",
                "Gerät (Tasten)",
                "Gerät (Slider)",
                "Gerät (Tasten rund um den Slider)",
                "Gerät (Tasten über den Slider)",
                "Automatisch"],
        /*fr*/ ["Aucun",
                "Amplificateur Externe (RI)",
                "Dispositif (Boutons)",
                "Dispositif (Glissière)",
                "Dispositif (Boutons autour du Glissière)",
                "Dispositif (Boutons au-dessus du Glissière)",
                "Automatique"],
        /*pl*/ ["Brak",
                "Wzmacniacz zewnętrzny (RI)",
                "Urządzenie (Przyciski)",
                "Urządzenie (Suwak)",
                "Urządzenie (Przyciski wokół Slidera)",
                "Urządzenie (Przyciski nad Sliderem)",
                "Automatyczna"]];
    static List<String> get pref_sound_control_names => l_pref_sound_control_names[_language];

    static const List<List<String>> l_pref_theme_names = [
        /*en*/ ["Strong Dark (Black and Lime)",
                "Dark (Dim Gray and Cyan)",
                "Dark (Dim Gray and Yellow)",
                "Light (Gray and Deep Purple)",
                "Light (Indigo and Orange)",
                "Light (Teal and Deep Orange)",
                "Light (Purple and Green)"],
        /*ru*/ ["Контрастная темная (черно-желтая)",
                "Темная (серая и сине-зеленая)",
                "Темная (серо-желтая)",
                "Светлая (серая и темно-фиолетовая)",
                "Светлая (темно-синяя и оранжевая)",
                "Светлая (зеленовато-голубая и темно-оранжевая)",
                "Светлая (фиолетовая и темно-зеленая)"],
        /*de*/ ["OLED (Schwarz und Limette)",
                "Dunkel (Dunkelgrau und Blau)",
                "Dunkel (Dunkelgrau und Gelb)",
                "Hell (Grau und Lila)",
                "Hell (Indigo und Orange)",
                "Hell (Türkis und sattes Orange)",
                "Hell (Lila und Grün)"],
        /*fr*/ ["Très sombre (Noir et jaune)",
                "Sombre (Gris et bleu)",
                "Sombre (Gris et orange)",
                "Clair (Gris et violet)",
                "Clair (Bleu et orange)",
                "Clair (Émeraude et magenta)",
                "Clair (Violet et vert)"],
        /*pl*/ ["Strong Dark (Czarny i limonkowy)",
                "Dark (Ciemnoszary i cyjan)",
                "Dark (Ciemnoszary i żółty)",
                "Light (Szary i głęboki fiolet)",
                "Light (Indygo i pomarańczowy)",
                "Light (Morski i głęboki pomarańczowy)",
                "Light (Fioletowy i zielony)"]];
    static List<String> get pref_theme_names => l_pref_theme_names[_language];

    static const List<List<String>> l_pref_language_names = [
        /*en*/ ["System language",
                "English",
                "Français",
                "Русский",
                "Deutsch",
                "Polski"],
        /*ru*/ ["Системный язык",
                "English",
                "Français",
                "Русский",
                "Deutsch",
                "Polski"],
        /*de*/ ["Systemsprache",
                "English",
                "Français",
                "Русский",
                "Deutsch",
                "Polski"],
        /*fr*/ ["Langue système",
                "English",
                "Français",
                "Русский",
                "Deutsch",
                "Polski"],
        /*pl*/ ["System language",
                "English",
                "Français",
                "Русский",
                "Deutsch",
                "Polski"]];
    static List<String> get pref_language_names => l_pref_language_names[_language];

    static const List<List<String>> l_pref_text_size_names = [
        /*en*/ ["Small",
                "Normal",
                "Big",
                "Huge"],
        /*ru*/ ["Маленький",
                "Нормальный",
                "Большой",
                "Огромный"],
        /*de*/ ["Klein",
                "Normal",
                "Groß",
                "Riesig"],
        /*fr*/ ["Petit",
                "Normal",
                "Grand",
                "Énorme"],
        /*pl*/ ["Małe",
                "Normalne",
                "Duże",
                "Ogromne"]];
    static List<String> get pref_text_size_names => l_pref_text_size_names[_language];

    static const List<List<String>> l_pref_visible_tabs_names = [
        /*en*/ ["Listen",
                "Media",
                "Shortcuts",
                "Device",
                "RC",
                "RI"],
        /*ru*/ ["Музыка",
                "Каналы",
                "Ярлыки",
                "Система",
                "Пульт",
                "RI"],
        /*de*/ ["Hören",
                "Medien",
                "Favoriten",
                "Gerät",
                "RC",
                "RI"],
        /*fr*/ ["Écoute",
                "Source",
                "Raccourcis",
                "Appareil",
                "RC",
                "RI"],
        /*pl*/ ["Słuchaj",
                "Media",
                "Skróty",
                "Urządzenie",
                "RC",
                "RI"]];
    static List<String> get pref_visible_tabs_names => l_pref_visible_tabs_names[_language];
}
