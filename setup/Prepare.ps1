# Add 7-Zip to path
$env:Path += ";C:\Program Files\7-Zip\"

# Test internet connection
$DNS = (Test-Connection www.google.com -quiet)
If($DNS -eq "True") {Write-Host "The internet is available"}
ElseIf($DNS -ne "True") {Restart-Service dnscache}

If(Test-Path -Path "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")
{
    $releaseKey = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release   
}
If($releaseKey -ge 528040)
{ Write-Host "4.8" }
ElseIf($releaseKey -ge 461808)
{ Write-Host "4.7.2" }
ElseIf($releaseKey -ge 461308)
{ Write-Host "4.7.1" }
ElseIf($releaseKey -ge 460798)
{ Write-Host "4.7" }
ElseIf($releaseKey -ge 394802)
{ Write-Host "4.6.2" }
ElseIf($releaseKey -ge 394254)
{ Write-Host "4.6.1" }
ElseIf($releaseKey -ge 393295)
{ Write-Host "4.6" }
ElseIf($releaseKey -ge 379893)
{ Write-Host "4.5.2" }
ElseIf($releaseKey -ge 378675)
{ Write-Host "4.5.1" }
ElseIf($releaseKey -ge 378389)
{ Write-Host "4.5" }
Else
{ Write-Host "No 4.5 or later version detected" }