<#
.SYNOPSIS
  De-obfuscates a LastPass Vault file obtained using the following code snippet in Developer Tools of your browser
  (ref: https://palant.info/2022/12/24/what-data-does-lastpass-encrypt/)

  fetch("https://lastpass.com/getaccts.php", {method: "POST"})
  .then(response => response.text())
  .then(text => console.log(text.replace(/>/g, ">\n")));

 Look carefully at the bottom of the page where Chrome or Edge will be saying “Show More” and also offering a “Copy”
 button. Click “Copy” to move all of that query response data onto your machine’s clipboard, and save this into a blank text file 
 with .xml extension

.DESCRIPTION
  Highlights the amount of data lost in the recent lastpass breach as disclosed 22/12/2022
  https://blog.lastpass.com/2022/12/notice-of-recent-security-incident/

  Use the -Verbose paramter to show output on screen as well as export to a new file


  
.PARAMETER LastPassVaultXML
  The XML file representing your lastpass vault as saved using the code snippet above

.PARAMETER OutputFile
  The resulting output file path. If omitted will be saved in the userprofile desktop

.INPUTS

.OUTPUTS
  XML document with de-obfuscated data

.NOTES
  Version:          0.1
  Author:           Aaron Mountford
  Creation Date:    05/01/2022


.EXAMPLE
  .\Convert-LastPassValut.ps1 -LastPassVaultXML c:\temp\lpv.xml

Import the specified file, an output file will be saved at "%USERPROFILE%\desktop\lpv-deobfuscated.xml"

.EXAMPLE
.\Convert-LastPassValut.ps1 -LastPassVaultXML c:\temp\lpv.xml -OutputFile "c:\temp\lastpass-deobfuscated.xml"

Import the specified file, an output file will be saved at c:\temp\lastpass-deobfuscated.xml

.EXAMPLE
.\Convert-LastPassValut.ps1 -LastPassVaultXML c:\temp\lpv.xml -Verbose

Import the specified file, some verbose output will be shown on the screen


.LINK
 
#>


[cmdletbinding()]
Param
(
    [Parameter(Mandatory = $True)]
    [String]$LastPassVaultXML,
    [Parameter(Mandatory = $False)]
    [String]$OutputFile = "$($env:USERPROFILE)\desktop\lpv-deobfuscated.xml"
)

Function Convert-FromHex
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]$x
    )
    $charArray = $x -split ''
    $plainTextArray = @()
    for ($i = 1; $i -lt ($chararray.length - 2); $i = $i + 2)
    {
        $j = $i + 1
        $hexChar = "0x$($charArray[$i])$($charArray[$j])"
        $plainTextChar = [char][byte]$hexChar
        $plainTextArray += $plainTextChar
    }
    $plainTextArray -join ''
}

$xml = [xml](Get-Content $LastPassVaultXML)

ForEach ($element in $xml.response.accounts.account)
{
    Write-Verbose "ID: $($element.id)"
    
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText

    $plainText = (Convert-FromHex $element.login.url).trim()
    Write-Verbose "Login URL: $plainText"
    $element.login.url = $plainText

    $plainText = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($element.last_touch))
    Write-Verbose "last_touch: $plainText"
    $element.last_touch = $plainText

    $plainText = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($element.last_modified))
    Write-Verbose "last_modified: $plainText"
    $element.last_modified = $plainText

    Write-Verbose ""
}

Write-Verbose "`nNever Auto Login:"
ForEach ($element in $xml.response.neveraccounts.neverautologin)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nNever Accounts:"
ForEach ($element in $xml.response.neveraccounts.neveraccount)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nNever Generate:"
ForEach ($element in $xml.response.neveraccounts.nevergenerate)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nNever Formfill:"
ForEach ($element in $xml.response.neveraccounts.neverformfill)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nNever Showicons:"
ForEach ($element in $xml.response.neveraccounts.nevershowicons)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nDisable Lp:"
ForEach ($element in $xml.response.neveraccounts.disablelp)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText"
    $element.url = $plainText
}

Write-Verbose "`nEquivalent Domains:"
ForEach ($element in $xml.response.equivdomains.equivdomain)
{
    $plainText = (Convert-FromHex $element.domain).trim()
    Write-Verbose "EDID: $($element.edid) URL: $plainText"
    $element.domain = $plainText
}

Write-Verbose "`nURL Rules:"
ForEach ($element in $xml.response.urlrules.urlrule)
{
    $plainText = (Convert-FromHex $element.url).trim()
    Write-Verbose "URL: $plainText Port: $($element.exactport) Host: $($element.exacthost)"
    $element.url = $plainText
}

$xml.save($OutputFile)
Write-Output "`nSaved deobfuscated file to $Outputfile"
