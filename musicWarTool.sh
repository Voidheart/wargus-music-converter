#!/bin/bash
# musicWarTool.sh
# Version: 1.0
# Author: Plagueheart
# Date: 2024-09-07
#
# https://github.com/Plagueheart/wargus-music-converter
# War1gus music converter script
# Convert midi files to wav and compress to ogg.gz
# Requires:
#   timidity
#   ffmpeg
# usage: ./musicWarTool.sh [-m] [-c]
# export WAR1GUS_PATH=$(pwd)

workingDir=$(pwd)
if [ -z "${WAR1GUS_PATH}" ]; then
    echo "WAR1GUS_PATH enviroment variable is not set!"
    echo "Using working directory: $workingDir"
else
    workingDir="${WAR1GUS_PATH}"
fi

musicDir="${workingDir}/music"
scriptsDir="${workingDir}/scripts"

# check_prerequisites() - Checks if the required programs and directories exist.
#
# This function checks that the required programs timidity and ffmpeg are installed
# and that the music and scripts directories exist. If any of these checks fail,
# the script will exit with a status of 1.
check_prerequisites() {
    if ! command -v timidity &> /dev/null; then
        echo "Timidity is not installed. Please install it and try again."
        exit 1
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        echo "FFmpeg is not installed. Please install it and try again."
        exit 1
    fi
    
    if [ ! -d "$musicDir" ]; then
        echo "Error: $musicDir does not exist!"
        exit 1
    fi
    
    if [ ! -d "$scriptsDir" ]; then
        echo "Error: $scriptsDir does not exist!"
        exit 1
    fi
}

# Writes the music extension to the wc1-config.lua file.
#
# Args:
#   musicType (str): The music extension to write.
#
# Raises:
#   Exit: If the ${scriptsDir} or ${wc1config} does not exist.
write_config_value() {
    musicType="$1"
    wc1config="${scriptsDir}/wc1-config.lua"
    
    if [ ! -d "${scriptsDir}" ]; then
        echo "Error: ${scriptsDir} does not exist!"
        exit 1
    fi
    if [ ! -f "${wc1config}" ]; then
        echo "Error: ${wc1config} does not exist!"
        echo "Creating ${wc1config}..."
        echo "war1gus.music_extension = \"$musicType\"" > "${wc1config}"
        exit 1
    else
        sed -i "s/war1gus\.music_extension\s*=.*$/war1gus\.music_extension=\"$musicType\"/" "$wc1config"
    fi
}

# convert_music_file() - Converts a single MIDI file to WAV and OGG and compresses it.
#
# Args:
#   filename (str): The name of the MIDI file to convert.
#
# Raises:
#   Exit: If the conversion fails.
convert_music_file() {
    local filename="$1"
    local base="${filename%.mid}"
    
    if ! [[ -f "$base.wav" ]]; then
        echo "Converting MIDI file: $filename"
        timidity -Ow "$filename" -o "$base.wav"
    fi
    
    if ! [[ -f "$base.ogg" ]]; then
        ffmpeg -y -i "$base.wav" -c:a libvorbis "$base.ogg"
    fi
    
    # Compress only if a .ogg exists (avoids unnecessary checks)
    if [[ -f "$base.ogg" ]]; then
        echo "Compressing OGG file: $filename"
        gzip -c "$base.ogg" > "$base.ogg.gz"
    fi
}

# cleanup() - Removes all non-MIDI files from the music directory.
#
# Removes all non-MIDI files from the music directory, including WAV, OGG, and
# OGG.GZ files. This is useful for cleaning up after a conversion.
#
# Raises:
#   Exit: If the music directory does not exist.
cleanup() {
    shopt -s nullglob
    if [ ! -d "$musicDir" ]; then
        echo "Error: $musicDir does not exist!"
        exit 1
    fi
    rm -f "$musicDir"/*.{wav,ogg,ogg.gz}
    shopt -u nullglob
}

while getopts ":mc" opt; do
    case $opt in
        m)
            check_prerequisites
            for file in "$musicDir"/*.mid; do
                convert_music_file "$file"
            done
            write_config_value ".ogg"
        ;;
        c)
            check_prerequisites
            cleanup
            write_config_value ".mid"
        ;;
        \?)
            echo "Usage: $0 [-m] [-c]"
            echo "-m: Convert midi files to wav and compress to ogg.gz"
            echo "-c: Cleanup wav and ogg files"
            echo ""
            echo ""
            echo "Note: If WAR1GUS_PATH is not set, the current directory will be used."
            exit 1
        ;;
    esac
done
