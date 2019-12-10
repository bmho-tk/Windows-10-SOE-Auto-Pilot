#Requires -version 2.0

# Set Tls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Environmental variables to be used
[string]$DownloadPath = 'C:\TempDownloads'

# Create Download directory
New-Item -Path $(Split-Path -Path $DownloadPath -Parent) -Name $(Split-Path -Path $DownloadPath -Leaf) -ItemType Directory -Confirm:$false -Force

# Download the Windows ADK for Windows 10, version 1903
Invoke-WebRequest -uri 'https://go.microsoft.com/fwlink/?linkid=2086042' -OutFile "${DownloadPath}\adksetup.exe"

# Download the Windows PE add-on for the ADK
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2087112' -OutFile "${DownloadPath}\adkwinpesetup.exe"

# Download the Windows System Image Manager (WSIM) 1903 update
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2095334' -OutFile "${DownloadPath}\WSIM1903.zip"

# Download 7zip (code borrowed from https://github.com/bmho-tk/SCCM_Software_Update/blob/master/apps/7zip.ps1)
$DLPage = Invoke-WebRequest -Uri https://www.7-zip.org/download.html -UseBasicParsing
$DLPath = 'https://www.7-zip.org/'
$url64_i = $DLPage.Links | Where-Object href -match '-x64.msi$' | ForEach-Object href
$url64_d = (Split-Path $url64_i -Leaf)
$url_V64 = (Split-Path $url64_i -Leaf).Replace('7z','').Replace('-x64.msi','')
[hashtable]$7Zip64 = @{
    Version = $url_V64[0]
    URL64_msi = "https://www.7-zip.org/a/7z$(${url_V64}[0])-x64.msi"
}
[string]$AppVersion64 = $7Zip64.Version
[string]$DownloadURI64 = $7Zip64.URL64_msi
[string]$AppShortName64 = '7Zip 64-bit'
[string]$AppFullName64 = "${AppShortName64} ${AppVersion64}"
[string]$BrandName64 = '7Zip'
[string]$url64_m = Split-Path $DownloadURI64 -Leaf
Invoke-WebRequest -Uri $DownloadURI64 -OutFile "${DownloadPath}\${url64_m}"


<#
  Install applications
#>
# 7-Zip
Start-Process -FilePath "${env:WINDIR}\system32\msiexec.exe" -ArgumentList "/i ${DownloadPath}\${url64_m} /passive" -Wait

# ADK for Windows 10
Start-Process -FilePath "${DownloadPath}\adksetup.exe" -ArgumentList '/features OptionID.DeploymentTools /quiet /norestart' -wait

# WinPE for ADK for Windows 10
Start-Process -FilePath "${DownloadPath}\adkwinpesetup.exe" -ArgumentList '/features OptionId.WindowsPreinstallationEnvironment /quiet /norestart' -Wait

# WSIM 1903 Update

<#
  A Windows ADK for Windows 10, version 1909 will not be released. You can use the Windows ADK for Windows 10, version 1903 to deploy Windows 10, version 1909.
#>

