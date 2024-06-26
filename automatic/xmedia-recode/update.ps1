$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://www.xmedia-recode.de/en/index.php'

function global:au_SearchReplace {
	@{
		"legal\VERIFICATION.txt"      = @{
			"(?i)(x32:).*"        				= "`${1} $($Latest.URL32)"
			"(?i)(checksum32:).*" 				= "`${1} $($Latest.Checksum32)"
			"(?i)(x64:).*"        				= "`${1} $($Latest.URL64)"
			"(?i)(checksum64:).*" 				= "`${1} $($Latest.Checksum64)"
			"(?i)(checksumtype:).*" 			= "`${1} $($Latest.ChecksumType32)"
		}
	}
}

function global:au_BeforeUpdate {
	Get-RemoteFiles -Purge -NoSuffix
}

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
	$page = Invoke-WebRequest -Uri $releases
	$regexPattern = 'XMedia Recode (\d+(\.\d+)*)'
	$versionMatch = $page.Content | Select-String -Pattern $regexPattern -AllMatches
	$version = $versionMatch.Matches[0].Groups[1].Value
	$versionfile = ($version -replace '[.]','')
	$url32 = "https://www.xmedia-recode.de/download/XMediaRecode$($versionfile)_setup.exe"
	$url64 = "https://www.xmedia-recode.de/download/XMediaRecode$($versionfile)_x64_setup.exe"

	$Latest = @{ URL32 = $url32; URL64 = $url64; Version = $version }
	return $Latest
}

update
