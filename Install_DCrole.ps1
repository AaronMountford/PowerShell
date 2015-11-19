$newDomainName="mydomain.co.nz"
$netBiosDomainName="netbiosdomain"
$dbPath="F:\Windows\NTDS"    #essential to move off C drive for Azure VMs due to caching


# Install AD DS Role
Install-WindowsFeature AD-Domain-Services, RSAT-ADDS

# Install AD DS on first DC in domain and forest:
Import-Module ADDSDeployment
Install-ADDSForest
	-DomainName $newDomainName `
	-DatabasePath $dbPath `
	-DomainNetbiosName $netBiosDomainName `
	-InstallDns




