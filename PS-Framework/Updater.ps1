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

#region 0: Clear Errors
$error.clear()
#endregion

#region 1: Global Definitions
$Validate = $True
$BaseDir = $env:windir + "\TEMP\PS\"
$LogFile = $BaseDir + "Output.txt"
$BaseURL = "http://mycloudrevolution.com/Projects/PS-Framework/"
$BaseXML = "Updater.xml"
Start-Transcript -Path $LogFile 
Write-Output "`nStarting with Config: $Config"
#endregion

#region 2: Check amd Create Path
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

#region 3: Download BaseXML
try {
    $Url = $BaseURL + $BaseXML 
    Invoke-WebRequest $Url -OutFile ($BaseDir + $BaseXML)
    }
catch {
    # Error out if loading fails
    $Validate = $false
    Write-Error "`nERROR: Failed to Download $BaseXML"  
}
#endregion

#region 4: Check and Load BaseXML
$BaseXMLPath = $BaseDir + $BaseXML
If (Test-Path $BaseXMLPath  ) {
    try {$BaseXMLContent = [XML] (Get-Content $BaseXMLPath )} catch {$Validate = $false; Write-Error "`nERROR: Invalid $BaseXML"}
    } Else {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Cannot load $BaseXML"
    }
#endregion

#region 5: Download Files from BaseXML
[Array] $BaseFiles =  $BaseXMLContent.Updater.Files.File
Foreach($BaseFile in $BaseFiles){
    try {
        $Url = $BaseURL + $BaseFile
        Invoke-WebRequest $Url -OutFile ($BaseDir + $BaseFile)
      }
    catch {
      # Error out if loading fails
       $Validate = $false
       Write-Error "`nERROR: Failed to Download $BaseFile"  
    }
}
#endregion

#region 6: Download Customer Files
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
    
#region 7: Start Base Script
if($Validate -eq $True) {
    $BaseScript = ($BaseXMLContent.Updater.Variable | Where-Object {$_.Name -eq "BaseScript"}).Value
    Write-Output "`nStarting $BaseDir$BaseScript"  
    Invoke-Expression ($BaseDir + $BaseScript)
    }
#endregion

#region 8: Finalize
Stop-Transcript

if($Validate -eq $false) {
    Write-Error "`nERROR: Validation Error(s) occured during Script!"
    }
#endregion