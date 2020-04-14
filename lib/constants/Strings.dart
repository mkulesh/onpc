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
    static const String pref_sound_control_default = "device";
    static const String pref_theme_default = "indigo-orange";
    static const String pref_language_default = "system";
    static const String pref_text_size_default = "normal";

    /* Non-translatable arrays */

    static const List<String> pref_sound_control_codes = [
        "none",
        "external-amplifier",
        "device",
        "device-slider",
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
        /*en*/ "Enhanced Controller for Onkyo and Pioneer",
        /*ru*/ "Enhanced Controller for Onkyo and Pioneer",
        /*de*/ "Erweiterte Bedienung für Onkyo und Pioneer",
        /*fr*/ "Contrôleur optimisé pour Onkyo et Pioneer",
        /*pl*/ "Ulepszony kontroler do urządzeń Onkyo i Pioneer"];
    static String get app_name => l_app_name[_language];

    static const List<String> l_app_short_name = [
        /*en*/ "Music Control",
        /*ru*/ "Music Control",
        /*de*/ "Musik Kontrolle",
        /*fr*/ "Music Control",
        /*pl*/ "Music Control"];
    static String get app_short_name => l_app_short_name[_language];

    static const List<String> l_app_description = [
        /*en*/ "Enhanced controller for Onkyo/Pioneer devices: listen to music properly!",
        /*ru*/ "Управляй музыкой на устройствах Onkyo/Pioneer одним кликом!",
        /*de*/ "Verbesserte Fernsteuerung für Onkyo/Pioneer Geräte: Musik richtig hören!",
        /*fr*/ "Contrôleur optimisé pour Onkyo/Pioneer: Ecoutez votre musique correctement!",
        /*pl*/ "Ulepszony kontroler do urządzeń Onkyo i Pioneer: słuchaj muzyki poprawnie!"];
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
        /*fr*/ "Eteint",
        /*pl*/ "Standby"];
    static String get state_standby => l_state_standby[_language];

    static const List<String> l_action_exit_confirm = [
        /*en*/ "Press back button again to exit",
        /*ru*/ "Для выхода нажмите Назад дважды",
        /*de*/ "Zum Beenden zurück erneut drücken",
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

    static const List<String> l_action_cancel = [
        /*en*/ "Cancel",
        /*ru*/ "Отмена",
        /*de*/ "Abbrechen",
        /*fr*/ "Annuler",
        /*pl*/ "Wstecz"];
    static String get action_cancel => l_action_cancel[_language];

    static const List<String> l_about_text = [
        /*en*/ """
# Enhanced Controller for Onkyo and Pioneer
Listen to music properly!

Copyright © 2019 by __Mikhail Kulesh__

This app allows remote control of an Onkyo/Pioneer/Integra Network Player or a Network A/V Receiver via the "Integra Serial Communication Protocol". Its two most popular features are music playback and sound profile management.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Links

Public repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

## Used Open Source Libraries

* Material Design Icons: [http://materialdesignicons.com](http://materialdesignicons.com)
* Material Design Palette: [https://www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [https://flutter.dev](https://flutter.dev)
* Flutter packages: [https://pub.dev/packages](https://pub.dev/packages)

Enjoy!""",
        /*ru*/ """
# Enhanced Controller for Onkyo and Pioneer
Управляй музыкой на устройствах Onkyo/Pioneer одним кликом!

Copyright © 2019 by __Михаил Кулеш__

Данная программа позволяет удаленно управлять сетевыми плеерами или ресиверами Onkyo/Pioneer/Integra по локальной сети, используя сетевой протокол "Integra Serial Communication Protocol". Основное предназначение программы - управление воспроизведением и звуковыми профилями.

## Лицензия

Данная программа является свободным программным обеспечением. Вы вправе распространять ее и/или модифицировать в соответствии с условиями версии 3 либо по вашему выбору с условиями более поздней версии Стандартной Общественной Лицензии GNU, опубликованной Free Software Foundation.

Мы распространяем данную программу в надежде на то, что она будет вам полезной, однако НЕ ПРЕДОСТАВЛЯЕМ НА НЕЕ НИКАКИХ ГАРАНТИЙ, в том числе ГАРАНТИИ ТОВАРНОГО СОСТОЯНИЯ ПРИ ПРОДАЖЕ и ПРИГОДНОСТИ ДЛЯ ИСПОЛЬЗОВАНИЯ В КОНКРЕТНЫХ ЦЕЛЯХ. Для получения более подробной информации ознакомьтесь со Стандартной Общественной Лицензией GNU.

Вместе с данной программой вы должны были получить экземпляр [Стандартной Общественной Лицензии GNU](https://www.gnu.org/licenses)

## Ссылки

Репозиторий с исходным кодом: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

## Библиотеки с открытым исходным кодом

* Material Design Icons: [http://materialdesignicons.com](http://materialdesignicons.com)
* Material Design Palette: [https://www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [https://flutter.dev](https://flutter.dev)
* Flutter packages: [https://pub.dev/packages](https://pub.dev/packages)""",
        /*de*/ """
# Erweiterte Bedienung für Onkyo und Pioneer
Verbesserte Fernsteuerung für Onkyo/Pioneer Geräte: Musik richtig hören!

Copyright © 2019 by __Mikhail Kulesh__

Diese App steuert Onkyo/Pioneer/Integra Netzwerk Abspielgeräte und A/V Receiver über das "Integra Serial Communication Protocol". Die beiden beliebtesten Funktionen sind Abspielsteuerung und Klangprofil Auswahl.

## Lizenz

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Links

Öffentliches repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

## Genutzte Open Source Bibliotheken

* Material Design Icons: [http://materialdesignicons.com](http://materialdesignicons.com)
* Material Design Palette: [https://www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [https://flutter.dev](https://flutter.dev)
* Flutter packages: [https://pub.dev/packages](https://pub.dev/packages)""",
        /*fr*/ """
# Contrôleur optimisé pour Onkyo/Pioneer:
Ecoutez votre musique correctement!

Copyright © 2018-2019 by __Mikhail Kulesh__

Cette appli permet le contrôle à distance d\'équipement audio connectée Onkyo/Pioneer/Integra Network Player ou des receivers A/V réseau via "Integra Serial Communication Protocol". Ses deux principales fonctions sont la commande de la musique et la gestion des profils audios.

## License

Ce programme est à usage gratuit: vous pouvez le distribuer et/ou le modifier celon les termes de GNU La "General Public License" telle que publiée par le "Free Software Foundation", sous la version 3 de la licence ou (à votre choix) toute version posterieure.

Ce programme est publié dans l\'espoir qu\'il soit utile, mais SANS GARANTIE; sans même la garantie implicite d\'une QUALITE MARCHANDE ou sa FIABILITE POUR UN USAGE QUELCONQUE. Voir GNU General Public License pour plus d\'information. Vous devez avoir reçu une copie de la GNU General Public License avec ce programme.

## Links

Public repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

## Used Open Source Libraries

* Material Design Icons: [http://materialdesignicons.com](http://materialdesignicons.com)
* Material Design Palette: [https://www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [https://flutter.dev](https://flutter.dev)
* Flutter packages: [https://pub.dev/packages](https://pub.dev/packages)
""",
        /*pl*/ """
# Enhanced Controller for Onkyo and Pioneer
Listen to music properly!

Copyright © 2019 by __Mikhail Kulesh__

This app allows remote control of an Onkyo/Pioneer/Integra Network Player or a Network A/V Receiver via the "Integra Serial Communication Protocol". Its two most popular features are music playback and sound profile management.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Links

Public repository: [github.com/mkulesh/onpc](https://github.com/mkulesh/onpc)

## Used Open Source Libraries

* Material Design Icons: [http://materialdesignicons.com](http://materialdesignicons.com)
* Material Design Palette: [https://www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [https://flutter.dev](https://flutter.dev)
* Flutter packages: [https://pub.dev/packages](https://pub.dev/packages)

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
        /*fr*/ "Equipement",
        /*pl*/ "Urządzenie"];
    static String get drawer_device => l_drawer_device[_language];

    static const List<String> l_drawer_device_connect = [
        /*en*/ "Connect",
        /*ru*/ "Соединение",
        /*de*/ "Verbinden",
        /*fr*/ "Conencter",
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

    static const List<String> l_drawer_device_application = [
        /*en*/ "Application",
        /*ru*/ "Приложение",
        /*de*/ "Anwendung",
        /*fr*/ "Application",
        /*pl*/ "Aplikacja"];
    static String get drawer_device_application => l_drawer_device_application[_language];

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
        /*fr*/ "A propos",
        /*pl*/ "Info"];
    static String get drawer_about => l_drawer_about[_language];

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
        /*fr*/ "Port (optionel)",
        /*pl*/ "Port (opcjonalnie)"];
    static String get connect_dialog_port => l_connect_dialog_port[_language];

    static const List<String> l_menu_power_power = [
        /*en*/ "On/Standby",
        /*ru*/ "Вкл/выкл",
        /*de*/ "An/Standby",
        /*fr*/ "marche/arrêt",
        /*pl*/ "On/Standby"];
    static String get menu_power_power => l_menu_power_power[_language];

    static const List<String> l_menu_receiver_information = [
        /*en*/ "Receiver information",
        /*ru*/ "Информация об устройстве",
        /*de*/ "Receiver Informationen",
        /*fr*/ "Information du récépteur",
        /*pl*/ "Informacje o urządzeniu"];
    static String get menu_receiver_information => l_menu_receiver_information[_language];

    static const List<String> l_menu_latest_logging = [
        /*en*/ "Latest logging",
        /*ru*/ "Лог приложения",
        /*de*/ "Letzte Log",
        /*fr*/ "Dernière entrée",
        /*pl*/ "Ostatnie logowanie"];
    static String get menu_latest_logging => l_menu_latest_logging[_language];

    static const List<String> l_title_monitor = [
        /*en*/ "Listen",
        /*ru*/ "Музыка",
        /*de*/ "Hören",
        /*fr*/ "Ecoute",
        /*pl*/ "Słuchaj"];
    static String get title_monitor => l_title_monitor[_language];

    static const List<String> l_title_media = [
        /*en*/ "Media",
        /*ru*/ "Каналы",
        /*de*/ "Medien",
        /*fr*/ "Source",
        /*pl*/ "Media"];
    static String get title_media => l_title_media[_language];

    static const List<String> l_title_device = [
        /*en*/ "Device",
        /*ru*/ "Система",
        /*de*/ "Gerät",
        /*fr*/ "Device",
        /*pl*/ "Urządzenie"];
    static String get title_device => l_title_device[_language];

    static const List<String> l_title_remote_control = [
        /*en*/ "RC",
        /*ru*/ "Пульт",
        /*de*/ "RC",
        /*fr*/ "RC",
        /*pl*/ "RC"];
    static String get title_remote_control => l_title_remote_control[_language];

    static const List<String> l_title_remote_interface = [
        /*en*/ "RI",
        /*ru*/ "RI",
        /*de*/ "RI",
        /*fr*/ "RI",
        /*pl*/ "RI"];
    static String get title_remote_interface => l_title_remote_interface[_language];

    static const List<String> l_pref_category_device_options = [
        /*en*/ "Device options",
        /*ru*/ "Настройки устройства",
        /*de*/ "Gerät Optionen",
        /*fr*/ "Options dispositif",
        /*pl*/ "Opcje urządzenia"];
    static String get pref_category_device_options => l_pref_category_device_options[_language];

    static const List<String> l_pref_category_ri_options = [
        /*en*/ "Remote interface",
        /*ru*/ "Удаленный интерфейс (RI)",
        /*de*/ "Remote interface",
        /*fr*/ "Contrôl interface",
        /*pl*/ "Kontrola zdalna"];
    static String get pref_category_ri_options => l_pref_category_ri_options[_language];

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
        /*de*/ "Lautstärketasten weiterleiten",
        /*fr*/ "Boutons volume",
        /*pl*/ "Przyciski głośności"];
    static String get pref_volume_title => l_pref_volume_title[_language];

    static const List<String> l_pref_volume_summary = [
        /*en*/ "Use volume keys to change master volume on remote device",
        /*ru*/ "Используйте кнопки управления громкостью для изменения уровня звука на удаленном устройстве",
        /*de*/ "Lautstärketasten verwenden um master Lautstärke zu ändern",
        /*fr*/ "Utilise les boutons volume pour modifier le volume de l\'appareil connecté",
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
        /*de*/ "Zurück-Taste verwenden um in Medien übergeordneter Ordner zu wählen",
        /*fr*/ "Utilise le bouton Retour pour remonter au niveau parent de la liste des médias",
        /*pl*/ "Użyj przycisku Wstecz, aby przełączyć na poziom nadrzędny na liście multimediów"];
    static String get pref_back_as_return_summary => l_pref_back_as_return_summary[_language];

    static const List<String> l_pref_advanced_queue = [
        /*en*/ "Advanced play queue options",
        /*ru*/ "Расширенные возможности Play Queue",
        /*de*/ "Erweiterte Optionen von Play Queue",
        /*fr*/ "Files d\'attentes avancée",
        /*pl*/ "Zaawansowane opcje kolejki odtwarzania"];
    static String get pref_advanced_queue => l_pref_advanced_queue[_language];

    static const List<String> l_pref_advanced_queue_summary = [
        /*en*/ "Experimental: use advanced play queue features",
        /*ru*/ "Использовать экспериментальные возможности очереди воспроизведения",
        /*de*/ "Experimentell: fortgeschrittene Funktionen in Play Queue verwenden",
        /*fr*/ "Experimentale: gestion évoluée des files d\'attentes",
        /*pl*/ "Eksperymentalna: Korzystaj z zaawansowanych funkcji kolejki odtwarzania"];
    static String get pref_advanced_queue_summary => l_pref_advanced_queue_summary[_language];

    static const List<String> l_pref_keep_playback_mode = [
        /*en*/ "Keep playback mode",
        /*ru*/ "Режим воспроизведения",
        /*de*/ "Abspielmodus behalten",
        /*fr*/ "Maintenir le mode lécture",
        /*pl*/ "Zachowaj tryb odtwarzania"];
    static String get pref_keep_playback_mode => l_pref_keep_playback_mode[_language];

    static const List<String> l_pref_keep_playback_mode_summary = [
        /*en*/ "Always keep playback mode in MEDIA tab while playing",
        /*ru*/ "Во вкладке КАНАЛЫ всегда оставаться в режиме воспроизведения.",
        /*de*/ "Während die Wiedergabe aktiv ist, Abspielmodus in MEDIEN behalten",
        /*fr*/ "Toujours conserver le mode lécture dans l\'onglet SOURCE quand l\'écoute est en cours",
        /*pl*/ "Zawsze zachowuj tryb odtwarzania na karcie MEDIA podczas odtwarzania"];
    static String get pref_keep_playback_mode_summary => l_pref_keep_playback_mode_summary[_language];

    static const List<String> l_pref_exit_confirm = [
        /*en*/ "Press back button twice for exit",
        /*ru*/ "Для выхода нажмите Назад дважды",
        /*de*/ "Zweimal zurück zum beenden",
        /*fr*/ "Bouton retour deux fois pour quitter",
        /*pl*/ "Naciśnij dwukrotnie przycisk Wstecz, aby wyjść"];
    static String get pref_exit_confirm => l_pref_exit_confirm[_language];

    static const List<String> l_pref_keep_screen_on = [
        /*en*/ "Keep the screen turned on",
        /*ru*/ "Не гасить экран",
        /*de*/ "Bildschirm aktiv lassen",
        /*fr*/ "Ecran toujours allumé",
        /*pl*/ "Ekran zawsze włączony"];
    static String get pref_keep_screen_on => l_pref_keep_screen_on[_language];

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
        /*fr*/ "Selection des sources",
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
        /*fr*/ "Noms personalisés des sources et dispositifs",
        /*pl*/ "Nazwa urządzenia"];
    static String get pref_friendly_names => l_pref_friendly_names[_language];

    static const List<String> l_pref_friendly_names_summary_on = [
        /*en*/ "Use friendly names provided by remote device",
        /*ru*/ "Использовать удобные названия, предоставленные удалённым устройством",
        /*de*/ "Lesbare Namen vom Onkyo-Gerät nutzen",
        /*fr*/ "Utilise les noms personalisés émis par le dispositif",
        /*pl*/ "Używaj nazwy dostarczonej przez zdalne urządzenie"];
    static String get pref_friendly_names_summary_on => l_pref_friendly_names_summary_on[_language];

    static const List<String> l_pref_friendly_names_summary_off = [
        /*en*/ "Use build-in names",
        /*ru*/ "Использовать встроенные названия",
        /*de*/ "Namen des Protokolls nutzen",
        /*fr*/ "Utilise les noms génériques",
        /*pl*/ "Użyj wbudowanych nazw"];
    static String get pref_friendly_names_summary_off => l_pref_friendly_names_summary_off[_language];

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
        /*fr*/ "Theme",
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
        /*de*/ "Selector position wrap-around up",
        /*fr*/ "Molette de selection haut",
        /*pl*/ "Głośniej"];
    static String get amp_cmd_selector_up => l_amp_cmd_selector_up[_language];

    static const List<String> l_amp_cmd_selector_down = [
        /*en*/ "Selector position wrap-around down",
        /*ru*/ "Выбрать предыдущий входной канал",
        /*de*/ "Selector position wrap-around down",
        /*fr*/ "Molette de selection bas",
        /*pl*/ "Ciszej"];
    static String get amp_cmd_selector_down => l_amp_cmd_selector_down[_language];

    static const List<String> l_amp_cmd_audio_muting_off = [
        /*en*/ "Amplifier audio muting off",
        /*ru*/ "Выключить звук усилителя",
        /*de*/ "Verstärker stumm ausschalten",
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
        /*fr*/ "Memoire",
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
        /*fr*/ "répéter",
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
        /*de*/ "Vorige Disk",
        /*fr*/ "Disque précédant",
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
        /*fr*/ "Audio silence desactivé",
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

    static const List<String> l_audio_control = [
        /*en*/ "Audio control",
        /*ru*/ "Контроль звука",
        /*de*/ "Audiosteuerung",
        /*fr*/ "Règlages Audio",
        /*pl*/ "Audio control"];
    static String get audio_control => l_audio_control[_language];

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
        /*fr*/ "Aigues",
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
        /*de*/ "Haupt Lautstärke",
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
        /*fr*/ "Restrict volume level",
        /*pl*/ "Restrict volume level"];
    static String get master_volume_restrict => l_master_volume_restrict[_language];

    static const List<String> l_master_volume_max = [
        /*en*/ "Maximum",
        /*ru*/ "Максимум",
        /*de*/ "Maximum",
        /*fr*/ "Maximum",
        /*pl*/ "Maximum"];
    static String get master_volume_max => l_master_volume_max[_language];

    static const List<String> l_preset_command_up = [
        /*en*/ "Sets preset wrap-around up",
        /*ru*/ "Следующий канал",
        /*de*/ "Nächster gespeicherter Sender",
        /*fr*/ "Préselection haut",
        /*pl*/ "Zapamiętane \"+\""];
    static String get preset_command_up => l_preset_command_up[_language];

    static const List<String> l_preset_command_down = [
        /*en*/ "Sets preset wrap-around down",
        /*ru*/ "Предыдущий канал",
        /*de*/ "Voriger gespeicherter Sender",
        /*fr*/ "Préselection bas",
        /*pl*/ "Zapamiętane \"-\""];
    static String get preset_command_down => l_preset_command_down[_language];

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
        /*de*/ "Vorigen Sender suchen",
        /*fr*/ "Changement fréquence bas",
        /*pl*/ "Strojenie \"-\""];
    static String get tuning_command_down => l_tuning_command_down[_language];

    static const List<String> l_cmd_description_play = [
        /*en*/ "Play",
        /*ru*/ "Воспроизведение",
        /*de*/ "Abspielen",
        /*fr*/ "Lécture",
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
        /*de*/ "voriger Titel",
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
        /*de*/ "Voriges",
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
        /*fr*/ "Selection",
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
        /*fr*/ "Language",
        /*pl*/ "Język"];
    static String get cmd_description_language => l_cmd_description_language[_language];

    static const List<String> l_cmd_description_setup = [
        /*en*/ "Setup",
        /*ru*/ "Настройки",
        /*de*/ "Einrichten",
        /*fr*/ "Paramètre",
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
        /*de*/ "Voriger Kanal (Iradio)",
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
        /*fr*/ "Positive Feed Or Mark/Unmark",
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
        /*pl*/ "Sort"];
    static String get cmd_description_sort => l_cmd_description_sort[_language];

    static const List<String> l_cmd_track_menu = [
        /*en*/ "Track menu",
        /*ru*/ "Меню трека",
        /*de*/ "Titel Menü",
        /*fr*/ "Menu des pistes",
        /*pl*/ "Menu utworów"];
    static String get cmd_track_menu => l_cmd_track_menu[_language];

    static const List<String> l_medialist_items = [
        /*en*/ "items",
        /*ru*/ "элементов",
        /*de*/ "Elemente",
        /*fr*/ "Elements",
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
        /*fr*/ "Mode de lécture",
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
        /*fr*/ "Filter items",
        /*pl*/ "Filter items"];
    static String get medialist_filter => l_medialist_filter[_language];

    static const List<String> l_input_selector_video1 = [
        /*en*/ "VCR/DVR",
        /*ru*/ "VCR/DVR",
        /*de*/ "VCR/DVR",
        /*fr*/ "VCR/DVR",
        /*pl*/ "VCR/DVR"];
    static String get input_selector_video1 => l_input_selector_video1[_language];

    static const List<String> l_input_selector_video2 = [
        /*en*/ "CBL/SAT",
        /*ru*/ "CBL/SAT",
        /*de*/ "CBL/SAT",
        /*fr*/ "CBL/SAT",
        /*pl*/ "CBL/SAT"];
    static String get input_selector_video2 => l_input_selector_video2[_language];

    static const List<String> l_input_selector_video3 = [
        /*en*/ "GAME",
        /*ru*/ "GAME",
        /*de*/ "GAME",
        /*fr*/ "GAME",
        /*pl*/ "GAME"];
    static String get input_selector_video3 => l_input_selector_video3[_language];

    static const List<String> l_input_selector_video4 = [
        /*en*/ "AUX",
        /*ru*/ "AUX",
        /*de*/ "AUX",
        /*fr*/ "AUX",
        /*pl*/ "AUX"];
    static String get input_selector_video4 => l_input_selector_video4[_language];

    static const List<String> l_input_selector_video5 = [
        /*en*/ "AUX2",
        /*ru*/ "AUX2",
        /*de*/ "AUX2",
        /*fr*/ "AUX2",
        /*pl*/ "AUX2"];
    static String get input_selector_video5 => l_input_selector_video5[_language];

    static const List<String> l_input_selector_video6 = [
        /*en*/ "PC",
        /*ru*/ "PC",
        /*de*/ "PC",
        /*fr*/ "PC",
        /*pl*/ "PC"];
    static String get input_selector_video6 => l_input_selector_video6[_language];

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

    static const List<String> l_input_selector_tv_cd = [
        /*en*/ "CD",
        /*ru*/ "CD",
        /*de*/ "CD",
        /*fr*/ "CD",
        /*pl*/ "CD"];
    static String get input_selector_tv_cd => l_input_selector_tv_cd[_language];

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

    static const List<String> l_playlist_options = [
        /*en*/ "Play queue",
        /*ru*/ "Очередь воспроизведения",
        /*de*/ "Abspielliste",
        /*fr*/ "File de lécture",
        /*pl*/ "Kolejka odtwarzania"];
    static String get playlist_options => l_playlist_options[_language];

    static const List<String> l_playlist_add = [
        /*en*/ "Add",
        /*ru*/ "Добавить",
        /*de*/ "Hnzufügen",
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
        /*fr*/ "Latest version",
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
        /*fr*/ "Mise à jour en cours, patienter…",
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
        /*fr*/ "Lancer la mise à jour en réseau",
        /*pl*/ "Rozpocznij aktualizację urządzenia przez sieć"];
    static String get device_firmware_net => l_device_firmware_net[_language];

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

    static const List<String> l_device_dimmer_level_off = [
        /*en*/ "Off",
        /*ru*/ "Выключено",
        /*de*/ "Aus",
        /*fr*/ "Eteint",
        /*pl*/ "Wyłączony"];
    static String get device_dimmer_level_off => l_device_dimmer_level_off[_language];

    static const List<String> l_device_dimmer_level_toggle = [
        /*en*/ "Sets dimmer level wrap-around",
        /*ru*/ "Изменить яркость дисплея",
        /*de*/ "Helligkeitseinstellung wechseln",
        /*fr*/ "Changer niveau luminosité",
        /*pl*/ "Zmień na kolejny"];
    static String get device_dimmer_level_toggle => l_device_dimmer_level_toggle[_language];

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
        /*ru*/ "Slow",
        /*de*/ "Langsam",
        /*fr*/ "Lent",
        /*pl*/ "Wolny"];
    static String get device_digital_filter_slow => l_device_digital_filter_slow[_language];

    static const List<String> l_device_digital_filter_sharp = [
        /*en*/ "Sharp",
        /*ru*/ "Sharp",
        /*de*/ "Klar",
        /*fr*/ "Précis",
        /*pl*/ "Ostry"];
    static String get device_digital_filter_sharp => l_device_digital_filter_sharp[_language];

    static const List<String> l_device_digital_filter_short = [
        /*en*/ "Short",
        /*ru*/ "Short",
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

    static const List<String> l_device_auto_power = [
        /*en*/ "Auto power",
        /*ru*/ "Авто-отключение",
        /*de*/ "Auto an/aus",
        /*fr*/ "Allumage auto",
        /*pl*/ "Auto power"];
    static String get device_auto_power => l_device_auto_power[_language];

    static const List<String> l_device_hdmi_cec = [
        /*en*/ "HDMI CEC",
        /*ru*/ "HDMI CEC",
        /*de*/ "HDMI CEC",
        /*fr*/ "HDMI CEC",
        /*pl*/ "HDMI CEC"];
    static String get device_hdmi_cec => l_device_hdmi_cec[_language];

    static const List<String> l_device_phase_matching_bass = [
        /*en*/ "PM Bass",
        /*ru*/ "PM Bass",
        /*de*/ "PM Bass",
        /*fr*/ "Basses avec adaptation de phase",
        /*pl*/ "PM Bass"];
    static String get device_phase_matching_bass => l_device_phase_matching_bass[_language];

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

    static const List<String> l_device_google_cast_analytics = [
        /*en*/ "Google Cast analytics",
        /*ru*/ "Аналитика Google Cast",
        /*de*/ "Google Cast analytics",
        /*fr*/ "Google Cast analytics",
        /*pl*/ "Google Cast analytics"];
    static String get device_google_cast_analytics => l_device_google_cast_analytics[_language];

    static const List<String> l_speaker_a_command_toggle = [
        /*en*/ "Sets speaker A switch wrap-around",
        /*ru*/ "Вкл/выкл динамик A",
        /*de*/ "Lautsprecher A umschalten",
        /*fr*/ "Selecteur Sortie A",
        /*pl*/ "Przełącz głośnik A na kolejny"];
    static String get speaker_a_command_toggle => l_speaker_a_command_toggle[_language];

    static const List<String> l_speaker_b_command_toggle = [
        /*en*/ "Sets speaker B switch wrap-around",
        /*ru*/ "Вкл/выкл динамик B",
        /*de*/ "Lautsprecher B umschalten",
        /*fr*/ "Selecteur Sortie B",
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
        /*ru*/ "оба выкл.",
        /*de*/ "Beide aus",
        /*fr*/ "Toutes éteintes",
        /*pl*/ "Oba wyłączone"];
    static String get speaker_ab_command_ab_off => l_speaker_ab_command_ab_off[_language];

    static const List<String> l_speaker_ab_command_ab_on = [
        /*en*/ "Both on",
        /*ru*/ "оба вкл.",
        /*de*/ "Beide an",
        /*fr*/ "Toutes allumlées",
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

    static const List<String> l_listening_mode_mode_00 = [
        /*en*/ "STEREO",
        /*ru*/ "STEREO",
        /*de*/ "STEREO",
        /*fr*/ "STEREO",
        /*pl*/ "STEREO"];
    static String get listening_mode_mode_00 => l_listening_mode_mode_00[_language];

    static const List<String> l_listening_mode_mode_01 = [
        /*en*/ "DIRECT",
        /*ru*/ "DIRECT",
        /*de*/ "DIREKT",
        /*fr*/ "DIRECT",
        /*pl*/ "DIRECT"];
    static String get listening_mode_mode_01 => l_listening_mode_mode_01[_language];

    static const List<String> l_listening_mode_mode_02 = [
        /*en*/ "SURROUND",
        /*ru*/ "SURROUND",
        /*de*/ "SURROUND",
        /*fr*/ "SURROUND",
        /*pl*/ "SURROUND"];
    static String get listening_mode_mode_02 => l_listening_mode_mode_02[_language];

    static const List<String> l_listening_mode_mode_03 = [
        /*en*/ "FILM",
        /*ru*/ "FILM",
        /*de*/ "FILM",
        /*fr*/ "FILM",
        /*pl*/ "FILM"];
    static String get listening_mode_mode_03 => l_listening_mode_mode_03[_language];

    static const List<String> l_listening_mode_mode_04 = [
        /*en*/ "THX",
        /*ru*/ "THX",
        /*de*/ "THX",
        /*fr*/ "THX",
        /*pl*/ "THX"];
    static String get listening_mode_mode_04 => l_listening_mode_mode_04[_language];

    static const List<String> l_listening_mode_mode_05 = [
        /*en*/ "ACTION",
        /*ru*/ "ACTION",
        /*de*/ "ACTION",
        /*fr*/ "ACTION",
        /*pl*/ "ACTION"];
    static String get listening_mode_mode_05 => l_listening_mode_mode_05[_language];

    static const List<String> l_listening_mode_mode_06 = [
        /*en*/ "MUSICAL",
        /*ru*/ "MUSICAL",
        /*de*/ "MUSICAL",
        /*fr*/ "MUSICAL",
        /*pl*/ "MUSICAL"];
    static String get listening_mode_mode_06 => l_listening_mode_mode_06[_language];

    static const List<String> l_listening_mode_mode_07 = [
        /*en*/ "MONO MOVIE",
        /*ru*/ "MONO MOVIE",
        /*de*/ "MONO FILM",
        /*fr*/ "MONO MOVIE",
        /*pl*/ "MONO MOVIE"];
    static String get listening_mode_mode_07 => l_listening_mode_mode_07[_language];

    static const List<String> l_listening_mode_mode_08 = [
        /*en*/ "ORCHESTRA",
        /*ru*/ "ORCHESTRA",
        /*de*/ "ORCHESTER",
        /*fr*/ "ORCHESTRA",
        /*pl*/ "ORCHESTRA"];
    static String get listening_mode_mode_08 => l_listening_mode_mode_08[_language];

    static const List<String> l_listening_mode_mode_09 = [
        /*en*/ "UNPLUGGED",
        /*ru*/ "UNPLUGGED",
        /*de*/ "UNPLUGGED",
        /*fr*/ "UNPLUGGED",
        /*pl*/ "UNPLUGGED"];
    static String get listening_mode_mode_09 => l_listening_mode_mode_09[_language];

    static const List<String> l_listening_mode_mode_0a = [
        /*en*/ "STUDIO-MIX",
        /*ru*/ "STUDIO-MIX",
        /*de*/ "STUDIO-MIX",
        /*fr*/ "STUDIO-MIX",
        /*pl*/ "STUDIO-MIX"];
    static String get listening_mode_mode_0a => l_listening_mode_mode_0a[_language];

    static const List<String> l_listening_mode_mode_0b = [
        /*en*/ "TV LOGIC",
        /*ru*/ "TV LOGIC",
        /*de*/ "TV LOGIC",
        /*fr*/ "TV LOGIC",
        /*pl*/ "TV LOGIC"];
    static String get listening_mode_mode_0b => l_listening_mode_mode_0b[_language];

    static const List<String> l_listening_mode_mode_0c = [
        /*en*/ "ALL CH STEREO",
        /*ru*/ "ALL CH STEREO",
        /*de*/ "ALL CH STEREO",
        /*fr*/ "ALL CH STEREO",
        /*pl*/ "ALL CH STEREO"];
    static String get listening_mode_mode_0c => l_listening_mode_mode_0c[_language];

    static const List<String> l_listening_mode_mode_0d = [
        /*en*/ "THEATER-DIMENSIONAL",
        /*ru*/ "THEATER-DIMENSIONAL",
        /*de*/ "THEATER-DIMENSIONAL",
        /*fr*/ "THEATER-DIMENSIONAL",
        /*pl*/ "THEATER-DIMENSIONAL"];
    static String get listening_mode_mode_0d => l_listening_mode_mode_0d[_language];

    static const List<String> l_listening_mode_mode_0e = [
        /*en*/ "ENHANCED 7/ENHANCE",
        /*ru*/ "ENHANCED 7/ENHANCE",
        /*de*/ "SPIELE-SPORT",
        /*fr*/ "ENHANCED 7/ENHANCE",
        /*pl*/ "ENHANCED 7/ENHANCE"];
    static String get listening_mode_mode_0e => l_listening_mode_mode_0e[_language];

    static const List<String> l_listening_mode_mode_0f = [
        /*en*/ "MONO",
        /*ru*/ "MONO",
        /*de*/ "MONO",
        /*fr*/ "MONO",
        /*pl*/ "MONO"];
    static String get listening_mode_mode_0f => l_listening_mode_mode_0f[_language];

    static const List<String> l_listening_mode_mode_11 = [
        /*en*/ "PURE AUDIO",
        /*ru*/ "PURE AUDIO",
        /*de*/ "PURE AUDIO",
        /*fr*/ "PURE AUDIO",
        /*pl*/ "PURE AUDIO"];
    static String get listening_mode_mode_11 => l_listening_mode_mode_11[_language];

    static const List<String> l_listening_mode_mode_12 = [
        /*en*/ "MULTIPLEX",
        /*ru*/ "MULTIPLEX",
        /*de*/ "MULTIPLEX",
        /*fr*/ "MULTIPLEX",
        /*pl*/ "MULTIPLEX"];
    static String get listening_mode_mode_12 => l_listening_mode_mode_12[_language];

    static const List<String> l_listening_mode_mode_13 = [
        /*en*/ "FULL MONO",
        /*ru*/ "FULL MONO",
        /*de*/ "FULL MONO",
        /*fr*/ "FULL MONO",
        /*pl*/ "FULL MONO"];
    static String get listening_mode_mode_13 => l_listening_mode_mode_13[_language];

    static const List<String> l_listening_mode_mode_14 = [
        /*en*/ "DOLBY VIRTUAL",
        /*ru*/ "DOLBY VIRTUAL",
        /*de*/ "DOLBY VIRTUAL",
        /*fr*/ "DOLBY VIRTUAL",
        /*pl*/ "DOLBY VIRTUAL"];
    static String get listening_mode_mode_14 => l_listening_mode_mode_14[_language];

    static const List<String> l_listening_mode_mode_15 = [
        /*en*/ "DTS Surround Sensation",
        /*ru*/ "DTS Surround Sensation",
        /*de*/ "DTS Surround Sensation",
        /*fr*/ "DTS Surround Sensation",
        /*pl*/ "DTS Surround Sensation"];
    static String get listening_mode_mode_15 => l_listening_mode_mode_15[_language];

    static const List<String> l_listening_mode_mode_16 = [
        /*en*/ "Audyssey DSX",
        /*ru*/ "Audyssey DSX",
        /*de*/ "Audyssey DSX",
        /*fr*/ "Audyssey DSX",
        /*pl*/ "Audyssey DSX"];
    static String get listening_mode_mode_16 => l_listening_mode_mode_16[_language];

    static const List<String> l_listening_mode_mode_1f = [
        /*en*/ "Whole House Mode",
        /*ru*/ "Whole House Mode",
        /*de*/ "Whole House Mode",
        /*fr*/ "Whole House Mode",
        /*pl*/ "Whole House Mode"];
    static String get listening_mode_mode_1f => l_listening_mode_mode_1f[_language];

    static const List<String> l_listening_mode_mode_40 = [
        /*en*/ "5.1ch Surround",
        /*ru*/ "5.1ch Surround",
        /*de*/ "5.1ch Surround",
        /*fr*/ "5.1ch Surround",
        /*pl*/ "5.1ch Surround"];
    static String get listening_mode_mode_40 => l_listening_mode_mode_40[_language];

    static const List<String> l_listening_mode_mode_41 = [
        /*en*/ "Dolby EX/DTS ES",
        /*ru*/ "Dolby EX/DTS ES",
        /*de*/ "Dolby EX/DTS ES",
        /*fr*/ "Dolby EX/DTS ES",
        /*pl*/ "Dolby EX/DTS ES"];
    static String get listening_mode_mode_41 => l_listening_mode_mode_41[_language];

    static const List<String> l_listening_mode_mode_42 = [
        /*en*/ "THX Cinema",
        /*ru*/ "THX Cinema",
        /*de*/ "THX Kino",
        /*fr*/ "THX Cinema",
        /*pl*/ "THX Cinema"];
    static String get listening_mode_mode_42 => l_listening_mode_mode_42[_language];

    static const List<String> l_listening_mode_mode_43 = [
        /*en*/ "THX Surround EX",
        /*ru*/ "THX Surround EX",
        /*de*/ "THX Surround EX",
        /*fr*/ "THX Surround EX",
        /*pl*/ "THX Surround EX"];
    static String get listening_mode_mode_43 => l_listening_mode_mode_43[_language];

    static const List<String> l_listening_mode_mode_44 = [
        /*en*/ "THX Music",
        /*ru*/ "THX Music",
        /*de*/ "THX Musik",
        /*fr*/ "THX Music",
        /*pl*/ "THX Music"];
    static String get listening_mode_mode_44 => l_listening_mode_mode_44[_language];

    static const List<String> l_listening_mode_mode_45 = [
        /*en*/ "THX Games",
        /*ru*/ "THX Games",
        /*de*/ "THX Spiele",
        /*fr*/ "THX Games",
        /*pl*/ "THX Games"];
    static String get listening_mode_mode_45 => l_listening_mode_mode_45[_language];

    static const List<String> l_listening_mode_mode_50 = [
        /*en*/ "THX U(2)/S(2)/I/S Cinema/Cinema2",
        /*ru*/ "THX U(2)/S(2)/I/S Cinema/Cinema2",
        /*de*/ "THX U(2)/S(2)/I/S Kino/Kino2",
        /*fr*/ "THX U(2)/S(2)/I/S Cinema/Cinema2",
        /*pl*/ "THX U(2)/S(2)/I/S Cinema/Cinema2"];
    static String get listening_mode_mode_50 => l_listening_mode_mode_50[_language];

    static const List<String> l_listening_mode_mode_51 = [
        /*en*/ "THX MusicMode",
        /*ru*/ "THX MusicMode",
        /*de*/ "THX MusikModus",
        /*fr*/ "THX MusicMode",
        /*pl*/ "THX MusicMode"];
    static String get listening_mode_mode_51 => l_listening_mode_mode_51[_language];

    static const List<String> l_listening_mode_mode_52 = [
        /*en*/ "THX Games Mode",
        /*ru*/ "THX Games Mode",
        /*de*/ "THX Spiele Modus",
        /*fr*/ "THX Games Mode",
        /*pl*/ "THX Games Mode"];
    static String get listening_mode_mode_52 => l_listening_mode_mode_52[_language];

    static const List<String> l_listening_mode_mode_80 = [
        /*en*/ "DOLBY SURROUND",
        /*ru*/ "PLII/PLIIx Movie ",
        /*de*/ "PLII/PLIIx Film ",
        /*fr*/ "DOLBY SURROUND",
        /*pl*/ "DOLBY SURROUND"];
    static String get listening_mode_mode_80 => l_listening_mode_mode_80[_language];

    static const List<String> l_listening_mode_mode_81 = [
        /*en*/ "PLII/PLIIx Music",
        /*ru*/ "PLII/PLIIx Music",
        /*de*/ "PLII/PLIIx Musik",
        /*fr*/ "PLII/PLIIx Music",
        /*pl*/ "PLII/PLIIx Music"];
    static String get listening_mode_mode_81 => l_listening_mode_mode_81[_language];

    static const List<String> l_listening_mode_mode_82 = [
        /*en*/ "DTS NEURAL:X",
        /*ru*/ "Neo:6 Cinema/Neo:X Cinema",
        /*de*/ "Neo:6 Kino/Neo:X Kino",
        /*fr*/ "DTS NEURAL:X",
        /*pl*/ "DTS NEURAL:X"];
    static String get listening_mode_mode_82 => l_listening_mode_mode_82[_language];

    static const List<String> l_listening_mode_mode_83 = [
        /*en*/ "Neo:6 Music/Neo:X Music",
        /*ru*/ "Neo:6 Music/Neo:X Music",
        /*de*/ "Neo:6 Musik/Neo:X Musik",
        /*fr*/ "Neo:6 Music/Neo:X Music",
        /*pl*/ "Neo:6 Music/Neo:X Music"];
    static String get listening_mode_mode_83 => l_listening_mode_mode_83[_language];

    static const List<String> l_listening_mode_mode_84 = [
        /*en*/ "PLII/PLIIx THX Cinema  ",
        /*ru*/ "PLII/PLIIx THX Cinema  ",
        /*de*/ "PLII/PLIIx THX Kino  ",
        /*fr*/ "PLII/PLIIx THX Cinema  ",
        /*pl*/ "PLII/PLIIx THX Cinema  "];
    static String get listening_mode_mode_84 => l_listening_mode_mode_84[_language];

    static const List<String> l_listening_mode_mode_85 = [
        /*en*/ "Neo:6/Neo:X THX Cinema",
        /*ru*/ "Neo:6/Neo:X THX Cinema",
        /*de*/ "Neo:6/Neo:X THX Kino",
        /*fr*/ "Neo:6/Neo:X THX Cinema",
        /*pl*/ "Neo:6/Neo:X THX Cinema"];
    static String get listening_mode_mode_85 => l_listening_mode_mode_85[_language];

    static const List<String> l_listening_mode_mode_86 = [
        /*en*/ "PLII/PLIIx Game",
        /*ru*/ "PLII/PLIIx Game",
        /*de*/ "PLII/PLIIx Spiele",
        /*fr*/ "PLII/PLIIx Game",
        /*pl*/ "PLII/PLIIx Game"];
    static String get listening_mode_mode_86 => l_listening_mode_mode_86[_language];

    static const List<String> l_listening_mode_mode_87 = [
        /*en*/ "Neural Surr*3",
        /*ru*/ "Neural Surr*3",
        /*de*/ "Neural Surr*3",
        /*fr*/ "Neural Surr*3",
        /*pl*/ "Neural Surr*3"];
    static String get listening_mode_mode_87 => l_listening_mode_mode_87[_language];

    static const List<String> l_listening_mode_mode_88 = [
        /*en*/ "Neural THX/Neural Surround",
        /*ru*/ "Neural THX/Neural Surround",
        /*de*/ "Neural THX/Neural Surround",
        /*fr*/ "Neural THX/Neural Surround",
        /*pl*/ "Neural THX/Neural Surround"];
    static String get listening_mode_mode_88 => l_listening_mode_mode_88[_language];

    static const List<String> l_listening_mode_mode_89 = [
        /*en*/ "PLII/PLIIx THX Games",
        /*ru*/ "PLII/PLIIx THX Games",
        /*de*/ "PLII/PLIIx THX Spiele",
        /*fr*/ "PLII/PLIIx THX Games",
        /*pl*/ "PLII/PLIIx THX Games"];
    static String get listening_mode_mode_89 => l_listening_mode_mode_89[_language];

    static const List<String> l_listening_mode_mode_8a = [
        /*en*/ "Neo:6/Neo:X THX Games",
        /*ru*/ "Neo:6/Neo:X THX Games",
        /*de*/ "Neo:6/Neo:X THX Spiele",
        /*fr*/ "Neo:6/Neo:X THX Games",
        /*pl*/ "Neo:6/Neo:X THX Games"];
    static String get listening_mode_mode_8a => l_listening_mode_mode_8a[_language];

    static const List<String> l_listening_mode_mode_8b = [
        /*en*/ "PLII/PLIIx THX Music ",
        /*ru*/ "PLII/PLIIx THX Music ",
        /*de*/ "PLII/PLIIx THX Musik ",
        /*fr*/ "PLII/PLIIx THX Music ",
        /*pl*/ "PLII/PLIIx THX Music "];
    static String get listening_mode_mode_8b => l_listening_mode_mode_8b[_language];

    static const List<String> l_listening_mode_mode_8c = [
        /*en*/ "Neo:6/Neo:X THX Music",
        /*ru*/ "Neo:6/Neo:X THX Music",
        /*de*/ "Neo:6/Neo:X THX Musik",
        /*fr*/ "Neo:6/Neo:X THX Music",
        /*pl*/ "Neo:6/Neo:X THX Music"];
    static String get listening_mode_mode_8c => l_listening_mode_mode_8c[_language];

    static const List<String> l_listening_mode_mode_8d = [
        /*en*/ "Neural THX Cinema",
        /*ru*/ "Neural THX Cinema",
        /*de*/ "Neural THX Kino",
        /*fr*/ "Neural THX Cinema",
        /*pl*/ "Neural THX Cinema"];
    static String get listening_mode_mode_8d => l_listening_mode_mode_8d[_language];

    static const List<String> l_listening_mode_mode_8e = [
        /*en*/ "Neural THX Music",
        /*ru*/ "Neural THX Music",
        /*de*/ "Neural THX Musik",
        /*fr*/ "Neural THX Music",
        /*pl*/ "Neural THX Music"];
    static String get listening_mode_mode_8e => l_listening_mode_mode_8e[_language];

    static const List<String> l_listening_mode_mode_8f = [
        /*en*/ "Neural THX Games",
        /*ru*/ "Neural THX Games",
        /*de*/ "Neural THX Spiele",
        /*fr*/ "Neural THX Games",
        /*pl*/ "Neural THX Games"];
    static String get listening_mode_mode_8f => l_listening_mode_mode_8f[_language];

    static const List<String> l_listening_mode_mode_90 = [
        /*en*/ "PLIIz Height",
        /*ru*/ "PLIIz Height",
        /*de*/ "PLIIz Height",
        /*fr*/ "PLIIz Height",
        /*pl*/ "PLIIz Height"];
    static String get listening_mode_mode_90 => l_listening_mode_mode_90[_language];

    static const List<String> l_listening_mode_mode_91 = [
        /*en*/ "Neo:6 Cinema DTS Surround Sensation",
        /*ru*/ "Neo:6 Cinema DTS Surround Sensation",
        /*de*/ "Neo:6 Kino DTS Surround Sensation",
        /*fr*/ "Neo:6 Cinema DTS Surround Sensation",
        /*pl*/ "Neo:6 Cinema DTS Surround Sensation"];
    static String get listening_mode_mode_91 => l_listening_mode_mode_91[_language];

    static const List<String> l_listening_mode_mode_92 = [
        /*en*/ "Neo:6 Music DTS Surround Sensation",
        /*ru*/ "Neo:6 Music DTS Surround Sensation",
        /*de*/ "Neo:6 Musik DTS Surround Sensation",
        /*fr*/ "Neo:6 Music DTS Surround Sensation",
        /*pl*/ "Neo:6 Music DTS Surround Sensation"];
    static String get listening_mode_mode_92 => l_listening_mode_mode_92[_language];

    static const List<String> l_listening_mode_mode_93 = [
        /*en*/ "Neural Digital Music",
        /*ru*/ "Neural Digital Music",
        /*de*/ "Neural Digital Musik",
        /*fr*/ "Neural Digital Music",
        /*pl*/ "Neural Digital Music"];
    static String get listening_mode_mode_93 => l_listening_mode_mode_93[_language];

    static const List<String> l_listening_mode_mode_94 = [
        /*en*/ "PLIIz Height + THX Cinema",
        /*ru*/ "PLIIz Height + THX Cinema",
        /*de*/ "PLIIz Height + THX Kino",
        /*fr*/ "PLIIz Height + THX Cinema",
        /*pl*/ "PLIIz Height + THX Cinema"];
    static String get listening_mode_mode_94 => l_listening_mode_mode_94[_language];

    static const List<String> l_listening_mode_mode_95 = [
        /*en*/ "PLIIz Height + THX Music",
        /*ru*/ "PLIIz Height + THX Music",
        /*de*/ "PLIIz Height + THX Musik",
        /*fr*/ "PLIIz Height + THX Music",
        /*pl*/ "PLIIz Height + THX Music"];
    static String get listening_mode_mode_95 => l_listening_mode_mode_95[_language];

    static const List<String> l_listening_mode_mode_96 = [
        /*en*/ "PLIIz Height + THX Games",
        /*ru*/ "PLIIz Height + THX Games",
        /*de*/ "PLIIz Height + THX Spiele",
        /*fr*/ "PLIIz Height + THX Games",
        /*pl*/ "PLIIz Height + THX Games"];
    static String get listening_mode_mode_96 => l_listening_mode_mode_96[_language];

    static const List<String> l_listening_mode_mode_97 = [
        /*en*/ "PLIIz Height + THX U2/S2 Cinema",
        /*ru*/ "PLIIz Height + THX U2/S2 Cinema",
        /*de*/ "PLIIz Height + THX U2/S2 Kino",
        /*fr*/ "PLIIz Height + THX U2/S2 Cinema",
        /*pl*/ "PLIIz Height + THX U2/S2 Cinema"];
    static String get listening_mode_mode_97 => l_listening_mode_mode_97[_language];

    static const List<String> l_listening_mode_mode_98 = [
        /*en*/ "PLIIz Height + THX U2/S2 Music",
        /*ru*/ "PLIIz Height + THX U2/S2 Music",
        /*de*/ "PLIIz Height + THX U2/S2 Musik",
        /*fr*/ "PLIIz Height + THX U2/S2 Music",
        /*pl*/ "PLIIz Height + THX U2/S2 Music"];
    static String get listening_mode_mode_98 => l_listening_mode_mode_98[_language];

    static const List<String> l_listening_mode_mode_99 = [
        /*en*/ "PLIIz Height + THX U2/S2 Games",
        /*ru*/ "PLIIz Height + THX U2/S2 Games",
        /*de*/ "PLIIz Height + THX U2/S2 Spiele",
        /*fr*/ "PLIIz Height + THX U2/S2 Games",
        /*pl*/ "PLIIz Height + THX U2/S2 Games"];
    static String get listening_mode_mode_99 => l_listening_mode_mode_99[_language];

    static const List<String> l_listening_mode_mode_9a = [
        /*en*/ "Neo:X Game",
        /*ru*/ "Neo:X Game",
        /*de*/ "Neo:X Spiele",
        /*fr*/ "Neo:X Game",
        /*pl*/ "Neo:X Game"];
    static String get listening_mode_mode_9a => l_listening_mode_mode_9a[_language];

    static const List<String> l_listening_mode_mode_a0 = [
        /*en*/ "PLIIx/PLII Movie + Audyssey DSX",
        /*ru*/ "PLIIx/PLII Movie + Audyssey DSX",
        /*de*/ "PLIIx/PLII Movie + Audyssey DSX",
        /*fr*/ "PLIIx/PLII Movie + Audyssey DSX",
        /*pl*/ "PLIIx/PLII Movie + Audyssey DSX"];
    static String get listening_mode_mode_a0 => l_listening_mode_mode_a0[_language];

    static const List<String> l_listening_mode_mode_a1 = [
        /*en*/ "PLIIx/PLII Music + Audyssey DSX",
        /*ru*/ "PLIIx/PLII Music + Audyssey DSX",
        /*de*/ "PLIIx/PLII Musik + Audyssey DSX",
        /*fr*/ "PLIIx/PLII Music + Audyssey DSX",
        /*pl*/ "PLIIx/PLII Music + Audyssey DSX"];
    static String get listening_mode_mode_a1 => l_listening_mode_mode_a1[_language];

    static const List<String> l_listening_mode_mode_a2 = [
        /*en*/ "PLIIx/PLII Game + Audyssey DSX",
        /*ru*/ "PLIIx/PLII Game + Audyssey DSX",
        /*de*/ "PLIIx/PLII Spiele + Audyssey DSX",
        /*fr*/ "PLIIx/PLII Game + Audyssey DSX",
        /*pl*/ "PLIIx/PLII Game + Audyssey DSX"];
    static String get listening_mode_mode_a2 => l_listening_mode_mode_a2[_language];

    static const List<String> l_listening_mode_mode_a3 = [
        /*en*/ "Neo:6 Cinema + Audyssey DSX",
        /*ru*/ "Neo:6 Cinema + Audyssey DSX",
        /*de*/ "Neo:6 Kino + Audyssey DSX",
        /*fr*/ "Neo:6 Cinema + Audyssey DSX",
        /*pl*/ "Neo:6 Cinema + Audyssey DSX"];
    static String get listening_mode_mode_a3 => l_listening_mode_mode_a3[_language];

    static const List<String> l_listening_mode_mode_a4 = [
        /*en*/ "Neo:6 Music + Audyssey DSX",
        /*ru*/ "Neo:6 Music + Audyssey DSX",
        /*de*/ "Neo:6 Musik + Audyssey DSX",
        /*fr*/ "Neo:6 Music + Audyssey DSX",
        /*pl*/ "Neo:6 Music + Audyssey DSX"];
    static String get listening_mode_mode_a4 => l_listening_mode_mode_a4[_language];

    static const List<String> l_listening_mode_mode_a5 = [
        /*en*/ "Neural Surround + Audyssey DSX",
        /*ru*/ "Neural Surround + Audyssey DSX",
        /*de*/ "Neural Surround + Audyssey DSX",
        /*fr*/ "Neural Surround + Audyssey DSX",
        /*pl*/ "Neural Surround + Audyssey DSX"];
    static String get listening_mode_mode_a5 => l_listening_mode_mode_a5[_language];

    static const List<String> l_listening_mode_mode_a6 = [
        /*en*/ "Neural Digital Music + Audyssey DSX",
        /*ru*/ "Neural Digital Music + Audyssey DSX",
        /*de*/ "Neural Digital Musik + Audyssey DSX",
        /*fr*/ "Neural Digital Music + Audyssey DSX",
        /*pl*/ "Neural Digital Music + Audyssey DSX"];
    static String get listening_mode_mode_a6 => l_listening_mode_mode_a6[_language];

    static const List<String> l_listening_mode_mode_a7 = [
        /*en*/ "Dolby EX + Audyssey DSX",
        /*ru*/ "Dolby EX + Audyssey DSX",
        /*de*/ "Dolby EX + Audyssey DSX",
        /*fr*/ "Dolby EX + Audyssey DSX",
        /*pl*/ "Dolby EX + Audyssey DSX"];
    static String get listening_mode_mode_a7 => l_listening_mode_mode_a7[_language];

    static const List<String> l_listening_mode_mode_ff = [
        /*en*/ "Auto Surround",
        /*ru*/ "Auto Surround",
        /*de*/ "Auto Surround",
        /*fr*/ "Auto Surround",
        /*pl*/ "Auto Surround"];
    static String get listening_mode_mode_ff => l_listening_mode_mode_ff[_language];

    static const List<String> l_listening_mode_up = [
        /*en*/ "Sets listening mode wrap-around up",
        /*ru*/ "Изменить звуковой профиль",
        /*de*/ "Klangprofile durchwechseln",
        /*fr*/ "Changer mode d\'écoute",
        /*pl*/ "Zmień tryb na następny"];
    static String get listening_mode_up => l_listening_mode_up[_language];

    static const List<String> l_remote_interface = [
        /*en*/ "Use devices connected via Remote Interface (RI)",
        /*ru*/ "Использовать устройства, подключенные через удаленный интерфейс (RI)",
        /*de*/ "Über RI Verbundene Geräte nutzen",
        /*fr*/ "Utilise des dispositifs connectés par Remote Interface (RI)",
        /*pl*/ "Używaj urządzeń podłączonych przez interfejs zdalny (RI)"];
    static String get remote_interface => l_remote_interface[_language];

    static const List<String> l_remote_interface_amp = [
        /*en*/ "Amplifier",
        /*ru*/ "Усилитель",
        /*de*/ "Verstärker",
        /*fr*/ "Amplificateur",
        /*pl*/ "Wzmacniacz"];
    static String get remote_interface_amp => l_remote_interface_amp[_language];

    static const List<String> l_remote_interface_cd = [
        /*en*/ "CD Player",
        /*ru*/ "CD-проигрыватель",
        /*de*/ "CD Player",
        /*fr*/ "CD Player",
        /*pl*/ "CD Player"];
    static String get remote_interface_cd => l_remote_interface_cd[_language];

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

    static const List<String> l_error_connection_no_device = [
        /*en*/ "Remote device not found",
        /*ru*/ "Устройство не найдено",
        /*de*/ "Onkyo Gerät nicht gefunden",
        /*fr*/ "Dispositif distant non trouvé",
        /*pl*/ "Nie znaleziono urządzenia zdalnego"];
    static String get error_connection_no_device => l_error_connection_no_device[_language];

    static const List<String> l_error_connection_no_response = [
        /*en*/ "Remote device %s not responding",
        /*ru*/ "Устойство %s не отвечает",
        /*de*/ "Onkyo Gerät %s antwortet nicht",
        /*fr*/ "Dispositif distant %s ne répond pas",
        /*pl*/ "Urządzenie zdalne %s nie odpowiada"];
    static String get error_connection_no_response => l_error_connection_no_response[_language];

    /* Translatable arrays */

    static const List<List<String>> l_pref_sound_control_names = [
        /*en*/ ["None",
                "External amplifier (RI)",
                "Device",
                "Device (Slider)",
                "Automatic"],
        /*ru*/ ["Нет",
                "Внешний усилитель (RI)",
                "Устройство",
                "Устройство (Слайдер)",
                "Выбрать автоматически"],
        /*de*/ ["Keine",
                "Externer Verstärker (RI)",
                "Gerät",
                "Gerät (Slider)",
                "Automatisch"],
        /*fr*/ ["Aucun",
                "Amplificateur Externe (RI)",
                "Dispositif",
                "Dispositif (Slider)",
                "Automatique"],
        /*pl*/ ["Brak",
                "Wzmacniacz zewnętrzny (RI)",
                "Urządzenie",
                "Urządzenie (Slider)",
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
                "Clair (Bleu and Orange)",
                "Clair (Emeraude et magenta)",
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
                "Enorme"],
        /*pl*/ ["Małe",
                "Normalne",
                "Duże",
                "Ogromne"]];
    static List<String> get pref_text_size_names => l_pref_text_size_names[_language];
}
