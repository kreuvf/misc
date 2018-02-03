# For every file, create a new .tags file
# sh is needed for proper redirection

# NOTE
# Does not work with filenames containing double quotes (")
# Bash scripting and its ultra-weird quoting/escaping shit should just die
# Man, how I hate this shit.

# We remove any empty entries and replay gain entries of 0.0

find . -regextype posix-extended -regex '.*\.ogg$' -exec sh -c 'soxi -a "{}" | grep --invert-match -E '\''=$'\'' | grep --invert-match -E '\''^REPLAYGAIN.*0(\.0+)?$'\'' > "{}".tags' \;
