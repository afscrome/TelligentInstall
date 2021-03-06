﻿Set-StrictMode -Version 2

$versionRegex = [regex]'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

function Get-TelligentVersion {
    <#
    .SYNOPSIS
	    Gets a list of Teligent Community builds in the TelligentPackages directory.
    .PARAMETER Version
	    Filters to the most recent build whose version matches the given pattern
    .EXAMPLE
        Get-TelligentVersion
        
        Gets a list of all available builds of Telligent Community.
    .EXAMPLE
        Get-TelligentVersion 9.1
        
        Gets the most recent build with major version 7 and minor version 6.
    #>
    [CmdletBinding(DefaultParameterSetName='All')]
    param(
        [parameter(Position=0)]
        [string]$Version
    )
	
	$base = $env:TelligentInstanceManager
	if (!$base) {
		throw 'TelligentInstanceManager environmental variable not defined' 
	}
	$basePackageDir = Join-Path $base TelligentPackages
	
    $basePackages = Get-VersionedTelligentCommunityPackage $basePackageDir
    $fullBuilds = $basePackages |
        % { 
            new-object psobject -Property ([ordered]@{
                Version = $_.Version
                BasePackage = $_.Path
            })
        } 
	
	$results = @($fullBuilds)

    $results = $results | sort Version
		
	if($Version){
        $versionPattern = "$($Version.TrimEnd('*'))*"
		$results = $results |
            ? {$_.Version.ToString() -like $versionPattern } |
            select -Last 1
	}
    $results

}

function Get-VersionedTelligentCommunityPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$Path
    )

    Get-ChildItem $Path  *.zip|
        %{
            $match = $versionRegex.Match($_.Name)

            if ($match.Value) {                
                New-Object PSObject -Property (@{
                    Version = [version]$match.Value
                    Path = $_.FullName
                })
            }
        }

}



