# Transparent Build Service

**PLEASE NOTE: for anonymity, some repository, folder and file names have been changed which can cause some scripts to fail. The code in this repository is meant for review only and the final version of the paper will point to the real open source repositories**

# Pre-prequisites
- [Docker](https://www.docker.com/products/docker-desktop).  
- All scripts are written in [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/overview) to work cross-platform. If you are on Linux, follow [these
instructions](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux)
to install PowerShell. Once its installed, you can run the ```pwsh``` command to start the shell. 
- Azure command line tools.

## Build containers
Build containers using the following script. 
```powershell
cd $REPOSITORY_ROOT_PATH/ci
./build-containers.ps1
```
This will build the following containers. 
1. Transparent build container
2. Transparecy sidecar
3. Transparency proxy based on envoy which intercepts and redirects HTTP traffic through the transparency sidecar. 
4. Init container which configures iptable rules to the proxy

## Publish the container images

To publish the locally built container images, you need a container registry account, such as
with [Azure Container Registry](https://azure.microsoft.com/services/container-registry/) (ACR). 
Once you have access to an account, edit the file set-env.ps1, specify the name of the container registry, username and password. 

Set the environment variables
```powershell
./set-env.ps1
```

Login to your Azure subscrption and container registry 
```powershell
az login
az acr login -n $ENV:CONTAINER_REGISTRY
```

Finally, tag and push the container images in `powershell`:
```powershell
./deployment/aci/push-containers.ps1
```
## Deploy to Confidential ACI
To deploy the container group to Confidential ACI, first install Azure command line tools for confidential containers. This is a one time task. 
```powershell
az extension add --source https://acccliazext.blob.core.windows.net/confcom/confcom-0.1.2-py3-none-any.whl -y
```

Next, generate a container security policy from the policy template. 

```powershell
cd deployment/aci
./set-policy-parameters.ps1
```

Finally, deploy the service. 
```powershell
./deploy-transparent-build-service.ps1
```
