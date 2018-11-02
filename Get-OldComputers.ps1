<# Script: Get-OldComputers
# Author: RChapman
# Date: 4-11-2017
#Description: Based on the last modified date returns a list of computers older then the num
#days specified
#>
<#

    .SYNOPSIS
        Returns an an AD Computer representing a computer no modified in AD for more then x days. 

    .DESCRIPTION
        Returns an an AD Computer representing a computer no modified in AD for more then x days.  
        The value for x is specified as the parameter pComputerNumDayOld.

    .PARAMETER pComputerNumDayOld
        How manys days since computer object was modified should be used to condsider if a computer is old. 

    .PARAMETER pFilter
        A valid PowerShell filter string for AD.  See examples. 
    
    .PARAMETER pSearchBase
        The OU in which to begin searching as a vaild DN string for the OU. 

    .OUTPUTS
        An Active Directory computer object. 

    .EXAMPLE
        Get-OldComputers.ps1 -pComputerNumDayOld 90 -pFilter * -pSearchBase 'OU=Labs,DC=fortlewis,DC=edu'


#>

#Parameters
#Number of days old is mandatory, search base and filter are not but have defaults

 [cmdletBinding()]
param(
   
    #Number of days old
    [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $false)]
    [int] $pComputerNumDayOld,
    #Num of days old

    #filter
    #filter syntax must be a valid PowerShell filter.
    #Example: {Name -like 'EBH38*'}
    [Parameter(
    Mandatory = $false,
    ValueFromPipeline = $false)]
    [string] $pFilter = "*",
    #filter

    #seach base as DN
    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false
    )]
    [string] $pSearchBase = "OU=Labs,DC=fortlewis,DC=edu" 
    #search base as DN
)
#Param

BEGIN{

    Try{
        Import-Module ActiveDirectory -ErrorAction Stop
    } Catch {
        Write-Output "Could not import active directory module"
        break
    }

    $searchFilter = $pFilter
    $searchBase = $pSearchBase
    $daysOld = -($pComputerNumDayOld)
} #BEGIN

PROCESS{
    #Ask AD for the computers at the specified filter, Include Name and whenChanged properties

    $ADComputers = Get-ADComputer -Filter $searchFilter -SearchBase $searchBase -SearchScope Subtree -Properties Name, whenChanged

    #Search ADComputers for older then 90 dates using .Net DateTime AddDays method
    $oldComputers = ($ADComputers | Where-Object {$_.whenChanged -le ([DateTime]::Now.AddDays($daysOld))})

    #Send the objet to the output stream
    #$oldComputers

    #Create an output object for each old computer

    $oldComputers

}#PROCESS

END{

    #$outputObject = New-Object -Type PSObject -Property @{Name = $oldComputers.Name; LastModified = $oldComputers.whenChanged}

    #$oldComputers

}#END

