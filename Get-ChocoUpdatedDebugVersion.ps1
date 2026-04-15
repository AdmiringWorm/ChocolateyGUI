[CmdletBinding(DefaultParameterSetName = "tag")]
param(
    # The location where Chocolatey CLI sources are located,
    # or will be located if the directory does not already exist.
    # If not specified and the environment variable `CHOCO_SOURCE_LOCATION`
    # is not definied, the location will default to `$env:TEMP\
    [Alias("ChocoLocation")]
    [string] $ChocoSourceLocation = $env:CHOCO_SOURCE_LOCATION,

    # Checkout a specific tag of your own choosing.
    # This value can also be a specific commit or a branch, but
    # will be notified as being a tag.
    # NOTE: Only tags already pulled down will be considered.
    [Parameter(ParameterSetName = "tag")]
    [string] $CheckoutTag = $null,

    # Checkout the latest tag available in the Chocolatey Source Location.
    # NOTE: Only tags already pulled down will be considered.
    [Parameter(ParameterSetName = "latest")]
    [switch] $CheckoutLatestTag,

    # Try check out a tage with the same name as what is used as a reference
    # in the packages.config file. If the reference specified is not a stable
    # version, the latest tag will be checked out instead.
    # NOTE: Only tags already pulled down will be considered.
    [Parameter(ParameterSetName = 'ref-tag')]
    [switch] $CheckoutRefTag,

    # Remove and clone the specified Chocolatey Source Location again.
    # This is a very destructive operation, and should only be used if
    # you are not interested in any local information.
    [switch] $ForceChocoClone,

    [switch] $NoBuild
)

if ((-not (Get-Module ChocolateyDebugging)) -and (-not (Get-Module -ListAvailable ChocolateyDebugging))) {
    throw "You don't have the ChocolateyDebugging module installed. Please run ``choco install chocolatey-debugging --source ops-choco-packages``"
}

if (-not $ChocoSourceLocation) {
    $ChocoSourceLocation = Find-ChocolateySourceLocation -RepositoryName choco
}

$GetChocolateyDebugBuildSplat = @{
    PackageName = 'chocolatey.lib'
    Path        = "$PSScriptRoot/Source/ChocolateyGui.Common"
    SourcePath  = $ChocoSourceLocation
    SourceRepo  = "https://github.com/chocolatey/choco"
    ForceClone  = $ForceChocoClone
    NoBuild     = $NoBuild
}

switch ($PSCmdlet.ParameterSetName) {
    'tag' {
        $GetChocolateyDebugBuildSplat.CheckoutTag = $CheckoutTag
    }
    'latest' {
        $GetChocolateyDebugBuildSplat.CheckoutLatestTag = $CheckoutLatestTag
    }
    'ref-tag' {
        $GetChocolateyDebugBuildSplat.CheckoutRefTag = $CheckoutRefTag
    }
}

Get-ChocolateyDebugBuild @GetChocolateyDebugBuildSplat