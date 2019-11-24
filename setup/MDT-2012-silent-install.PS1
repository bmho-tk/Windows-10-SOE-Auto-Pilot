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

Start-Sleep -s 10

# This installs Windows Deployment Service
Import-Module ServerManager
Add-WindowsFeature WDS

Start-Sleep -s 10

# Install wAIK 
$PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path

msiexec /qb /i "$PSScriptRoot\KB3AIK_EN\wAIKAMD64.msi" "TRANSFORMS=$PSScriptRoot\KB3AIK_EN\waikamd64.mst" | Out-Null

Start-Sleep -s 10

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
$Computer = get-content env:computername
$FolderPath = "D:\DeploymentShare"
$ShareName = "DeploymentShare$"
$NetPath = "\\$Computer\DeploymentShare$"
$MDTDescription = "Deployment Share"

# Make MDT Directory
mkdir "$FolderPath"

# Create MDT Shared Folder
$Type = 0
$objWMI = [wmiClass] 'Win32_share'
$objWMI.create($FolderPath, $ShareName, $Type)


# Create PS Drive for MDT
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$FolderPath" -Description "$MDTDescription" -NetworkPath "$NetPath"  -Verbose | add-MDTPersistentDrive -Verbose

# Create OS Folders
new-item -path "DS001:\Operating Systems" -enable "True" -Name "Windows 7" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Operating Systems" -enable "True" -Name "Windows Server" -Comments "" -ItemType "folder" -Verbose

# Create Driver Folders

new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "Windows 7 x86" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "Windows 7 x64" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "WinPE x86" -Comments "" -ItemType "folder" -Verbos
new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "WinPE x64" -Comments "" -ItemType "folder" -Verbos

new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86" -enable "True" -Name "Dell Inc." -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -enable "True" -Name "OptiPlex 760" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -enable "True" -Name "Latitude E6500" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -enable "True" -Name "OptiPlex 745" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -enable "True" -Name "OptiPlex GX280" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Inc." -enable "True" -Name "Latitude E6400" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86" -enable "True" -Name "Dell Computer Corporation" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Out-of-Box Drivers\Windows 7 x86\Dell Computer Corporation" -enable "True" -Name "OptiPlex GX260" -Comments "" -ItemType "folder" -Verbose


# Create Packages Folders
new-item -path "DS001:\Packages" -enable "True" -Name "Language Packs" -Comments "" -ItemType "folder" -Verbose

# Create TS Folders
new-item -path "DS001:\Task Sequences" -enable "True" -Name "Windows 2008" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Task Sequences" -enable "True" -Name "Windows 7" -Comments "" -ItemType "folder" -Verbose

# Create Application Folders
new-item -path "DS001:\Applications" -enable "True" -Name "Reference Applications" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Core Applications" -Comments "" -ItemType "folder" -Verbose

# Create Selection Profiles
new-item -path "DS001:\Selection Profiles" -enable "True" -Name "WinPE x86" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x86`" #/></SelectionProfile>" -ReadOnly "False" -Verbose
new-item -path "DS001:\Selection Profiles" -enable "True" -Name "WinPE x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE x64`" #/></SelectionProfile>" -ReadOnly "False" -Verbose

# Import Operating System Source Files
import-mdtoperatingsystem -path "DS001:\Operating Systems\Windows 7" -SourcePath "D:\Source\Operating Systems\Windows 7 Enterprise x86" -DestinationFolder "Windows 7 #Enterprise x86 Source" -Verbose

# Import Applications
import-MDTApplication -path "DS001:\Applications\Reference Applications" -enable "True" -Name "Microsoft .NET Framework 3.0 SP2" -ShortName ".NET Framework" -Version #"3.0 SP2" -Publisher "Microsoft" -Language "" -CommandLine "cscript.exe Install-NETFramework30SP2.wsf" -WorkingDirectory ".\Applications\INSTALL - Microsoft .NET #Framework 3.0 SP2" -ApplicationSourcePath "C:\Source\INSTALL - Microsoft .NET Framework 2.0" -DestinationFolder "INSTALL - Microsoft .NET Framework 3.0 SP2" -Verbose


# Restart of server 
shutdown.exe /r /f /t 30


