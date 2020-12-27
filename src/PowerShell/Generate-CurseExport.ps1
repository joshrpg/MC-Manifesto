$Source = @"
    using System;
    namespace murmur
    { 					
        public class murmurhash
        {
	        public static uint Hash(string data)
	        {
                byte[] dataByte=System.Text.Encoding.UTF8.GetBytes(data);
		        return Hash(dataByte);
	        }

	        public static uint Hash(byte[] data)
	        {
		        //return Hash(data, 0xc58f1a7a);
                int length = data.Length;
		        return Hash(Normalize(data), 1, length);
	        }

	        const uint m = 0x5bd1e995;
	        const int r = 24;
	        public static uint Hash(byte[] data, uint seed, int length)
	        {
		
		        if (length == 0)
			        return 0;
		        uint h = seed ^ (uint)length;
		        int currentIndex = 0;
		        while (length >= 4)
		        {
			        uint k = (uint)(data[currentIndex++] | data[currentIndex++] << 8 | data[currentIndex++] << 16 | data[currentIndex++] << 24);
			        k *= m;
			        k ^= k >> r;
			        k *= m;

			        h *= m;
			        h ^= k;
			        length -= 4;
		        }
		        switch (length)
		        {
			        case 3:
				        h ^= (UInt16)(data[currentIndex++] | data[currentIndex++] << 8);
				        h ^= (uint)(data[currentIndex] << 16);
				        h *= m;
				        break;
			        case 2:
				        h ^= (UInt16)(data[currentIndex++] | data[currentIndex] << 8);
				        h *= m;
				        break;
			        case 1:
				        h ^= data[currentIndex];
				        h *= m;
				        break;
			        default:
				        break;
		        }

		        h ^= h >> 13;
		        h *= m;
		        h ^= h >> 15;

		        return h;	
            }

	        public static byte[]  SubArray (byte[]  data, int index, int length)
            {
                byte[] result = new byte[length];
                Array.Copy(data, index, result, 0, length);
                return result;
            }

            public static byte[] Normalize(byte[] array){

                int bufferSize = array.Length;

                int contador=0;
		        byte c;
		
               for (int a = 0; a < bufferSize; a++){
			
                    c=array[a];        
				
                    if (!(c==9||c==10||c==13||c==32)) //No es espacio
                    {         
                        array[contador]=array[a];
				        contador++;
                    }
                 }
				
                return SubArray (array,0,contador);

            }


            public static uint HashNormalize(byte[] array){

                int bufferSize = array.Length;

                int contador=0;
		        byte c;
		
               for (int a = 0; a < bufferSize; a++){
			
                    c=array[a];        
				
                    if (!(c==9||c==10||c==13||c==32)) //No es espacio
                    {         
                        array[contador]=array[a];
				        contador++;
                    }
                 }
				
                return Hash (array,1,contador);

            }

        }
    }
"@
Add-Type -TypeDefinition $Source -Language CSharp

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}

# Requires a single file path to be passed to it
function Get-MurmurHash {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$FilePath
    )

    [Byte[]]$bytes = [IO.File]::ReadAllBytes($FilePath)
    $fingerPrint = [murmur.murmurhash]::HashNormalize($bytes)
    $fingerPrint.ToString()
}

function Get-ModFingerPrints {
    Param(
        [Parameter(Mandatory = $true)]
        [array]$Files
    )

    $i = 0
    $body = '['
    foreach ($file in $Files) {
        $hash = Get-MurmurHash -FilePath $file.FullName
        $body += $hash
        $mods.Add($hash, $file.FullName)

        $i++
        if (-not ($Files.Length -eq $i)) {
            $body += ','
        }
    }
    $body += ']'

    $body
    
    $response = Invoke-WebRequest https://addons-ecs.forgesvc.net/api/v2/fingerprint -ContentType "application/json" -Method POST -Body $body | ConvertFrom-Json
    $response.exactMatches
}

function Copy-Overrides {
    foreach ($override in $overrides) {
        $source = ($baseMinecraftDirectory + '\' + $override)
        $destination = ($workingDirectory + '\overrides\' + $override)
        
        if (Test-Path $source) {
            Copy-Item -Path $Source -Destination $Destination -Recurse
        }
        else {
            Write-Host "$source does not exist, skipping."
        }
    }

    if ($jarOverrides.Length -gt 0) {
        New-Item -ItemType Directory -Path ($workingDirectory + '\overrides\mods') -Force
        foreach ($jarOverride in $jarOverrides) {
            Copy-Item -Path $jarOverride -Destination ($workingDirectory + '\overrides\mods') -Force
        }
    }
}

function Build-Package {
    $shellVersion = 5 #$PSVersionTable.PSVersion.Major

    $timestamp = Get-Date -Format FileDateTime
    $workingDirectory = ($env:TEMP + "\CurseManifest_" + $timestamp)
    $archiveName = ($cfg.packName + '_' + $cfg.versions.pack)
    Copy-Overrides

    $manifest.files = $manifestFiles
    $manifest | ConvertTo-Json -Depth 100 | Out-File ($workingDirectory + '\manifest.json') -Encoding utf8NoBOM

    if ($shellVersion -eq 7) {
        $compress = @{
            Path            = ($workingDirectory + '\*')
            DestinationPath = ($baseMinecraftDirectory + '\' + $archiveName + '_' + $timestamp + '.zip')
        }

        Compress-Archive @compress 
    Compress-Archive @compress 
        Compress-Archive @compress 
    
        Remove-Item -Path $workingDirectory -Recurse -Force
    }
    else {
        Write-Host "PowerShell 7 was not detected. Looking for 7-zip."

        if (Test-Path HKLM:\SOFTWARE\7-Zip) {
            $7zip = (Get-ItemProperty -Path HKLM:\SOFTWARE\7-Zip).Path
            $destinationPath = ($baseMinecraftDirectory + '\' + $archiveName + '_' + $timestamp + '.zip')
            $path = ($workingDirectory + '\*')

            & $7zip\7z a -tzip $destinationPath $path
        }
        else {
            throw "7-zip was not detected, please install it."
        }
    }
}

$baseMinecraftDirectory = Get-ScriptDirectory

if (Test-Path (($baseMinecraftDirectory) + '\manifestConfig.json')) {
    $jarOverrides = @()
    $manifestFiles = @()
    
    $mods = $null
    $mods = @{}

    $cfg = Get-Content -Path (($baseMinecraftDirectory) + '\manifestConfig.json') | ConvertFrom-Json
    $overrides = $cfg.overrides

    $manifest = @{
        minecraft       = @{
            version    = $cfg.versions.minecraft
            modLoaders = @(
                @{
                    id      = $cfg.versions.forge
                    primary = $true
                }
            )
        }
        manifestType    = "minecraftModpack"
        manifestVersion = 1
        name            = $cfg.packName
        version         = $cfg.versions.pack
        author          = $cfg.author
        files           = @()
        overrides       = "overrides"
    }

    
    if (Test-Path (($baseMinecraftDirectory) + '\mods')) {
        $modFolder = ($baseMinecraftDirectory) + '\mods'
    }
    else {
        throw 'Mods folder was not detected. Exiting'
    }
    
    $modFiles = Get-ChildItem -Filter *.jar $modFolder
    
    $modFingerPrints = Get-ModFingerPrints -Files $modFiles
    
    $count = 0
    foreach ($modFingerPrint in $modFingerPrints) {
        if ($modFingerPrint.file.isAvailable -eq $false) {
            $jarOverrides += $mods[$modFingerPrint.file.packageFingerprint.ToString()]
        }
        else {
            if ($count -ne 0) {   
                $manifestFiles += @{
                    projectID = $modFingerPrint.file.projectId
                    fileID    = $modFingerPrint.file.id
                    required  = $true
                }
            }
            $count++
        }
    }
    
    Build-Package

    Write-Host -ForegroundColor Green -BackgroundColor Black "Hey, pack person. I'm done."
    Write-Host -ForegroundColor Green -BackgroundColor Black "Please check your mods folder for any missing 3rd party mods. You can simply add the jar files to the mods folder in the archive."
    Read-Host -Prompt "Press the 'any' key to close"
}
else {
    # do something else
}