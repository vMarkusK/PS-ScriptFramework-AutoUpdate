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
    
    Module-Name: BaseScript
    Module Version: 1.0
#>

#region 1: Global Definitions
$Validate = $True
$BaseScriptXML = "BaseScript.xml"
#endregion

#region 2: Check and Load BaseXML
$BaseScriptXMLPath = $BaseDir + $BaseScriptXML
If (Test-Path $BaseXMLPath  ) {
    try {$BaseScriptXMLContent = [XML] (Get-Content $BaseScriptXMLPath )} catch {$Validate = $false; Write-Error "`nERROR: Invalid $BaseScriptXML"}
    } Else {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Cannot load $BaseScriptXML"
    }
#endregion

#region 3: Base Script Invokes
if($Validate -eq $True) {
    [Array] $Scripts =  $BaseScriptXMLContent.BaseScript.Scripts.Script
    Foreach($Script in $Scripts){
        try {
            Write-Output "`nStarting $BaseDir$Script"  
            Invoke-Expression ($BaseDir + $Script)
        }
        catch {
            # Error out if loading fails
            $Validate = $false
            Write-Error "`nERROR: Failed to Start $Script in $BaseDir"  
            }
    }
}
#endregion

#region 4: Finalize
if($Validate -eq $false) {
    Write-Error "`nERROR: Validation Error(s) occured during Script!"
    }
#endregion
