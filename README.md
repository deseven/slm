## Sins Localization Merger

This is a tool for merging two different localization files for the Sins of a Solar Empire game series.  
For example, you have a localized version of SoaSE and you want to play some nice mods. You install a mod and whoa - your localized version became an original english version.  
What this tool is actually do is just taking all possible strings from your localization and putting it into mod. So you'll get a semi-localized mod. This is also very useful for translation, because non-localized strings will be added to the end of the localization file.

## Compatibility
This tool will run on Windows 2000/XP/Vista/7 and it's compatible with all SoaSE versions as long as the file format remains the same.

## Usage
Simply run slm.exe and select Primary file (your localization file, can be found at [sins directory]\String\).  
Then select Secondary file (mod localization file, can be found at [mod directory]\String\).  
Finally, select Output file (you can select mod localization file for that to do on-the-fly convertion) and press GO!

The process can take a while on some computers, just wait while the tool told you that all operations are done.

## Possible problems
I didn't do any workarounds for different localization file formatting.

## Compilation
Use [PureBasic](http://purebasic.com/) version 4.50 or higher.
