Function Convert-ECSAccountToSID
    {
    <#
    .SYNOPSIS
    Retrieves the SID for a given account name

    .DESCRIPTION
    Convert-ECSAccountToSID is used to convert an account to a SID

    .PARAMETER AccountName
    This parameter can be in the format of the following:
    
    Name
    Domain\Name
    Name@domain.com

    Specifying the domain, will result in the most accurate return.  if there are two accounts named "example".  One local and one domain, the local will return by default.

    .EXAMPLE
    This is an example of converting a single account.

    Convert-ECSAccountToSID -AccountName "AccountName"

    Convert-ECSAccountToSID -AccountName "Domain\AccountName"

    Convert-ECSAccountToSID -AccountName "AccountName@Domain.com"
    
    .EXAMPLE
    This example uses an array of objects

    $AllAccounts = Get-content c:\AllAccounts.txt

    Convert-ECSAccountToSID -AccountName $AllAccounts

    .EXAMPLE
    This example uses is from a pipeline

    Get-content c:\AllAccounts.txt | Convert-ECSAccountToSID 

    #>
    [CmdletBinding()]
    Param
	    (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage="Enter an NTAccount in the format of domain\object or simply object (domain\object is the most accurate)"
            )]
        [ValidateNotNull()]    
        $AccountName

        )
	    
    ##########################################################################################################
    #Process block

    process 
        {

        Foreach ($Object in $AccountName)
            {
            Try
                {
                Write-Verbose "########################################################"
                Write-Verbose "Attempting to convert $Object to SID"

                #Creating a user or other object
                $objUser = New-Object System.Security.Principal.NTAccount($Object)     

                #Translating the object to a SID
                $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])

                #Now to have a clean consistent object, we're going to convert the SID back to an NTAccount
                $NTAccount = Convert-ECSSIDToAccount -SID $($strSID.value)
                    
                Write-Verbose "Account lookup succeeded"

                New-Object PSObject -Property @{
                    NTAccount = $($NTAccount.NTAccount)
                    SAMAccountName = $($NTAccount.SAMAccountName)
                    SAMAccountNetBIOSName = $($NTAccount.SAMAccountNetBIOSName)
                    SID = $($NTAccount.SID)
                    AccountDomainSID = $($NTAccount.AccountDomainSID)
                    AccountName = $Object
                    }
                }
            Catch
                {
                $Exception = $_.Exception 
                Write-Verbose "We had an exception looking up the account, see below for the message"
                Write-verbose "$($Exception.Message)" 
                Write-Verbose "Failed to convert $Object to SID"

                New-Object PSObject -Property @{
                    NTAccount = "Account lookup failed"
                    SAMAccountName = "Account lookup failed"
                    SAMAccountNetBIOSName = "Account lookup failed"
                    SID = "Account lookup failed"
                    AccountDomainSID = "Account lookup failed"
                    AccountName = $Object
                    }
                }

            }
        }

    #End Process block
    ##########################################################################################################

    }