#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 ~ 2012 Deepin, Inc.
#               2011 ~ 2012 Wang Yong
# 
# Author:     Wang Yong <lazycat.manatee@gmail.com>
# Maintainer: Wang Yong <lazycat.manatee@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/usr/bin/python
# Interface to the commandline version of mediainfo to read stream information

import sys
import subprocess
from pprint import pprint

MEDIAINFO='mediainfo'

# Media has a container, and then video, audio and text streams

# Lines to parse
#General
#Format                           : Matroska
#Codec                            : Matroska
#File size                        : 2416672563
#Overall bit rate                 : 3206541
#Duration                         : 6029357
#
#Video
#Format                           : AVC
#Codec ID                         : V_MPEG4/ISO/AVC
#Codec                            : V_MPEG4/ISO/AVC
#Duration                         : 6023333
#Nominal bit rate                 : 2971000
#Width                            : 960
#Height                           : 720
#Display aspect ratio             : 1.778
#Pixel Aspect Ratio               : 1.000
#Frame rate                       : 23.976
#Scan type                        : Progressive
#
#Audio
#Format                           : AAC
#Codec ID                         : A_AAC
#Codec                            : A_AAC/MPEG4/LC
#Duration                         : 6029357
#Bit rate mode                    : VBR
#Bit rate                         : 129720
#Channel(s)                       : 6
#Sampling rate                    : 48000
#Resolution                       : 16
#Language                         : eng
#
#Text #1
#Format                           : ASS
#Codec ID                         : S_TEXT/ASS
#Codec                            : S_TEXT/ASS
#Language                         : eng

def set_par(dict, index, value):
    if (not dict.has_key(index)) or dict[index] is None or dict[index] == '':
        dict[index] = value

def parse_info(filename):
    """ Parses media info for filename """
    args = [MEDIAINFO, '-f', filename]
    output = subprocess.Popen(args, stdout=subprocess.PIPE).stdout
    data = output.readlines()
    output.close()
    mode = 'none'
    result = {
            'general_format' : '',
            'general_codec' : '',
            'general_size' : None,
            'general_bitrate' : None,
            'general_duration' : None,
            'general_extension' : None,
            'video_format' : '',
            'video_codec_id' : '',
            'video_codec' : '',
            'video_bitrate' : None,
            'video_width' : None,
            'video_height' : None,
            'video_displayaspect' : None,
            'video_pixelaspect' : None,
            'video_scantype' : '',
            'audio_format' : '',
            'audio_codec_id' : '',
            'audio_codec' : '',
            'audio_bitrate' : None,
            'audio_channels' : None,
            'audio_samplerate' : None,
            'audio_resolution' : None,
            'audio_language' : '',
            }
    for line in data:
        if not ':' in line:
            if 'General' in line:
                mode = 'General'
            elif 'Video' in line:
                mode = 'Video'
            elif 'Audio' in line:
                mode = 'Audio'
            elif 'Text' in line:
                mode = 'Text'
        else:
            key, sep, value = line.partition(':')
            key = key.strip()
            value = value.strip()
            if mode == 'General':
                if key == 'Format': set_par(result, 'general_format', value)
                if key == 'Codec': set_par(result,'general_codec', value)
                if key == 'File size': set_par(result,'general_size', value)
                if key == 'Overall bit rate': set_par(result,'general_bitrate', value)
                if key == 'Duration': set_par(result,'general_duration', value)
                if key == 'File extension': set_par(result,'general_extension', value)
            if mode == 'Video':
                if key == 'Format': set_par(result,'video_format', value)
                if key == 'Codec ID': set_par(result,'video_codec_id', value)
                if key == 'Codec': set_par(result,'video_codec', value)
                if key == 'Nominal bit rate': set_par(result,'video_bitrate', value)
                if key == 'Width': set_par(result,'video_width', value)
                if key == 'Height': set_par(result,'video_height', value)
                if key == 'Display aspect ratio': set_par(result,'video_displayaspect', value)
                if key == 'Pixel Aspect Ratio': set_par(result,'video_pixelaspect', value)
                if key == 'Scan type': set_par(result,'video_scantype', value)
            if mode == 'Audio':
                if key == 'Format': set_par(result,'audio_format', value)
                if key == 'Codec ID': set_par(result,'audio_codec_id', value)
                if key == 'Codec': set_par(result,'audio_codec', value)
                if key == 'Bit rate': set_par(result,'audio_bitrate', value)
                if key == 'Channel(s)': set_par(result,'audio_channels', value)
                if key == 'Sampling rate': set_par(result,'audio_samplerate', value)
                if key == 'Resolution': set_par(result,'audio_resolution', value)
                if key == 'Language': set_par(result,'audio_language', value)
    return result

if __name__ == '__main__':
    print sys.argv[1]
    r = parse_info(sys.argv[1])
    pprint(r)
