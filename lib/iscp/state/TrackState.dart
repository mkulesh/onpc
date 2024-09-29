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

import "package:flutter/widgets.dart";

import "../../utils/Logging.dart";
import "../ConnectionIf.dart";
import "../ISCPMessage.dart";
import "../messages/AlbumNameMsg.dart";
import "../messages/ArtistNameMsg.dart";
import "../messages/AudioInformationMsg.dart";
import "../messages/DcpMediaItemMsg.dart";
import "../messages/FileFormatMsg.dart";
import "../messages/JacketArtMsg.dart";
import "../messages/TimeInfoMsg.dart";
import "../messages/TitleNameMsg.dart";
import "../messages/TrackInfoMsg.dart";
import "../messages/VideoInformationMsg.dart";
import "../messages/XmlListItemMsg.dart";

class TrackState
{
    late String _album;

    String get album
    => _album;

    late String _artist;

    String get artist
    => _artist;

    late String _title;

    String get title
    => _title;

    late String _fileFormat;

    String get fileFormat
    => _fileFormat;

    late String _currentTime;

    String get currentTime
    => _currentTime;

    late String _maxTime;

    String get maxTime
    => _maxTime;

    late int _currentTrack;

    int get currentTrack
    => _currentTrack;

    set currentTime(value)
    {
        _currentTime = value;
    }

    late int _maxTrack;

    int get maxTrack
    => _maxTrack;

    // Cover Image
    OnProcessFinished? _coverDownloadFinished;

    set coverDownloadFinished(OnProcessFinished value)
    {
        _coverDownloadFinished = value;
    }

    Image? _cover;

    Image? get cover
    => _cover;

    late bool _coverPending;

    bool get isCoverPending
    => _coverPending;

    String? _coverUrl;
    final List<int> _coverBuffer = [];

    // Audio/Video information
    late String _avInfoAudioInput;

    String get avInfoAudioInput
    => _avInfoAudioInput;

    late String _avInfoAudioOutput;

    String get avInfoAudioOutput
    => _avInfoAudioOutput;

    late String _dcpAudioFormat, _dcpAudioFreq;

    late String _avInfoVideoInput;

    String get avInfoVideoInput
    => _avInfoVideoInput;

    late String _avInfoVideoOutput;

    String get avInfoVideoOutput
    => _avInfoVideoOutput;

    TrackState()
    {
        clear();
    }

    List<String> getQueries()
    {
        Logging.info(this, "Requesting data...");
        return [
            AlbumNameMsg.CODE, ArtistNameMsg.CODE, TitleNameMsg.CODE,
            FileFormatMsg.CODE, TimeInfoMsg.CODE, TrackInfoMsg.CODE
        ];
    }

    List<String> getAvInfoQueries()
    {
        Logging.info(this, "Requesting audio/video info...");
        return [ AudioInformationMsg.CODE, VideoInformationMsg.CODE ];
    }

    void clear()
    {
        _album = "";
        _artist = "";
        _title = "";
        _fileFormat = "";
        _currentTime = TimeInfoMsg.INVALID_TIME;
        _maxTime = TimeInfoMsg.INVALID_TIME;
        _currentTrack = TrackInfoMsg.INVALID_TRACK;
        _maxTrack = TrackInfoMsg.INVALID_TRACK;
        _cover = null;
        _coverUrl = null;
        _coverBuffer.clear();
        _coverPending = false;
        _avInfoAudioInput = "";
        _avInfoAudioOutput = "";
        _dcpAudioFormat = "";
        _dcpAudioFreq = "";
        _avInfoVideoInput = "";
        _avInfoVideoOutput = "";
    }

    bool processAlbumName(AlbumNameMsg msg)
    {
        final bool changed = _album != msg.getData;
        _album = msg.getData;
        return changed;
    }

    bool processArtistName(ArtistNameMsg msg)
    {
        final bool changed = _artist != msg.getData;
        _artist = msg.getData;
        return changed;
    }

    bool processTitleName(TitleNameMsg msg)
    {
        final bool changed = _title != msg.getData;
        _title = msg.getData;
        return changed;
    }

    bool processFileFormat(FileFormatMsg msg)
    {
        final bool changed = _fileFormat != msg.getFullFormat();
        _fileFormat = msg.getFullFormat();
        return changed;
    }

    bool processTimeInfo(TimeInfoMsg msg)
    {
        final bool changed = _currentTime != msg.getCurrentTime || _maxTime != msg.getMaxTime;
        _currentTime = msg.getCurrentTime;
        _maxTime = msg.getMaxTime;
        return changed;
    }

    bool processTrackInfo(TrackInfoMsg msg)
    {
        final bool changed = _currentTrack != msg.getCurrentTrack || _maxTrack != msg.getMaxTrack;
        _currentTrack = msg.getCurrentTrack;
        _maxTrack = msg.getMaxTrack;
        return changed;
    }

    bool processJacketArt(ProtoType protoType, JacketArtMsg msg, bool isOn)
    {
        if (msg.getImageType == ImageType.URL && msg.url != null)
        {
            if (protoType == ProtoType.DCP && _coverUrl != null && _coverUrl == msg.url)
            {
                Logging.info(msg, "Cover image already loaded, reload skipped");
                return false;
            }
            _coverPending = isOn;
            _coverUrl = msg.url;
            msg.loadFromUrl().then((image)
            {
                _cover = image;
                _coverPending = false;
                if (_coverDownloadFinished != null)
                {
                    Logging.info(this, "image loaded: " + msg.url!);
                    _coverDownloadFinished!(true, JacketArtMsg.CODE);
                }
            });
            return true;
        }
        else if (msg.getRawData != null)
        {
            bool doReport = false;
            if (msg.getPacketFlag == PacketFlag.START)
            {
                Logging.info(msg, "processing raw stream...");
                _coverPending = true;
                _coverBuffer.clear();
                doReport = true;
            }
            _coverBuffer.addAll(msg.getRawData!);
            if (msg.getPacketFlag == PacketFlag.END)
            {
                Logging.info(msg, "Cover image size length=" + _coverBuffer.length.toString() + "B");
                _cover = msg.loadFromBuffer(_coverBuffer);
                _coverUrl = null;
                _coverPending = false;
                _coverBuffer.clear();
                doReport = true;
            }
            return doReport;
        }
        else
        {
            Logging.info(msg, "ignored");
        }
        return false;
    }

    bool processAudioInformation(AudioInformationMsg msg)
    {
        switch (msg.updateType)
        {
            case AudioInformationUpd.ALL:
                final bool changed = _avInfoAudioInput != msg.audioInput
                    || _avInfoAudioOutput != msg.audioOutput;
                _avInfoAudioInput = msg.audioInput;
                _avInfoAudioOutput = msg.audioOutput;
                return changed;
            case AudioInformationUpd.DCP_FORMAT:
                final bool changed = _dcpAudioFormat != msg.audioInput;
                _dcpAudioFormat = msg.audioInput;
                _avInfoAudioInput = _dcpAudioFormat + " " + _dcpAudioFreq;
                return changed;
            case AudioInformationUpd.DCP_FREQ:
                final bool changed = _dcpAudioFreq != msg.frequency;
                _dcpAudioFreq = msg.frequency;
                _avInfoAudioInput = _dcpAudioFormat + " " + _dcpAudioFreq;
                return changed;
        }
    }

    bool processVideoInformation(VideoInformationMsg msg)
    {
        switch (msg.updateType)
        {
            case VideoInformationUpd.ALL:
                final bool changed = _avInfoVideoInput != msg.videoInput
                  || _avInfoVideoOutput != msg.videoOutput;
                _avInfoVideoInput = msg.videoInput;
                _avInfoVideoOutput = msg.videoOutput;
                return changed;
            case VideoInformationUpd.DCP_INPUT:
                final bool changed = _avInfoVideoInput != msg.videoInput;
                _avInfoVideoInput = msg.videoInput;
                return changed;
            case VideoInformationUpd.DCP_OUTPUT:
                final bool changed = _avInfoVideoOutput != msg.videoOutput;
                _avInfoVideoOutput = msg.videoOutput;
                return changed;
        }
    }

    void processXmlListItem(final List<ISCPMessage> list)
    {
        for (int i = 0; i < list.length; i++)
        {
            final ISCPMessage m = list[i];
            if (m is XmlListItemMsg && m.getIcon.key == ListItemIcon.PLAY)
            {
                _currentTrack = i + 1;
                _maxTrack = list.length;
                return;
            }
        }
    }

    String getListeningModeFromAvInfo()
    {
        final List<String> aTerms = avInfoAudioInput.split(",");
        return aTerms.length > 1 ? aTerms[1] : "Unknown";
    }

    /*
     * Denon control protocol
     */
    bool processDcpMediaItemMsg(DcpMediaItemMsg msg)
    {
        bool changed = _currentTrack != msg.qid;
        _currentTrack = msg.qid;
        if (_currentTrack == DcpMediaItemMsg.INVALID_TRACK)
        {
            if (_maxTrack != TrackInfoMsg.INVALID_TRACK)
            {
                changed = true;
            }
            _maxTrack = TrackInfoMsg.INVALID_TRACK;
        }
        return changed;
    }
}