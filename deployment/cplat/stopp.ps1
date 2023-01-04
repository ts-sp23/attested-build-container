if ($null -ne $env:podID) {
    C:\ContainerPlat\crictl.exe stopp $env:podID
    C:\ContainerPlat\crictl.exe rmp $env:podID
    $env:podID = $null
}
