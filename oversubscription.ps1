$vcenter = "192.168.0.1"
Connect-VIServer $vcenter

$TotalNumvCPUs = 0
$TotalCPUCores = 0
$TotalRAM = 0
$TotalvRAM = 0

Foreach ($Cluster in (Get-Cluster |Sort Name)){
Write-Host ""
Write-Host ""
Write-Host “Cluster: $($Cluster.name)“
Foreach ($ESXHost in ($Cluster |Get-VMHost |Sort Name)){
Write-Host “———-“
Write-Host “ Host: $($ESXHost.name)“
Write-Host ""
$CPUCores = $null
$CPUCores = ($ESXHost).NumCPU
$RAM = $null
$RAM = [math]::Round(($ESXHost).MemoryTotalGB)
$TotalCPUCores += $CPUCores
$TotalRAM += $RAM
 
Write-Host “ Physical Cores:                      $CPUCores“
Foreach ($VM in ($ESXHost |Get-VM | Where-Object{$_.powerstate -eq 'PoweredOn'})){
$HostNumvCPUs += ($VM).NumCpu
}
Foreach ($VM in ($ESXHost |Get-VM | Where-Object{$_.powerstate -eq 'PoweredOn'})){
$HostNumvRAM += ($VM).MemoryGB
}
Write-Host “ Number of vCPU on host:              $($HostNumvCPUs)“
$HostOversubscription = [math]::Round($HostNumvCPUs/$CPUCores,2)
$RAMOversubscription = [math]::Round($HostNumvRAM/$RAM,2)

Write-Host " CPU Oversubscription ratio:          $($HostOversubscription):1"
Write-Host ""
Write-Host " Physical Memory in GB:               $RAM"
Write-Host " Total Virtual Memory on Host in GB:  $HostNumvRAM"
Write-Host " RAM Oversubscription ratio:          $($RAMOversubscription):1"
$TotalNumvCPUs += $HostNumvCPUs
$TotalvRAM += $HostNumvRAM
$HostNumvCPUs = 0
$HostNumvRAM = 0
}
$CPUOversubscription = [math]::Round($TotalNumvCPUs/$TotalCPUCores,2)
$RAMOversubscription = [math]::Round($TotalvRAM/$TotalRAM,2)
Write-Host ""
Write-Host “———-“
Write-Host "Number of Physical Cores in $($Cluster.name):       $TotalCPUCores"
Write-Host “Number of vCPU in $($Cluster.name):                 $TotalNumvCPUs“
Write-Host "CPU Oversubscription ratio on cluster: $($CPUOversubscription):1"
Write-Host ""
Write-Host "Total Physical RAM in $($Cluster.name):             $TotalRAM"
Write-Host "Total vRAM in $($Cluster.name):                     $TotalvRAM"
Write-Host "RAM Oversubscription ratio on cluster: $($RAMOversubscription):1"
Write-Host “———-“
Write-Host “”
$TotalNumvCPUs = 0
}