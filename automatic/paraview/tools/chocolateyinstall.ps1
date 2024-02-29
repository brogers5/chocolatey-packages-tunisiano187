﻿$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url            = 'https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.12/&type=binary&os=Windows&downloadFile=ParaView-5.12.0-RC3-Windows-Python3.10-msvc2017-AMD64.msi' # download url, HTTPS preferred
$checksum       = 'cafb2a85dc615fd1026e871705f26ce53578488023cd59e849a1ac08d0072b79'
$checksumType   = 'sha256'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'MSI'
  url           = $url
  softwareName  = 'paraview*'
  checksum      = $checksum
  checksumType  = $checksumType

  silentArgs    = "/quiet /qn /norestart"
  validExitCodes= @(0, 3010, 1641)
}

if((Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 1) {
  Install-ChocolateyPackage @packageArgs
} else {
  Write-Warning "System not supported, client required"
  exit 0;
}
