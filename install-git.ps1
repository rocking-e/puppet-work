# get latest download url for git-for-windows 64-bit exe
$git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like "*64-bit.exe"
# download installer
$installer = "$env:temp\$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
# run installer
#$git_install_inf = Join-Path -path $PWD.Path -ChildPath ".\git-install.ini"
#$install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
$install_args = '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
Start-Process -FilePath $installer -ArgumentList $install_args -Wait

# Start a git-bash shell
Write-Host "Launching git-bash window"
& "C:\Program Files\Git\git-bash.exe" --cd-to-home