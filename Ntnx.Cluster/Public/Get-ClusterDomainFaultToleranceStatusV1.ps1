function Get-ClusterDomainFaultToleranceStatusV1 {   
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

        # Prism UI Credential to invoke call
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,

        # Domain Fault Type 
        [Parameter(Mandatory=$false)]
        [ValidateSet("RACK","RACKABLE_UNIT","NODE","DISK")]
        [string]
        $DomainType,

        # Simplified Output
        [Parameter(Mandatory=$false)]
        [switch]
        $SimpleOutput,

        [Parameter(Mandatory=$false)]
        [switch]
        $SkipCertificateCheck,

        [Parameter(Mandatory=$false)]
        [switch]
        $ShowMetadata,

        # Port (Default is 9440)
        [Parameter(Mandatory=$false)]
        [int16]
        $Port = 9440
    )

    begin {
        Set-StrictMode -Version Latest
    }

    process {
        $body = [Hashtable]::new()
        #$body.add("BodyParam1",$BodyParam1)

        $iwrArgs = @{
            Uri = "https://$($ComputerName):$($Port)/PrismGateway/services/rest/v1/cluster/domain_fault_tolerance_status"
            Method = "GET"
            ContentType = "application/json"
            ErrorVariable = "iwrError"
        }

        if($DomainType){
            Write-Verbose -Message "FaultType is not NULL and will be checked for $DomainType"
            $iwrArgs.uri += "/"+$DomainType
        }

        if($body.count -ge 1){
            $iwrArgs.add("Body",($body | ConvertTo-Json))
        }

        if($PSVersionTable.PSVersion.Major -lt 6){
            $basicAuth = Initialize-BasicAuthHeader -credential $Credential
            $iwrArgs.Add("headers",$basicAuth)
        }
        else{
            $iwrArgs.add("Authentication","Basic")
            $iwrArgs.add("Credential",$Credential)
            $iwrArgs.add("SslProtocol","Tls12")

            if($SkipCertificateCheck){
                $iwrArgs.add("SkipCertificateCheck",$true)
            }
        }
        
        try{
            $response = Invoke-WebRequest @iwrArgs

            if($response.StatusCode -in 200..204){
                $content = $response.Content | ConvertFrom-Json

                if($SimpleOutput){
                    $responseAlt = foreach($r in $content){
                        $propList = $r.componentFaultToleranceStatus.psobject.properties.name
                        foreach($p in $propList){
                            $r.componentFaultToleranceStatus.$p | Add-Member -NotePropertyName "DomainType" -NotePropertyValue $r.domainType
                            $r.componentFaultToleranceStatus.$p | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $ComputerName
                            $r.componentFaultToleranceStatus.$p
                        }
                    }
                    Write-Output $responseAlt
                }
                else{
                    Write-Output $content
                }
            }
            elseif($response.StatusCode -eq 401){
                Write-Verbose -Message "Credential used not authorized, exiting..."
                Write-Error -Message "$($response.StatusCode): $($response.StatusDescription)"
                exit
            }
            else{
                Write-Error -Message "$($response.StatusCode): $($response.StatusDescription)"
            }   
        } 
        catch{
            Write-Error -Message "API Call Failed"
            Write-Error -Message $iwrError.Message
        }
    }
                
}
