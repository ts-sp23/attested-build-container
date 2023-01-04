if ($null -ne $env:initContainerID) {
    c:\ContainerPlat\crictl.exe stop $env:initContainerID
    c:\ContainerPlat\crictl.exe rm $env:initContainerID
    $env:initContainerID = $null
}
