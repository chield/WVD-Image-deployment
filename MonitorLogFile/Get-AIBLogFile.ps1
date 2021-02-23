$StorageAccountName = 'q7fplpn3pg91v9yhcacpuux6'
$TargetPath = 'C:\Temp\customization.log'
$r = Get-AzResourceGroup -Tag @{createdby = 'AzureVMImageBuilder' }
$s = Get-AzStorageAccount -ResourceGroupName $r.ResourceGroupName -Name $StorageAccountName
$p = Get-AzStorageContainer -Context $s.context | Where-Object { $_.Name -eq 'packerlogs' }
$container = Get-AzStorageBlob -Container $p.Name -Context $s.context
Get-AzStorageBlobContent -Container $p.Name -Context $s.context -Blob $container.Name -Destination $TargetPath -Force -ErrorAction SilentlyContinue


