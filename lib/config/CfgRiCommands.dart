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
// @dart=2.9

import "package:flutter/services.dart" show rootBundle;
import "package:shared_preferences/shared_preferences.dart";
import "package:xml/xml.dart" as xml;

import "../utils/Convert.dart";
import "../utils/Logging.dart";
import "../utils/Pair.dart";
import "../utils/CompatUtils.dart";
import "../Platform.dart";
import "../iscp/ISCPMessage.dart";
import "../iscp/StateManager.dart";
import "CfgModule.dart";

enum RiDeviceType
{
    AMPLIFIER,
    CD_PLAYER,
    MD_PLAYER,
    TAPE_DECK
}

class RiCommand
{
    String code;
    String hex;

    RiCommand.fromXml(xml.XmlNode command)
    {
        code = ISCPMessage.nonNullString(command.getAttribute("code"));
        hex = ISCPMessage.nonNullString(command.getAttribute("hex"));
    }
}

class RiDevice
{
    String type;
    String model;
    final List<RiCommand> commands = [];

    RiDevice.fromXml(xml.XmlElement device)
    {
        type = ISCPMessage.nonNullString(device.getAttribute("type"));
        model = ISCPMessage.nonNullString(device.getAttribute("model"));
        device.children.forEach((c)
        {
            if (c.getAttribute("code") != null && c.getAttribute("code").isNotEmpty)
            {
                commands.add(RiCommand.fromXml(c));
            }
        });
    }

    void printInfo()
    {
        String commandsInfo = "";
        commands.forEach((c) => commandsInfo += " " + c.code);
        Logging.info(this, "  " + type.toString() + "(" + model + "), "
            + commands.length.toString() + " commands: " + commandsInfo);
    }
}

class CfgRiCommands extends CfgModule
{
    // All ports
    List<Pair<String, String>> _ports = [];

    List<Pair<String, String>> get ports
    => _ports;

    // All devices
    final List<RiDevice> _devices = [];

    // Active USB port
    static const Pair<String, String> USB_PORT = Pair<String, String>("usb_port", "");
    String _usbPort = "";

    String get usbPort
    => _usbPort;

    set usbPort(String value)
    {
        _usbPort = value;
        saveStringParameter(USB_PORT, value);
    }

    bool get isOn => Platform.isDesktop && _usbPort.isNotEmpty;

    // Device images
    static const Pair<String, String> AMP_MODEL = Pair<String, String>("amp_model", "A-9010");
    String _ampModel;

    String get ampModel
    => _ampModel;

    set ampModel(String value)
    {
        _ampModel = value;
        saveStringParameter(AMP_MODEL, value);
    }

    static const Pair<String, String> CD_MODEL = Pair<String, String>("cd_model", "C-7030");
    String _cdModel;

    String get cdModel
    => _cdModel;

    set cdModel(String value)
    {
        _cdModel = value;
        saveStringParameter(CD_MODEL, value);
    }

    // methods
    CfgRiCommands(final SharedPreferences preferences) : super(preferences);

    @override
    void read()
    {
        _ampModel = getString(AMP_MODEL, doLog: true);
        _cdModel = getString(CD_MODEL, doLog: true);

        if (!Platform.isDesktop)
        {
            return;
        }
        try
        {
            _ports = SerialPortWrapper.getPorts();
            Logging.info(this, "Available USB ports:");
            _ports.forEach((p) => Logging.info(this, "  " + p.toString()));
        }
        on Exception catch (e)
        {
            Logging.info(this, "can not read serial ports: " + e.toString());
        }

        try
        {
            _devices.clear();
            rootBundle.loadString('lib/assets/ri/commands.xml').then((String content)
            {
                final xml.XmlDocument document = xml.XmlDocument.parse(content);
                document.findAllElements("device").forEach((d) => _devices.add(RiDevice.fromXml(d)));
                Logging.info(this, "Configured USB-RI commands:");
                _devices.forEach((d) => d.printInfo());
            });
        }
        on Exception catch (e)
        {
            Logging.info(this, "can not read USB-RI commands: " + e.toString());
        }

        _usbPort = getString(USB_PORT, doLog: true);
        if (_usbPort.isNotEmpty && !_ports.any((p) => p.item1 == _usbPort))
        {
            Logging.info(this, "configured port is not more available, clear it");
            _usbPort = "";
        }
    }

    @override
    void setReceiverInformation(StateManager stateManager)
    {
        // nothing to do
    }

    RiCommand findCommand(RiDeviceType type, String code)
    {
        if (isOn)
        {
            for (RiDevice d in _devices)
            {
                final RiCommand rc = d.commands.firstWhere((c) => c.code == code, orElse: () => null);
                if (d.type == Convert.enumToString(type) && rc != null)
                {
                    return rc.hex.isNotEmpty ? rc : null;
                }
            }
        }
        return null;
    }
}