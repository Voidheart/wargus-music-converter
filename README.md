# War1Gus Music Converter for Linux

This is a simple bash script that converts MIDI files to WAV and OGG and compresses them to OGG.GZ.

It was designed with War1Gus in mind, but it can be used for any game that uses MIDI files.

## Requirements

* Timidity
* FFmpeg

## Usage

1. Clone the repository and navigate to the directory.
2. Set the `WAR1GUS_PATH` environment variable to the path of your War1Gus directory.
3. Run `./musicWarTool.sh -m` to convert all MIDI files in the `music` directory to WAV and OGG and compress them to OGG.GZ.
4. Run `./musicWarTool.sh -c` to remove all non-MIDI files from the `music` directory. This will remove *.WAV, *.OGG, *.OGG.GZ files.
5. During clean up it will set the config back to .mid instead of .ogg

## Notes

* If the `WAR1GUS_PATH` environment variable is not set, the script will use the current working directory.
* The script will not overwrite existing files, so if you want to re-convert a file, you will need to delete the original file first.
