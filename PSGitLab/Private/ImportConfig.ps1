Function ImportConfig {
<#
.Synopsis
   Check for configuration and output the information.
.DESCRIPTION
   Check for configuration and output the information. Goes into the $env:appdata for the configuration file.
.EXAMPLE
    ImportConfig
#>

if ( ( Test-Path env:PSGitLabDomain) -and ( Test-Path env:PSGitLabToken ) -and ( Test-Path env:PSGitLaAPIVersion ) ) {
    $Token = ConvertTo-SecureString -String $env:PSGitLabToken -AsPlainText -Force
    [PSCustomObject]@{
        Domain=$env:PSGitLabDomain
        Token=$Token
        APIVersion=$env:PSGitLabAPIVersion
    }
    break;
}

if ( $IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" ) ) {
    $ConfigFile = "{0}\PSGitLab\PSGitLabConfiguration.xml" -f $env:appdata
} elseif ( $IsLinux ) {
    $ConfigFile = "{0}/.psgitlab/PSGitLabConfiguration.xml" -f $HOME
} else {
    Write-Error "Unknown Platform"
}
if (Test-Path $ConfigFile) {
    Import-Clixml $ConfigFile

} else {
    Write-Warning 'No saved configuration information. Run Save-GitLabAPIConfiguration.'
    break;
}
}
