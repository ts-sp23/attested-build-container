$CCE_POLICY=(az confcom acipolicygen -i ./transparent-build-policy-in.json)

$ACI_PARAMETERS='{\"containerRegistry\": {\"value\":\"' + $ENV:CONTAINER_REGISTRY `
  + '\"}, \"containerRegistryUsername\": {\"value\":\"' + $ENV:CONTAINER_REGISTRY_USERNAME `
  + '\"}, \"containerRegistryPassword\": {\"value\":\"' + $ENV:CONTAINER_REGISTRY_PASSWORD `
  + '\"}, \"ccePolicy\": {\"value\":\"' + $CCE_POLICY `
  + '\"}}'

az deployment group create --resource-group $ENV:RESOURCE_GROUP `
  --template-file ./transparent-build-deployment.json `
  --parameters $ACI_PARAMETERS
