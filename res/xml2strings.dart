/*
 * Enhanced Controller for Onkyo and Pioneer Pro
 * Copyright (C) 2019-2021 by Mikhail Kulesh
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

import "dart:io";
import "package:xml/xml.dart" as xml;
import "package:args/args.dart";
import 'package:xml/xml.dart';

const inputFile = "input";
const outputFile = "output";

final List<String> TRANSLATIONS = ["ru", "de", "fr", "pl"];

void main(List<String> arguments) async
{
    if (arguments.length != 4)
    {
        print("Invalid arguments. Usage: xml2strings --input <file1> --output <file2>");
        return;
    }

    final parser = ArgParser()
        ..addOption(inputFile, abbr: 'i')
        ..addOption(outputFile, abbr: 'o');

    final ArgResults argResults = parser.parse(arguments);

    final String inFile = argResults[inputFile];
    final String outFile = argResults[outputFile];

    print("xml2strings: " + inFile + " -> " + outFile);

    final Map<String, xml.XmlDocument> inTranslations = Map();
    for(String tName in TRANSLATIONS)
    {
        final tFile = inFile.split(".")[0] + "_" + tName + "." + inFile.split(".")[1];
        await File(tFile).readAsString().then((String inContent)
        {
            print("    transtation " + tFile + ": " + inContent.length.toString() + "B");
            inTranslations[tName] = xml.XmlDocument.parse(inContent);
        });
    };

    final StringBuffer outContent = StringBuffer();
    await File(inFile).readAsString().then((String inContent)
    {
        outContent.writeln("/*                    ---- CAUTION! ----                    */");
        outContent.writeln("/* This is an auto-generated file! Do not edit it manually. */");
        outContent.writeln("");
        outContent.writeln("/* Class collects all strings that can be shown to the user */");
        outContent.writeln("class Strings");
        outContent.writeln("{");

        final xml.XmlDocument document = xml.XmlDocument.parse(inContent);

        outContent.writeln("    /* All supported languages */");
        outContent.writeln("");
        outContent.writeln("    static const List<String> app_languages = [");
        outContent.writeln('        /*en*/ "en",');
        for(int i = 0; i < TRANSLATIONS.length; i++)
        {
            outContent.writeln('        /*' + TRANSLATIONS[i] + '*/ "' + TRANSLATIONS[i] + (i + 1 < TRANSLATIONS.length ? '",' : '"];'));
        }
        outContent.writeln("");

        outContent.writeln("    /* Current language */");
        outContent.writeln("");
        outContent.writeln("    static int _language = 0;");
        outContent.writeln("    static int get language => _language;");
        outContent.writeln("    static void setLanguage(String language)");
        outContent.writeln("    {");
        outContent.writeln("        switch(language)");
        outContent.writeln("        {");
        outContent.writeln('            case "en": _language = 0; break;');
        for(int i = 0; i < TRANSLATIONS.length; i++)
        {
            outContent.writeln('            case "' + TRANSLATIONS[i] + '": _language = ' + (i + 1).toString() + '; break;');
        }
        outContent.writeln("            default: _language = 0; break;");
        outContent.writeln("        }");
        outContent.writeln("    }");

        final List<XmlElement> allStrings = document.findAllElements("string")
            .where((e) => e.children.isNotEmpty).toList();
        final List<XmlElement> allArrays = document.findAllElements("string-array")
            .where((e) => e.children.isNotEmpty).toList();

        outContent.writeln("");
        outContent.writeln("    /* Non-translatable attributes */");
        outContent.writeln("");
        allStrings.where((e) => e.getAttribute("translatable") == "false").forEach((element)
        {
            final String name = element.getAttribute("name");
            final XmlNode node = element.children.first;
            outContent.writeln('    static const String ' + name + ' = "' + node.toString() + '";');
        });

        outContent.writeln("");
        outContent.writeln("    /* Non-translatable arrays */");
        outContent.writeln("");
        allArrays.where((e) => e.getAttribute("translatable") == "false").forEach((element)
        {
            final String name = element.getAttribute("name");
            outContent.writeln('    static const List<String> ' + name + ' = [');
            int idx = 1;
            element.children.forEach((node)
            {
                idx++;
                if (node.children.length == 1)
                {
                    outContent.writeln('        "' + node.children.first.toString() + '"'
                        + (idx == element.children.length ? '];' : ','));
                }
            });
        });

        outContent.writeln("");
        outContent.writeln("    /* Translatable attributes */");
        allStrings.where((e) => e.getAttribute("translatable") != "false").forEach((element)
        {
            outContent.writeln("");
            final String name = element.getAttribute("name");
            final XmlNode node = element.children.first;
            outContent.writeln('    static const List<String> l_' + name + ' = [');
            outContent.writeln('        /*en*/ "' + node.toString() + '",');
            for (String tName in TRANSLATIONS)
            {
                final tDoc = inTranslations[tName];
                XmlElement tElement = tDoc.findAllElements("string").firstWhere(
                        (e) => e.getAttribute("name") == name, orElse: () => null);
                if (tElement == null)
                {
                    print("    ERROR: string " + name + " is not found in translation " + tName);
                    tElement = element;
                }
                final XmlNode tNode = tElement.children.first;
                outContent.writeln('        /*' + tName + '*/ "' + tNode.toString()
                    + (tName == TRANSLATIONS.last ? '"];' : '",'));
            };
            outContent.writeln('    static String get ' + name + ' => l_' + name + '[_language];');
        });

        outContent.writeln("");
        outContent.writeln("    /* Translatable arrays */");
        allArrays.where((e) => e.getAttribute("translatable") != "false").forEach((element)
        {
            outContent.writeln("");
            final String name = element.getAttribute("name");
            outContent.writeln('    static const List<List<String>> l_' + name + ' = [');
            _writeArray(outContent, "en", element, false);
            for (String tName in TRANSLATIONS)
            {
                final tDoc = inTranslations[tName];
                XmlElement tElement = tDoc.findAllElements("string-array").firstWhere(
                        (e)  => e.getAttribute("name") == name, orElse: () => null);
                if (tElement == null)
                {
                    print("    ERROR: array " + name + " is not found in translation " + tName);
                    tElement = element;
                }
                _writeArray(outContent, tName, tElement, tName == TRANSLATIONS.last);
            }
            outContent.writeln('    static List<String> get ' + name + ' => l_' + name + '[_language];');
        });
    });

    outContent.writeln("}");

   await File(outFile).writeAsString(outContent.toString());
}

void _writeArray(StringBuffer outContent, final String lan, final xml.XmlElement element, bool isLast)
{
    int idx = 1;
    element.children.forEach((node)
    {
        idx++;
        if (node.children.length == 1)
        {
            outContent.writeln(
                (idx == 3 ? '        /*' + lan + '*/ ["' : '                "')
                + node.children.first.toString() + '"'
                + (idx == element.children.length ? ']' + (isLast ? '];' : ',') : ','));
        }
    });
}
