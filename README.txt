OVERVIEW
--------
This is a patch for removing the default OS X behavior of _always_ starting
iTunes when the play button on the keyboard is pressed.  This feature can be
useful for a lot of users, but it can also be annoying if you are using VLC or
other similar programs that support the media keys.

The Patch script will patch the Remote Control Daemon to prevent it from starting
iTunes whenever you press the play button on the keyboard or an external remote
control. This will only prevent iTunes from starting, all other functions (like
play/pause while iTunes is _running_) will continue to work as before.

Lastly, this program will backup the original file in case if you would like to
restore the original functionality.



GENERAL INFORMATION
-------------------
Author: Farhan Ahmad <farhan@thebitguru.com>
Website: http://www.thebitguru.com/projects/iTunesPatch



CHANGE LOG
-------------------
2011-09-03	Farhan Ahmad	<farhan@thebitguru.com>
 * Added Michael Winestock's info.
	 http://www.linkedin.com/pub/michael-winestock/18/579/972

2011-08-18	Farhan Ahmad	<farhan@thebitguru.com>
 * Added a fix to account for spaces in the directory where the patch is
   uncompressed. Patch submitted by Michael Winestock.
 * Version changed to 0.8.

2010-11-28	Farhan Ahmad	<farhan@thebitguru.com>
 * Wrote a new python based patching script that dynamically patches the files
	 instead of using bspatch and relying on a pre-supplied patch file. This
	 should make the patch work with pretty much all versions of rcd.

2010-11-23	Farhan Ahmad	<farhan@thebitguru.com>
 * Packaged and released the first version.
