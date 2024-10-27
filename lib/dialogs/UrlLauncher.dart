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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import "../utils/Logging.dart";
import "PopupManager.dart";

class UrlLauncher
{
    static void launchURL(final String url, {String? errorMsg, final GlobalKey<ScaffoldMessengerState>? toastKey}) async
    {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri))
        {
            await launchUrl(uri);
            return;
        }
        Logging.info(url, "Cannot launch URL: " + url);
        if (errorMsg != null && toastKey != null)
        {
            PopupManager.showToast(errorMsg, toastKey: toastKey);
        }
    }
}