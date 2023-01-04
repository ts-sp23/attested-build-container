if ($null -ne $env:buildContainerID) {
    c:\ContainerPlat\crictl.exe stop $env:buildContainerID
    c:\ContainerPlat\crictl.exe rm $env:buildContainerID
    $env:buildContainerID = $null    
}
