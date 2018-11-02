<# Script: Rename-LabComputers
# Author: RChapman
# Date: 6-21-2017
#Description: 
#>
<#

    .SYNOPSIS
        Replaces a part of a computer name with a new value and renames the computer. 

    .DESCRIPTION
        Replaces a part of a computer name with a new value and renames the computer. Use to rename a computer when they move to a new building.

    .PARAMETER pOldNamePrefix
        The name component to replace

    .PARAMETER pNewNamePrefix
        The new value for the name component being replaced

    .PARAMETER pComputersToRename
        The name of the computer to effect.  Hostname (not FQDN) as a string or string array.

    .PARAMETER pLogFilePath
        Full path to location where a log file should be written.
    
    .PARAMETER pForceComputerReboot
        Force the computer to reboot after rename.  New name will not take affect until reboot.
    
    .PARAMETER

    .INPUTS
        Pipe in a string for each computers name.  Not an FQDN. 

    .OUTPUTS
        Outputs a computer changed info object. 
    .EXAMPLE

         Get-Content C:\Users\username\Desktop\gpe2771.txt | .\Rename-LabComputers.ps1 -Verbose -pOldNamePrefix GPE -pNewNamePrefix SFH -pLogFilePath E:\gpe.txt



#>

[cmdletBinding()]
param(

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $false
    )]
    [string] $pOldNamePrefix,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $false
    )]
    [string] $pNewNamePrefix,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    [string[]] $pComputersToRename,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $false
    )]
    [string] $pLogFilePath,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false
    )]
    [switch] $pForceComputerReboot,

    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $false
    )]
    [pscredential]$pCredential = (Get-Credential)
)

BEGIN {
Write-Verbose "Old name prefix: $pOldNamePrefix"
Write-Verbose "New name prefix: $pNewNamePrefix"
Write-Verbose "Force reboot: $pForceComputerReboot"
Write-Verbose "Log path: $pLogFilePath"

}

PROCESS {

    foreach ($computer in $pComputersToRename) {
    
    #check if computer is alive and then rename

        If ($(Test-Connection -Quiet -ComputerName $computer)) {
                #Check for currently logged in user
                $loggedInUser = @(Get-WmiObject -ComputerName $computer `
                    -Class Win32_ComputerSystem `
                    -Credential $pCredential `
                    -ErrorAction SilentlyContinue)[0].UserName

                If (![string]::IsNullOrEmpty($loggedInUser)) {
                    #User logged in skip
                    Write-Output "$loggedInUser is logged into computer $computer" | Tee-Object -FilePath $pLogFilePath -Append

                    Break
                }
                Else {
                    #No logged in user rename
                    # $oldNameSuffixLength = ($pNewNamePrefix.Length)
                    # $newNameSuffix = $computer.Substring($oldNameSuffixLength)
                    # $newName = ($pNewNamePrefix + $newNameSuffix)
                    New-Object -TypeName System.String $computer 
                    $newName = $computer.Replace($pOldNamePrefix,$pNewNamePrefix)

                    Write-Verbose $newName
                    $computerChangedOutput = Rename-Computer -ComputerName $computer `
                        -DomainCredential $pCredential `
                        -NewName $newName `
                        -Restart:$pForceComputerReboot `
                        -PassThru
                    Write-Output $computerChangedOutput | Tee-Object -FilePath $pLogFilePath -Append
                }

            } Else {
                Write-Output "$computer is offline." | Tee-Object -FilePath $pLogFilePath -Append

            }
     

    }

}

END {


}