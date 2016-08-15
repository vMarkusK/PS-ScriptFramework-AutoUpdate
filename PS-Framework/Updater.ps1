<#	
	.NOTES
    ===========================================================================
    Created by: Markus Kraus
    Organization: mycloudrevolution.com
    Personal Blog:  mycloudrevolution.com
    Twitter: @vMarkus_K
    ===========================================================================
	.DESCRIPTION
    This is a self updating PowerShell Script Framework.
    
    Module-Name: Updater
    Module Version: 1.0
#>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False,Position=1)]
   [string] $Config = "Default"
)  

#region: Clear Errors
$error.clear()
#endregion

#region: Global Definitions
$Validate = $True
$BaseDir = $env:windir + "\TEMP\PS\"
$LogFile = $BaseDir + "Output.txt"
$BaseURL = "http://mycloudrevolution.com/Projects/PS-Framework/"
$BaseXML = "Updater.xml"
$BasePS1 = "Updater.ps1"
Start-Transcript -Path $LogFile 
Write-Output "`nStarting with Config: $Config"
#endregion

#region: Check amd Create Path
if (!(Test-Path -path $BaseDir)) {
    try {
        New-Item -ItemType directory -Path $BaseDir
        }
    catch {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Failed to Create $BaseDir"  
    }
}
#endregion

#region: Download BaseXML
try {
    $Url = $BaseURL + $BaseXML 
    Invoke-WebRequest $Url -OutFile ($BaseDir + $BaseXML) -ErrorAction Stop
    }
catch {
    # Error out if loading fails
    $Validate = $false
    Write-Error "`nERROR: Failed to Download $BaseXML"  
}
#endregion

#region: Download BasePS1
try {
    $Url = $BaseURL + $BasePS1
    Invoke-WebRequest $Url -OutFile ($BaseDir + $BasePS1) -ErrorAction Stop
    }
catch {
    # Error out if loading fails
    $Validate = $false
    Write-Error "`nERROR: Failed to Download $BasePS1"  
}
#endregion


#region: Check and Load BaseXML
$BaseXMLPath = $BaseDir + $BaseXML
If (Test-Path $BaseXMLPath  ) {
    try {$BaseXMLContent = [XML] (Get-Content $BaseXMLPath )} catch {$Validate = $false; Write-Error "`nERROR: Invalid $BaseXML"}
    } Else {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Cannot load $BaseXML"
    }
#endregion

#region: Download Files from BaseXML
[Array] $BaseFiles =  $BaseXMLContent.Updater.Files.File
Foreach($BaseFile in $BaseFiles){
    try {
        $Url = $BaseURL + $BaseFile
        Invoke-WebRequest $Url -OutFile ($BaseDir + $BaseFile) -ErrorAction Stop
      }
    catch {
      # Error out if loading fails
       $Validate = $false
       Write-Error "`nERROR: Failed to Download $BaseFile"  
    }
}
#endregion

#region: Download Customer Files
if ($Config -ne "Default") {
    [Array] $ConfigFiles = @("Customer-" + $Config + ".xml"; "Customer-" + $Config + ".ps1")
    Foreach($ConfigFile in $ConfigFiles){
        try {
            $Url = $BaseURL + $ConfigFile
            Invoke-WebRequest $Url -OutFile ($BaseDir + $ConfigFile)
        }
        catch {
            # Error out if loading fails
            $Validate = $false
            Write-Error "`nERROR: Failed to Download $ConfigFile"  
        }
    }
 }
#endregion    

#region: Updater Check
$myFile = $MyInvocation.MyCommand.Path
$myFileHash = (Get-FileHash -Path $myFile).Hash
$newFile = ($BaseDir + $BasePS1)
$newFileHash = (Get-FileHash -Path $newFile).Hash

Write-Output "`nMy Updater File: $myFile"
Write-Output "My Updater File Hash: $myFileHash"
Write-Output "New Updater File: $newFile"
Write-Output "My Updater File Hash: $newFileHash"

if ($myFileHash -ne $newFileHash) {
    try {
        Copy-Item $newFile -Destination $($myFile + ".new")
        Write-Warning "Replacing local Updater.ps1 with Server Version. Exiting this Version and wait for next run..."
        Stop-Transcript
        Exit
    }
    catch {
            # Error out if replacing fails
            $Validate = $false
            Write-Error "`nERROR: Failed to Update Update.ps1"  
        } 
}
#endregion

#region: Start Base Script
if($Validate -eq $True) {
    $BaseScript = ($BaseXMLContent.Updater.Variable | Where-Object {$_.Name -eq "BaseScript"}).Value
    Write-Output "`nStarting $BaseDir$BaseScript"  
    Invoke-Expression ($BaseDir + $BaseScript)
    }
    else {
        Write-Warning "Starting $BaseDir$BaseScript skipped... Validation Error." 
    }
#endregion

#region: Finalize
Stop-Transcript

if($Validate -eq $false) {
    Write-Error "`nERROR: Validation Error(s) occured during Script!"
    }
#endregion