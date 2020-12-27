# How to use the PowerShell Script <!-- omit in toc -->

1. Copy the `Generate-CurseExport.ps1` script and the `manifestConfig.json` to the root of the Minecraft folder. This would be the folder with the "config", "mods", "saves", etc. folders.
2. Open the `manifestConfig.json` and configure it how you'd like.
3. Right click the `Generate-CurseExport.ps1` script and in the explorer context menu click **Run with PowerShell**.
4. A PowerShell window should open.
5. If you are asked something along the lines of do you want to run it, just say yes.
6. Don't do anything with the zip or Minecraft folder while the PowerShell window is open, it's probably still making the zip.
7. Once closed, you should see a zip in the root of the Minecraft folder with the pack name, the version, and a time stamp as to when it was generated, this aviods any issues with overriding, this will be your packaged modpack.

## manifestConfig

I feel like this would be self explanatory but:

* author: The person who is making the pack. That's probably you.
* packName: The name of the pack.
* versioins:
    * minecraft: The version of MC that is required to play the pack.
    * forge: The version of forge you are using.
    * pack: the version of the pack, it doesn't really matter what you put here but its good for version control.
* overrides: These are the folders you would like to keep. In theory this should work with files but I haven't tested that yet. **Don't** add the mods folder. Any mods that aren't found on CurseForge will automatically be added to a mods folder in the override directory.

## ToDo

* Make it so that you don't need the `manifestConfig.json`.
    * The script should detect that the json file is missing and ask the user questions to make the json, then execute as normal.
