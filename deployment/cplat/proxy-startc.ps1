$env:proxyContainerID = c:\ContainerPlat\crictl.exe create --no-pull $env:podID .\lcow-container-proxy.json .\pod.json
c:\ContainerPlat\crictl.exe start $env:proxyContainerID 

