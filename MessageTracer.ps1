# -----------------------------------------------------------------------------
# Script: MessageTracer.ps1
# Author: Aaron Mountford
# Date: 27/10/2015
# Keywords: 
# -----------------------------------------------------------------------------
  <#
   .Synopsis
    Gets Exchange Message Logs for given sender and past number of days
   .Description
    Outputs to CSV file.  Uses a join to output multi-valued properties.
   .Example
   MessageTracer.ps1 -Sender user@abc.com -Days 5
 #>

param (
    [string]$sender = "Christopher.Young@minterellison.co.nz",
    [int]$days = 7
 )

$outfile=".\exchangetrace.csv"

Get-MessageTrackingLog -Start (Get-Date).AddDays(-$days) `
                       -Sender $sender `
                       -ResultSize Unlimited  | 
                       Select TimeStamp,EventID,Source,@{Name=’Recipients';Expression={[string]::join(“;”, ($_.Recipients))}},MessageSubject |
                       Export-CSV $outfile

Write-Host "Output written to $outfile"

Write-Host "Changed"