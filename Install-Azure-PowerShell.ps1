$ProgressPreference = 'SilentlyContinue'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Az.Compute, Az.Resources, Az.KeyVault, Az.Network, Az.Storage -Confirm:$false 