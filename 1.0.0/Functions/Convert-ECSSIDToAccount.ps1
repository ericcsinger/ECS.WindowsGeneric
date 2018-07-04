Function Convert-ECSSIDToAccount
    {
    <#
    .SYNOPSIS
    Retrieves the SAMAccountName and NTAccount for a given SID.

    .DESCRIPTION
    Convert-ECSSIDToAccount is used to convert a SID to an NTAccount or SAMAccountName.  This works for SIDs of domain and local accounts.

    .PARAMETER SID
    This parameter must be in the format of s-1-5-21-etc.  It accepts pipeline input, multivalue objects and singular SIDS.

    .EXAMPLE
    This is an example of converting a single SID.

    Convert-ECSSIDToAccount -SID "S-1-5-21-3917423434342070-3434343434-65034343434228590"
    
    .EXAMPLE
    This example uses an array of objects

    $AllSIDS = Get-content c:\AllSIDS.txt

    Convert-ECSSIDToAccount -SID $AllSIDS

    .EXAMPLE
    This example uses is from a pipeline

    Get-content c:\AllSIDS.txt | Convert-ECSSIDToAccount 

    #>
    [CmdletBinding()]
    Param
	    (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage="Enter a SID in the format of S-1-5-21 to retrive the NTAccount and SAMAccount names"
            )]
        [Validatescript(
            {
            #Validating if SID is in the correct format
            $SIDRegexPattern = "S-\d-\d-\d+"
            If ($_ -match $SIDRegexPattern)
                {
                $true
                }
            Else
                {
                Throw "The SID $SID you entered does not start with S-number-number-number... format needed"
                }
            })]
        $SID

        )
	    
    
    ##########################################################################################################
    #Process block

    process 
        {

        Foreach ($Object in $SID)
            {
            Try
                {
                Write-Verbose "########################################################"
                Write-Verbose "Attempting to convert $Object to AccountName"

                #Creating a SID object
                $objSID = New-Object System.Security.Principal.SecurityIdentifier ($Object) 

                #Translating the SID to the AccountName
                $SIDMapping = $objSID.Translate( [System.Security.Principal.NTAccount]) 

                Write-Verbose "SID lookup succeeded"

                New-Object PSObject -Property @{
                    NTAccount = $SIDMapping.Value
                    SAMAccountName = ($SIDMapping.Value -split "\\")[1]
                    SAMAccountNetBIOSName = ($SIDMapping.Value -split "\\")[0]
                    SID = $($Object)
                    AccountDomainSID = $($objSID.AccountDomainSid)
                    }
                }
            Catch
                {
                $Exception = $_.Exception 
                Write-Verbose "We had an exception looking up the SID, see below for the message"
                Write-verbose "$($Exception.Message)" 
                Write-Verbose "Failed to convert $Object to AccountName"

                New-Object PSObject -Property @{
                    NTAccount = "SID lookup failed"
                    SAMAccountName = "SID lookup failed"
                    SAMAccountNetBIOSName = "SID lookup failed"
                    SID = $($Object)
                    AccountDomainSID = "SID lookup failed"
                    }
                }
            }
        }

    #End Process block
    ##########################################################################################################

    }