# Dynamic-Forge-Modpack-Downloader

## Intro
This PowerShell script is designed to automatically download a dynamically changing Forge modpack based on a JSON file containing a list of Forge Mods. This script will also download configuration files, overwriting any default files provided by the mods.

## Requirements
* Operating System: Windows
* Windows Management Framework 5.1+ (https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/install/windows-powershell-system-requirements)
  * Note: This is installed by default on Windows 10 1607+
* Minecraft Client: MultiMC (https://multimc.org/)
* Internet Connection

## Instructions
1. Download and install MultiMC (If not already installed)
2. Create a MultiMC instance for the modpack
3. Install Forge for the MultiMC Instance
4. Copy the path to the .minecraft directory for the MultiMC Instance
5. Download this script
6. Run this script
7. When asked provide the path to the MultiMC Instance that you copied earlier
8. Wait for the script to finish
9. Complete
