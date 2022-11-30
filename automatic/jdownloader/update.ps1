﻿$ErrorActionPreference = 'Stop'

import-module au
$releases="https://jdownloader.org/jdownloader2"

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
		}
		".\tools\VERIFICATION.txt" = @{
			"(?i)(\s+x32:).*"                   = "`${1} $($Latest.URL32)"
			"(?i)(Get-RemoteChecksum).*"        = "`${1} $($Latest.URL32)"
			"(?i)(\s+checksum32:).*"            = "`${1} $($Latest.Checksum32)"
			"(?i)(\s+x64:).*"                   = "`${1} $($Latest.URL64)"
			"(?i)(\s+checksum64:).*"            = "`${1} $($Latest.Checksum64)"
		}
		"$($Latest.PackageName).nuspec" = @{
			"(\<copyright\>).*?(\</copyright\>)" 	= "`${1}$($Latest.Copyright)`$2"
		}
	}
}

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
	$urls=(Invoke-WebRequest -uri $releases).Links
	$url32 = ($urls | Where-Object {$_.id -match "windows1"}).href
	$url64 = ($urls | Where-Object {$_.id -match "windows0"}).href
	$toolsPath = Join-Path $(Split-Path $MyInvocation.MyCommand.Definition) "tools"


	megatools.exe dl $url32
	megatools.exe dl $url64

	$File = Get-Item $toolsPath\*_x86_jre17.exe
	$version=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($File).FileVersion.trim()
	$copyright = (Get-Item($File)).VersionInfo.LegalCopyright
	Move-Item *.exe $toolsPath

	$Latest = @{ URL32 = $url32; Version = $version; Copyright = $copyright }
	return $Latest
}

update