if ($null -ne $env:proxyContainerID) {
    c:\ContainerPlat\crictl.exe stop $env:proxyContainerID
    c:\ContainerPlat\crictl.exe rm $env:proxyContainerID
    $env:proxyContainerID = $null
}
