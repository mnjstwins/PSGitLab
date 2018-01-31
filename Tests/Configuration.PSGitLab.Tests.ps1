$ModuleName = Split-Path (Resolve-Path "$PSScriptRoot\..\" ) -Leaf
$ModuleManifest = Resolve-Path "$PSScriptRoot\..\PSGitLab\$ModuleName.psd1"

Get-Module $ModuleName | Remove-Module

Import-Module $ModuleManifest

InModuleScope PSGitLab {
    $TestCase = @(
        @{TestName='Standard HTTPS';Domain='https://example.com';APIVersion=3;Token='Test'},
        @{TestName='Sub Domain';Domain='https://subdomain.example.com';APIVersion=4;Token='NewToken'}
        @{TestName='Directory';Domain='https://example.com/gitlab/';APIVersion=4;Token='lsfjfsff'}
        @{TestName='Non-Standard Port';Domain='https://example.com:7387/';APIVersion=4;Token='lsfjflkjsdflkjsafsff'}
    )

    Describe 'Save-GitLabAPIConfiguration' {
        # Arrange
        $FilePath = "$TestDrive\PesterTest.xml"

        $ExportCLIXML = Get-Command Export-Clixml

        Mock Export-Clixml {
            & $ExportCLIXML -InputObject $InputObject -Path $FilePath
        }


        It -TestCases $TestCase "<TestName>" {
            param(
                $Domain,
                $Token,
                $APIVersion
            )
            # Act 
            Save-GitLabAPIConfiguration -Token $Token -Domain $Domain -APIVersion $APIVersion

            # Assert
            $Results = Import-Clixml "$TestDrive\PesterTest.xml" 
            $Results.Domain | Should be $Domain
            $Results.APIVersion | Should be $APIVersion
            $Results.Token.GetType() | Should be 'SecureString'
            DecryptString -Token $Results.Token | Should be $Token
        }

    }

    Describe 'ImportConfig' {
        # Arrange
        $FilePath = "$TestDrive\PesterTest.xml"
        $ExportCLIXML = Get-Command Export-Clixml
        $ImportCLIXML = Get-Command Import-Clixml
        Mock Export-Clixml {
            & $ExportCLIXML -InputObject $InputObject -Path $FilePath
        }

        Mock Test-Path {
            return $true
        }
        
        Mock Import-Clixml -Verifiable {
            & $ImportCLIXML $FilePath
        }

        It '<TestName>' -TestCases $TestCase {
            param(
                $Domain,
                $Token,
                $APIVersion
            )  
            $Act           
            Save-GitLabAPIConfiguration -Token $Token -Domain $Domain -APIVersion $APIVersion
            $Results = ImportConfig $FilePath
            
            # Assert
            $Results.Domain | Should be $Domain
            $Results.APIVersion | Should be $APIVersion
            $Results.Token.GetType() | Should be 'SecureString'
            DecryptString -Token $Results.Token | Should be $Token
        }
    }

    Describe 'GetGitLabStatusCode' {
        # Arrange
        $StatusCodeTestCase = @(
            @{StatusCode=200;Contains='OK'},
            @{StatusCode=201;Contains='Created'},
            @{StatusCode=400;Contains='Bad Request'},
            @{StatusCode=401;Contains='Unauthorized'},
            @{StatusCode=403;Contains='Forbidden'},
            @{StatusCode=404;Contains='Not Found'},
            @{StatusCode=405;Contains='Method Not Allowed'},
            @{StatusCode=409;Contains='Conflict'},
            @{StatusCode=422;Contains='Unprocessable'},
            @{StatusCode=500;Contains='Server Error'}
        )
        it "Status Code: <StatusCode>" -TestCases $StatusCodeTestCase {
            param(
                $StatusCode,
                $Contains
            )
            # Act
            $Results = GetGitlabStatusCode -StatusCode $StatusCode

            # Assert
            $Results.StatusText | Should Match $Contains
        }
    }

    Describe 'DecryptString' {
        # Arrange
        $DecryptTestCase = @(
            @{TestName='Alpha';Token='lksjfd'},
            @{TestName='Numeric';Token='1242402'},
            @{TestName='Alpha-Numberic';Token='lkslksjdf1212jfd'}
        )

        $FilePath = "$TestDrive\PesterTest.xml"
        $ExportCLIXML = Get-Command Export-Clixml
        $ImportCLIXML = Get-Command Import-Clixml
        Mock Export-Clixml {
            & $ExportCLIXML -InputObject $InputObject -Path $FilePath
        }

        Mock Test-Path {
            return $true
        }
        
        Mock Import-Clixml -Verifiable {
            & $ImportCLIXML $FilePath
        }        
        
        It "<TestName>" -TestCases $DecryptTestCase {
            param(
                $Token
            )
            # Act
            Save-GitLabAPIConfiguration -Token $Token -Domain 'https://example.com' -APIVersion 3
            $Results = ImportConfig $FilePath

            # Assert
            DecryptString -Token $Results.Token | Should be $Token

        }
        
    }

    Describe 'GetMethodParameters' {
        # Arrange
        $GetMethodTestCase = @(
            @{TestName='One Parameter';Parameters=@(@{per_page=100});URLLocation='?per_page=100'},
            @{TestName='Multiple Parameters';Parameters=@(@{per_page=100},@{search='example'});URLLocation='?per_page=100&search=example'},
            @{TestName='Space';Parameters=@(@{search='With Space'});URLLocation='?search=With%20Space'},
            @{TestName='Question Mark';Parameters=@(@{search='What am I testing?'});URLLocation='?search=What%20am%20I%20testing%3F'},
            @{TestName='Apersand';Parameters=@(@{search='Checking with &'});URLLocation='?search=Checking%20with%20%26'}
        )

        It "<TestName>" -TestCases $GetMethodTestCase {
            param(
                $Parameters,
                $URLLocation
            )
            # Act
            $Result = GetMethodParameters -GetURLParameters $Parameters


            # Assert
            $Result | Should be $URLLocation
        }
    }
}

Remove-Module $ModuleName