#!/bin/sh

# Source: https://winaero.com/blog/set-exact-display-resolution-in-virtualbox-virtual-machine/

# The VM must be running and have the Guest Additions installed.
# Used for a specific VM with specific settings.

# Looks like these are not the VM viewport dimensions, so added 16 to width (1770) and 82 to height (846)

# These probably need to be set once for all subsequent setvideomodehints?!
VBoxManage setextradata global GUI/MaxGuestResolution any
VBoxManage setextradata "LaTeX_Xubuntu_14.04" "1786 x 928 x 32"

# This should be the actual command for setting the new VM resolution
VBoxManage controlvm "LaTeX_Xubuntu_14.04" setvideomodehint 1786 928 32

