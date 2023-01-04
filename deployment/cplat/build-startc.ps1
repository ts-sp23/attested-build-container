$env:buildContainerID = c:\ContainerPlat\crictl.exe create --no-pull $env:podID .\lcow-container-build.json .\pod.json
c:\ContainerPlat\crictl.exe start $env:buildContainerID 

