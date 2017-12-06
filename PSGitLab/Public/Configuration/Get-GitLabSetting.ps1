Function Get-GitLabSetting {
    [OutputType('GitLab.User.Key')]
    $Request = @{
        URI="/application/settings";
        Method='Get';
    }
   
    QueryGitLabAPI -Request $Request -ObjectType 'GitLab.Settings'

}