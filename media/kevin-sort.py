#!/usr/bin/env python3

# Kevin MacLeod New Title Sorter
# Kevin MacLeod (incompetech.com) has a list of all the tracks on his site.
# Around once a year I hear my way through all of them to rate them and save
# the ones I like. Since there is no other way and I do this so seldomly I
# manually copy & paste the list from his site and do the same with the table
# I have stored locally. The script does the rest.
#
# Author: Steven 'Kreuvf' Koenig
# Created: 2018-07-29
# Licence: Creative Commons Attribution 4.0 International Public License

# Inputs
# Text files with one title followed by a tab followed by the ISRC: USUAN...
# identifier per line.
# Requires one file "old.txt" and one file "new.txt" in the directory it is called in.

with open("old.txt", mode = "r", encoding = "utf8") as f:
	oldkev = f.read().splitlines()

with open("new.txt", mode = "r", encoding = "utf8") as f:
	newkev = f.read().splitlines()

with open("really_new.txt", mode = "w", encoding = "utf8") as f:
	for piece in newkev:
		if not(piece in oldkev):
			f.write(piece + "\n")

# Just out of curiosity, let's look whether old ones were dropped ...
for piece in oldkev:
	if not(piece in newkev):
		print("'{}' has been dropped! D:".format(piece))

