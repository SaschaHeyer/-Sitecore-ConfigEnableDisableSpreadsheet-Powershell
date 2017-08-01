param(
[Parameter(Mandatory=$true)]
[string]$projectPath = "",
[Parameter(Mandatory=$true)]
[string]$csvPath = "",
[Parameter(Mandatory=$true)]
[string]$searchProvider= "",
[Parameter(Mandatory=$true)]
[string]$server)

$columnSearchProvider = "Search Provider Used"

$source = "$projectPath\App_Config"
$destination = "$projectPath\Backup.zip"
If(Test-path $destination) 
{
     Remove-item $destination
}

Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($Source, $destination) 

$configs = Import-CSV $csvPath -Delimiter ";"
$configs = $configs | Where-Object {($_.$columnSearchProvider -eq $searchProvider -or $_.$columnSearchProvider -eq '')}

$disableConfigs = $configs | Where-Object {$_.$server -eq 'Disable'}
foreach ($config in $disableConfigs) {
    
    $filePath = $config.('File Path');
    $filePath = $filePath.Replace("website\",$null);
    $fileName = $config.('Config file name');

        Rename-Item -Path "$projectPath$filePath\$fileName" -NewName "$fileName.disabled" -ErrorAction SilentlyContinue
        Write-Host "disabled: $fileName" -foregroundcolor yellow 
    
}

$enableConfigs = $configs | Where-Object {($_.$server -eq 'Enable')}
foreach ($config in $enableConfigs) {
    
    $filePath = $config.('File Path');
    $filePath = $filePath.Replace("website\",$null);
    $fileName = $config.('Config file name');
    
    $replacedFileName = $fileName.Replace(".disabled",$null);
    
         Rename-Item -Path "$projectPath$filePath\$fileName" -NewName "$replacedFileName" -ErrorAction SilentlyContinue
         Rename-Item -Path "$projectPath$filePath\$fileName.disabled" -NewName "$replacedFileName" -ErrorAction SilentlyContinue
         Write-Host "enabled: $fileName" -foregroundcolor green 
}