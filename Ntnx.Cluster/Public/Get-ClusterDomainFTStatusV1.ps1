function Get-ClusterDomainFTStatusV1 {   
<#
.SYNOPSIS
Dynamically Generated API Function
.NOTES
NOT FOR PRODUCTION USE - FOR DEMONSTRATION/EDUCATION PURPOSES ONLY

The code samples provided here are intended as standalone examples.  They can be downloaded, copied and/or modified in any way you see fit.

Please be aware that all code samples provided here are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily modified before they can be used in a production environment.
#>

    [CmdletBinding()]
    [OutputType()]

    param(
        # VIP or FQDN of target AOS cluster
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        # Domain Fault Type 
        [Parameter(Mandatory=$false)]
        [ValidateSet("RACK","RACKABLE_UNIT","NODE","DISK")]
        [string]
        $DomainType,

        # Simplified Output
        [Parameter(Mandatory=$false)]
        [switch]
        $SimpleOutput,

        # Prism UI Credential to invoke call
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,

        # Port (Default is 9440)
        [Parameter(Mandatory=$false)]
        [int16]
        $Port = 9440
    )

    process {
        foreach ($c in $ComputerName){
            $headers = Initialize-BasicAuthHeader -credential $Credential
            $headers.Add("content-type", "application/json")

            $url = "https://$($ComputerName):$($Port)/PrismGateway/services/rest/v1/cluster/domain_fault_tolerance_status"

            if($DomainType){
                Write-Verbose -Message "FaultType is not NULL and will be checked for $DomainType"
                $url = $url+"/"+$DomainType
            }
            
            $response = Invoke-RestMethod -Method get -Uri $url -Headers $headers

            if($SimpleOutput){
                $responseAlt = foreach($r in $response){
                    $propList = $r.componentFaultToleranceStatus.psobject.properties.name
                    foreach($p in $propList){
                        $r.componentFaultToleranceStatus.$p | Add-Member -NotePropertyName "DomainType" -NotePropertyValue $r.domainType
                        $r.componentFaultToleranceStatus.$p | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $c
                        $r.componentFaultToleranceStatus.$p
                    }
                }
                Write-Output $responseAlt
            }
            else{
                Write-Output $response
            }
        }
    }       
}