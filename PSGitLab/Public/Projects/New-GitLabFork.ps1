Function New-GitLabFork {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Id')]
        [string]$Id,

        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        #[Parameter(ParameterSetName='Namespace')]
        [string]$Namespace
    )

    $Project = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Id' { $Project = Get-GitLabProject -Id $Id }
        'Namespace' { $Project = Get-GitLabProject -Namespace $Namespace }
    }

    $Request = @{
        URI="/projects/fork/$($Project.id)";
        Method='POST';
    }
    if ($PSCmdlet.ShouldProcess($Project.Name, 'Create Project Fork')) {
        QueryGitLabAPI -Request $Request -ObjectType 'GitLab.Project'
    }
}
