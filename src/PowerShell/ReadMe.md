# How to use the PowerShell Script <!-- omit in toc -->

- [Requirements](#requirements)
- [Using the Script](#using-the-script)
- [manifestConfig](#manifestconfig)
- [To Do](#to-do)
- [Takeaways or FAQ? IDK](#takeaways-or-faq-idk)

## Requirements

* If you are using PowerShell 7, your good to go.
* If you are using PowerShell 5 or below, you need [7-zip installed](https://www.7-zip.org/).

## Using the Script

1. Copy the `Generate-CurseExport.ps1` script and the `manifestConfig.json` to the root of the Minecraft folder. This would be the folder with the "config", "mods", "saves", etc. folders.
2. Open the `manifestConfig.json` and configure it how you'd like. [See below.](#manifestconfig)
3. Right-click the `Generate-CurseExport.ps1` script, and in the explorer context menu, click **Run with PowerShell**. Or if you have PowerShell 7 installed, click **Run With PowerShell 7**
4. A PowerShell window should open.
5. If you are asked something along the lines, do you want to run it, say yes.
6. Don't do anything with the zip or Minecraft folder while the PowerShell window is open; it's probably still making the zip. It will tell you when it's done.
7. Once closed, you should see a zip in the root of the Minecraft folder with the pack name, the version, and timestamp as to when it was generated; this avoids any issues with overriding; this will be your packaged mod pack. Please check your mods folder for any missing 3rd party mods. You can add the jar files to the mods folder in the archive.

## manifestConfig

I feel like this would be self-explanatory but:

* author: The person who is making the pack. That's probably you.
* packName: The name of the pack.
* versions:
    * minecraft: The version of MC that is required to play the pack.
    * forge: The version of forge you are using.
    * pack: The version of the pack. It doesn't really matter what you put here, but it's suitable for version control.
* overrides: These are the folders you would like to keep. In theory, this should work with files, but I haven't tested that yet. **Don't** add the mods folder. Any mods that aren't found on CurseForge will automatically be added to a mods folder in the override directory.

## To Do

* Make it so that you don't need the `manifestConfig.json`.
    * The script should detect that the JSON file is missing and ask the user questions to make the JSON, then execute as expected.

## Takeaways or FAQ? IDK

* What's this whole 5 or 7 thing with PowerShell?

Well, you see, I made this script using PowerShell 7.1, and everything worked. Most people have PowerShell 5.1, which comes with Windows 10. Compress-Archive is apparently broken in 5.1, which is where 7-zip comes into play.

* Okay, but why 7-zip?

Because I like 7-zip. Its free, open-source, and not that hard to use command line wise.
