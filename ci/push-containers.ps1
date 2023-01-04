$containers = @('transparency-init:latest','transparent-build:latest','transparency-proxy:latest', 'transparent-policygen:latest')
Foreach ($container in $containers) {
  docker tag  $container $ENV:CONTAINER_REGISTRY"/"$container
  docker push $ENV:CONTAINER_REGISTRY"/"$container
}
