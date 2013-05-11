#!/usr/bin/env python
#
# Author: Farhan Ahmad
# Website: http://www.thebitguru.com/projects/iTunesPatch
# Description: This patches the iTunes launch commands in the rcd binary. This
#        program is expected to be executed by the provided Patch.command driver.
#        For more information please see the website for this project.
#
# Revision history:
#  2010-11-28, fa: Created

import mmap
import sys
import os.path

if len(sys.argv) != 2:
	print "%s rcd_filepath" % sys.argv[0]
	sys.exit(1)

rcd_filepath = sys.argv[1]

if not os.path.isfile(rcd_filepath):
	print "'%s' is not a valid file." % rcd_filepath
	sys.exit(2)

# String that needs to be commented out.
string_to_find = 'tell application id "com.apple.iTunes" to launch'
instances = []

with open(rcd_filepath, "r+b") as f:
	map = mmap.mmap(f.fileno(), 0)
	start = 0
	while True:
		found_at = map.find(string_to_find, start)
		if found_at == -1:
			break
		instances.append(str(found_at))
		map[found_at:found_at+2] = "--"
		start = found_at + len(string_to_find)
	map.close()

if len(instances) == 0:
	print "    Sorry, could not find any instances of the expected bytes to be patched."
	sys.exit(3)
else:
	print "    Successfully patched the file (found %s instances at %s)." % (
			len(instances), ", ".join(instances))

sys.exit(0)   # Return successful status.
