function Execute([string] $cmd)
{
    powershell `
        -NoProfile `
        -ExecutionPolicy unrestricted `
        -Command $cmd
}

Function Test-RegistryValue 
{
    param(
        [Alias("RegistryPath")]
        [Parameter(Position = 0)]
        [String]$Path
        ,
        [Alias("KeyName")]
        [Parameter(Position = 1)]
        [String]$Name
    )

    process 
    {
        if (Test-Path $Path)  {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                }       
                else {
                    $true
                }
            }
            else {
                $false
            }
        }
        else {
            $false
        }
    }
}

Function Disable-UAC
{
    $EnableUACRegistryPath = "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $EnableUACRegistryKeyName = "EnableLUA"
    $UACKeyExists = Test-RegistryValue -RegistryPath $EnableUACRegistryPath -KeyName $EnableUACRegistryKeyName 
    if ($UACKeyExists)
    {
        Set-ItemProperty -Path $EnableUACRegistryPath -Name $EnableUACRegistryKeyName -Value 0
    }
    else
    {
        New-ItemProperty -Path $EnableUACRegistryPath -Name $EnableUACRegistryKeyName -Value 0 -PropertyType "DWord"
    }
}

Function Set-Explorer-Options
{
	$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
	Set-ItemProperty $key Hidden 1
	Set-ItemProperty $key HideFileExt 0
	Set-ItemProperty $key ShowSuperHidden 1
	Set-ItemProperty $key NavPaneExpandToCurrentFolder 1
	Stop-Process -processname explorer
}

Function Set-Server-Config-Options
{
	if ( -Not (Test-Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability'))
	{
		New-Item -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT' -Name Reliability -Force
	}
	Set-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name ShutdownReasonOn -Value 0
  
}
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}



Set-Server-Config-Options
Set-Explorer-Options
Disable-InternetExplorerESC

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
# Update envs as needed
RefreshEnv

# Install PSGet
iex (new-object Net.WebClient).DownloadString('http://psget.net/GetPsGet.ps1')

# Get PowerShell modules
Import-Module PSGet
Install-Module Pester
Install-Module Pscx
Install-Module Psake

# Chocolatey Packages
cinst poshgit
RefreshEnv

# setup GIT with my info
git config --global user.name 'Jim Holmes'
git config --global user.email 'jim@GuidepostSystems.com'


# Now back to Chocolatey
choco install TimRayburn.GitAliases
choco install ruby
choco install ruby2.devkit
choco install beyondcompare
choco install 7zip
choco install sysinternals
choco install fiddler
choco install slickrun
choco install zoomit
choco install autohotkey
choco install vim
choco install poweriso
choco install markdownpad2
choco install Git-TF

# Windows Features

choco WindowsFeatures IIS-WebServerRole
choco WindowsFeatures IIS-ISAPIFilter
choco WindowsFeatures IIS-ISAPIExtensions
choco WindowsFeatures IIS-NetFxExtensibility
choco WindowsFeatures IIS-ASPNET45
#choco WindowsFeatures TelnetClient
choco WindowsFeatures WCF-Services45
choco WindowsFeatures WCF-TCP-PortSharing45
choco windowsfeatures IIS-WebServerManagementTools
choco windowsfeatures IIS-StaticContent

# Add Visual Studio 2012 - Removed because packge does not do what you'd expect.
# cinst VisualStudio2012Ultimate

# Disable UAC & Reboot
# Disable-UAC
