$moduleName = Split-Path (Split-Path $PSScriptRoot) -Leaf

$moduleRoot = Join-Path -Path (Split-Path $PSScriptRoot) -ChildPath $moduleName

$manifestPath = "$moduleRoot\$moduleName.psd1"
#

#Test-Path -Path $moduleRoot

$publicFunctions = (Get-ChildItem -Path "$moduleRoot\Public" -Filter '*.ps1').BaseName
#$publicFunctions

if(Test-Path -Path $manifestPath){
    $maniVer = (Test-ModuleManifest -Path $manifestPath).Version

    if($maniVer.Build -eq -1){
        $maniVer.Build = 0
    } 

    $newVer = [version]::new($maniVer.Major, $maniVer.Minor, $maniVer.Build, $maniVer.Revision + 1)

    Update-ModuleManifest -Path $manifestPath -FunctionsToExport $publicFunctions -ModuleVersion $newVer
}
