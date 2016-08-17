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

    Module-Name: myExample
    Module Version: 1.0
#>

#region 1: Global Definitions
$Validate = $True
$myExampleScriptXML = "myExample.xml"
#endregion

#region 2: Check and Load myExampleXML
$myExampleScriptXMLPath = $BaseDir + $myExampleScriptXML
If (Test-Path $myExampleScriptXMLPath  ) {
    try {$myExampleScriptXMLContent = [XML] (Get-Content $myExampleScriptXMLPath )} catch {$Validate = $false; Write-Error "`nERROR: Invalid $myExampleScriptXML"}
    } Else {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Cannot load $myExampleScriptXML"
    }
#endregion

#region 3: Do myExample
if($Validate -eq $True) {
    $Text = ($myExampleScriptXMLContent.myExample.Variable | Where-Object {$_.Name -eq "Text"}).Value
    try {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("$Text",0,"Done",0x1)
    }
    catch {
        # Error out if loading fails
        $Validate = $false
        Write-Error "`nERROR: Failed to Create Popup."  
        }

}
#endregion