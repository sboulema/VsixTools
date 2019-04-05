Install-PackageProvider -Name NuGet -Force -Scope CurrentUser

# Install VstsTaskSdk to signVsix
New-Item -ItemType directory -Path .\src\tasks\signVsix\ps_modules
Save-Module -Name VstsTaskSdk -Path .\src\tasks\signVsix\ps_modules
Move-Item -Path .\src\tasks\signVsix\ps_modules\VstsTaskSdk\0.11.0\* -Destination .\src\tasks\signVsix\ps_modules\VstsTaskSdk

# Copy VstsTaskSdk to uploadVsix
Copy-Item .\src\tasks\signVsix\ps_modules\* -Destination .\src\tasks\uploadVsix\ps_modules -Recurse