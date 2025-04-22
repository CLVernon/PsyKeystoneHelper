#Get the installation directory
$installDir = "C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\"
if (Test-Path $installDir) {
    Write-Host "Installation directory found: $installDir"
} else {
    $installDir = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\"

    if (Test-Path $installDir) {
        Write-Host "Installation directory found: $installDir"
    } else
    {
        Write-Host "ERR: No installation directory found!"
        exit
    }
}

#Delete the old build if present
$buildDir = "$installDir\PsyKeystoneHelper"
if (Test-Path buildDir) {
    Write-Host "Deleting old build..."
    Remove-Item -Recurse -Force $buildDir
}

#Create the new build
Write-Host "Creating new build..."
$currentDir = (Get-Location).Path
$srcDir = "$currentDir\PsyKeystoneHelper"
$excludes = @("*.xcf", "*.wowproj", "*.csproj", "*.user")
Write-Host "Copying files from $srcDir to $buildDir..."
Get-ChildItem $srcDir -Recurse -Exclude $excludes | Copy-Item -Destination {Join-Path $buildDir $_.FullName.Substring($srcDir.length)}

#Complete
Write-Host "Build complete!"
exit