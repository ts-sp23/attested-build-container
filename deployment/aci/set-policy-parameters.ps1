$TMP=$(jq '.containers[].containerImage |= env.CONTAINER_REGISTRY+.' ./transparent-build-policy-in.json)
echo $TMP > ./transparent-build-policy-in.json
