$env:initContainerID = c:\ContainerPlat\crictl.exe create --no-pull $env:podID .\lcow-container-init.json .\pod.json
c:\ContainerPlat\crictl.exe start $env:initContainerID 
echo $env:initContainerID
