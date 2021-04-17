$JSONFile = @(
    [pscustomobject]@{
        Type="Mod";
        Name="Just Enough Resources";
        ProjectID="240630";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Mod";
        Name="Just Enough Items";
        ProjectID="238222";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Mod";
        Name="Mouse Tweaks";
        ProjectID="60089";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Mod";
        Name="JourneyMap";
        ProjectID="32274";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Mod";
        Name="Create";
        ProjectID="328085";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Mod";
        Name="Morpheus";
        ProjectID="69118";
        MinecraftVersion="1.16.5"
    },
    [pscustomobject]@{
        Type="Config";
        Name="KLT Modpack Customization";
        URL="https://drive.google.com/uc?export=download&id=13DuZCZfuU-0L9Sp3cwr4w-T8bbBU9jyL"
    }
)

<#

    Title: Dynamic Forge Modpack Downloader
    Author: KingLinkTiger
    Date: 17APR21
    Version: 1

    v1
    - Initial

    Sources:
        https://gist.github.com/crapStone/9a423f7e97e64a301e88a2f6a0f3e4d9 
            -Unofficial Curse API Documentation
        https://lifehacker.com/share-direct-links-to-files-in-google-drive-and-skip-th-1493813665
            -Google Drive links need to NOT use the web viewer otherwise the Zip will be corrupt...

    JSON File Format
        JSON
            Type: Mod
                Project ID
                File ID (Optional)
                    If provided the script will download the specific file provided
                Minecraft Version
                    If file ID is not provided we will find the file that supports the supplied version
                    Future: Support "Latest"?
            Type: Config
                This will download a zip file of the customized config files, placing them in the correct directory, OVERWRITING files as needed.
                URL
                    URL to the ZIP file containing the Config files

    ToDo
    - Make script use external JSON file for mods and configs
    - Add versioning checks to the config download. Currently it downloads every time...
    - Add the ability to customize the MultiMC Instance icon (Default path is .minecraft/icon.png)
#>

function Get-Mod{

    param(
        [Parameter(Mandatory=$true)]
        $ProjectID,
        [Parameter(Mandatory=$true, ParameterSetName="Default")]
        $MinecraftVersion,
        [Parameter(Mandatory=$true, ParameterSetName="FileID")]
        $FileID
    )

        $Content = (Invoke-WebRequest -Uri "https://addons-ecs.forgesvc.net/api/v2/addon/$($ProjectID)/files").Content
        $Content = $Content | ConvertFrom-Json

        $TempMod = @()


        foreach($file in $Content){          
            if($file.gameVersion.Contains($item.MinecraftVersion)){
                $TempMod += $file
            }
        }

        #Process Mod
        
        $ModToDownload = ($TempMod | Sort-Object -Property fileDate -Descending | Select-Object -First 1)
        #Write-Debug $ModToDownload

        #If there are dependancies recursivelly process them
        if($ModToDownload.dependencies -ne $null){
            foreach($dependency in $ModToDownload.dependencies){
                #IDK what the Type field is but a type of 4 appears to be an external not required tool. 3 appears to be normal
                if($dependency.type -eq 3){
                    Get-Mod -ProjectID $dependency.addonId -MinecraftVersion $MinecraftVersion
                }
            }
        }
        
        #Download the Mod :D
        #Check if we have this mod downloaded already. This will be an issue if the user explicitly supplied a dependancy
        #Will also need to check for download by name in case the explicitly supplied a dependancy but a specific/different version
        return $ModToDownload.downloadURL

}

#Prompt the user to provide the directory to their .minecraft folder. This will be used to save the mods and/or configs
$OutputDirectory = Read-Host -Prompt "Please enter the path to your .minecraft Directory. This will normally be the root of your MultiMC."

$downloadURLs = $null

#region Process the Mods

    foreach($item in ($JSONFile | Where-Object -Property Type -eq -Value "Mod")){
        $downloadURLs += Get-Mod -ProjectID $item.ProjectID -MinecraftVersion $item.MinecraftVersion
    }

    #region Download the Mods
    foreach($downloadURL in $downloadURLs){
        $FileName = $downloadURL.split("/")[-1]
        #If the mod is not already downloaded download it.
        if(-not (Test-Path -Path "$OutputDirectory\mods\$FileName")){
            Invoke-WebRequest -Uri $downloadURL -OutFile "$OutputDirectory\mods\$FileName"
        }else{
            Write-Debug "Skipping download"
        }
    }
    #endregion
#endregion

#region Process the Config Files
    foreach($item in ($JSONFile | Where-Object -Property Type -eq -Value "Config")){
    
        #Download Config Zip to Config.Zip so we can call it by name
        Invoke-WebRequest -Uri $item.URL -OutFile "$OutputDirectory\Config.zip"

        #Extract it to $OutputDirectory. Overwriting files
        Expand-Archive -Path "$($OutputDirectory)\Config.zip" -DestinationPath $($OutputDirectory) -Force

        #Delete Zip
        Remove-Item -Path "$($OutputDirectory)\Config.zip"
    }
#endregion
