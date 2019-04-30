#!/bin/bash
# Use ffmpeg to convert screencasts generated by kazam 1.4.5 'NCC-80102' to a format usable by Lightworks 14.0
ffmpeg -i "$1" -y -threads 7 -c:v libx264 -pix_fmt yuv420p -preset fast -crf 12 -f mov "$1".mov
