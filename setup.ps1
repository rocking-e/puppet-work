$root_dir = "C:\ProgramData\eg-puppet"
$tmp_dir = Join-Path -Path $root_dir -ChildPath "tmp"
$puppet_url = "https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-x64-latest.msi"
$puppet_msi = Join-Path -Path $tmp_dir -ChildPath "puppet.msi"
$puppet_bin = "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat"
$dateStamp = get-date -Format yyyyMMddTHHmmss
$installed_modules = Join-Path -Path $tmp_dir -ChildPath "modules.log"

#$file_name = '{0}-{1}.log' -f "puppet-install",$dateStamp | Out-String
#$logFile = Join-Path -Path $tmp_dir -ChildPath $file_name
$puppetlabs_modules = @('stdlib', 'concat', 'inifile')

# Set this variable to "SilentlyContinue" to surpress "verbose" output
$VerbosePreference = "Continue"

If(!(Test-Path -PathType Container $root_dir)) {
    Write-Verbose "Creating $root_dir directory"
    New-Item -ItemType Directory -Path $root_dir
}

if(!(Test-Path -PathType Container $tmp_dir)) {
    Write-Verbose "Creating $tmp_dir directory"
    New-Item -ItemType Directory $tmp_dir
}

if (!(Test-Path -PathType Leaf $puppet_msi)) {
    Write-Verbose "Fetching puppet msi"
    Write-Debug "from $puppet_url"
    Invoke-WebRequest -Uri "$puppet_url" -OutFile $puppet_msi
}

if (!(Test-Path -PathType Leaf $puppet_bin)) {
    Write-Verbose "Looks like Puppet is not installed"
    Write-Debug "Looked for $puppet_bin"
    $argList = @(
        "/I"
        "$puppet_msi"
        "/qn"
    )
    Start-Process msiexec.exe -ArgumentList $argList  -Wait -PassThru
}
# update PATH so puppet commands work
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + 
    ";" +
    [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Verbose "Installing modules from Puppetfile"
$mod_lines = Get-content Puppetfile | select-string "^mod "
foreach ($line in $mod_lines) {
    # strip out the quotes and comma in the line and get rid of the "mod " at
    # the beginning of the line. Then split it into an array.
    $d = $line.ToString().replace("'", "").replace("mod ", "").replace(",", "").split(" ")
    $module = $d[0]
    $version = $d[1]
    
    if (!(puppet module list | Select-String $module.replace("puppetlabs/", "puppetlabs-"))) {
        Write-Verbose "Installing module $module at $version"
        puppet module install $module --version $version
    }
}
