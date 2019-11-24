#Requires -version 2.0
# ***************************************************************************
# 
# Author:    Chris Steding 
# 
# Purpose:   This PowerShell script will execute all tasks to install a 
#            working MDT Including:
#            Install the Feature .NET Framework 3.5.1
#            Installs Windows Deployment Service
#            Install Microsoft Deployment ToolKit
#            Install Windows Automated Installation kit         
#
# Usage:     Copy this file to an appropriate location. 
#            Extraxt KB3AIK_EN.ISO to KB3AIK_EN
#            Save the MDT installation file in the script directory
#            Edit the constant variables in the second part of the script below to meet your needs and enjoy.
#
#
# ------------- DISCLAIMER --------------------------------------------------
# This script code is provided as is with no guarantee or warranty concerning
# the usability or impact on systems.
# ------------- DISCLAIMER --------------------------------------------------
#
# **************************************************************************

# This scripts needs unrestricted access 
Set-ExecutionPolicy Unrestricted -force

# This installs the Feature .NET Framework 3.5.1
Import-Module ServerManager
Add-WindowsFeature as-net-framework
Start-Sleep -Seconds 10

# This installs Windows Deployment Service
Import-Module ServerManager
Add-WindowsFeature WDS
Start-Sleep -Seconds 10

# Install wAIK 
$PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
msiexec /qb /i "$PSScriptRoot\KB3AIK_EN\wAIKAMD64.msi" "TRANSFORMS=$PSScriptRoot\KB3AIK_EN\waikamd64.mst" | Out-Null
Start-Sleep -Seconds 10

# Install Microsoft Deployment Toolkit 2012
$PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
msiexec /qb /i "$PSScriptRoot\MicrosoftDeploymentToolkit2012_x64.msi" | Out-Null
Start-Sleep -s 10

# Configure MDT 2012
# ***************************************************************************
# 
# 
# 
# Author:    Brandon Linton 
# 
# Purpose:   This PowerShell script will execute all tasks to create a working
#            MDT Deployment Share Including:
#            Create Folder for share
#            Share MDT Deployment Folder
#            Creates an example folder structure and selection profiles.
#            
#
#            Note that there should be no one actively adding items to the
#            deployment share while running this script, as some of the
#            operations performed could cause duplicated or lost items.
#
#
# Usage:     Copy this file to an appropriate location.  Edit the constant
#            variables below to meet your needs and enjoy.
#
#
# ------------- DISCLAIMER --------------------------------------------------
# This script code is provided as is with no guarantee or warranty concerning
# the usability or impact on systems.
# ------------- DISCLAIMER --------------------------------------------------
#
# **************************************************************************

# Initialize
Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue

# Constants
$Computer = $env:computername
$FolderPath = "C:\DeploymentShare"
$ShareName = "DeploymentShare$"
$NetPath = "\\$Computer\DeploymentShare$"
$MDTDescription = "Deployment Share"

# Make MDT Directory
New-Item -Path $(Split-Path -Path $FolderPath -Parent) -ItemType Directory -Name $(Split-Path -Path $FolderPath -Leaf) -Confirm:$false -Force

# Create MDT Shared Folder
$Type = 0
$objWMI = [wmiClass] 'Win32_share'
$objWMI.create($FolderPath, $ShareName, $Type)

# Create PS Drive for MDT
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$FolderPath" -Description "$MDTDescription" -NetworkPath "$NetPath"  -Verbose | Add-MDTPersistentDrive -Verbose

# Create OS Folders
New-Item -Path "DS001:\Operating Systems" -Enable "True" -Name "Windows 7" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Operating Systems" -Enable "True" -Name "Windows Server" -Comments "" -ItemType Directory -Verbose

# Create Driver Folders
New-Item -Path "DS001:\Out-of-Box Drivers" -Enable "True" -Name "Windows 7 x86" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers" -Enable "True" -Name "Windows 7 x64" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers" -Enable "True" -Name "WinPE x86" -Comments "" -ItemType Directory -Verbos
New-Item -Path "DS001:\Out-of-Box Drivers" -Enable "True" -Name "WinPE x64" -Comments "" -ItemType Directory -Verbos

New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86" -Enable "True" -Name "Dell Inc." -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -Enable "True" -Name "OptiPlex 760" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -Enable "True" -Name "Latitude E6500" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -Enable "True" -Name "OptiPlex 745" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -Enable "True" -Name "OptiPlex GX280" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -Enable "True" -Name "Latitude E6400" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86" -Enable "True" -Name "Dell Computer Corporation" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Computer Corporation" -Enable "True" -Name "OptiPlex GX260" -Comments "" -ItemType Directory -Verbose

# Create Packages Folders
New-Item -Path "DS001:\Packages" -Enable "True" -Name "Language Packs" -Comments "" -ItemType Directory -Verbose

# Create TS Folders
New-Item -Path "DS001:\Task Sequences" -Enable "True" -Name "Windows 2008" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Task Sequences" -Enable "True" -Name "Windows 7" -Comments "" -ItemType Directory -Verbose

# Create Application Folders
New-Item -Path "DS001:\Applications" -Enable "True" -Name "Reference Applications" -Comments "" -ItemType Directory -Verbose
New-Item -Path "DS001:\Applications" -Enable "True" -Name "Core Applications" -Comments "" -ItemType Directory -Verbose

# Create Selection Profiles
New-Item -Path "DS001:\Selection Profiles" -Enable "True" -Name "WinPE x86" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x86`" #/></SelectionProfile>" -ReadOnly "False" -Verbose
New-Item -Path "DS001:\Selection Profiles" -Enable "True" -Name "WinPE x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x64`" #/></SelectionProfile>" -ReadOnly "False" -Verbose

# Import Operating System Source Files
ImportNew-ItemMDTOperatinSystem -Path "DS001:\Operating Systems\Windows 7" -SourcePath "D:\Source\Operating Systems\Windows 7 Enterprise x86" -DestinationFolder "Windows 7 #Enterprise x86 Source" -Verbose

# Import Applications
Import-MDTApplication -Path "DS001:\Applications\Reference Applications" -Enable "True" -Name "Microsoft .NET Framework 3.0 SP2" -ShortName ".NET Framework" -Version #"3.0 SP2" -Publisher "Microsoft" -Language "" -CommandLine "cscript.exe Install-NETFramework30SP2.wsf" -WorkingDirectory ".\Applications\INSTALL - Microsoft .NET #Framework 3.0 SP2" -ApplicationSourcePath "C:\Source\INSTALL - Microsoft .NET Framework 2.0" -DestinationFolder "INSTALL - Microsoft .NET Framework 3.0 SP2" -Verbose

# Restart of server 
#shutdown.exe /r /f /t 30
