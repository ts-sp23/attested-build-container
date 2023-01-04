#!/bin/sh
dockerd &> dockerd-logfile &
sleep 5

T1=$(date +%s);

echo "Cloning repo $GITHUB_REPO..."
if [ ! -z $USERNAME ] && [ ! -z $PERSONAL_ACCESS_TOKEN ]
then
  git clone --recursive https://$USERNAME:$PERSONAL_ACCESS_TOKEN@$GITHUB_REPO code 
else 
  git clone --recursive https://$GITHUB_REPO code 
fi
cd code 

if [ ! -z $BRANCH ] 
then
  echo "Checking out branch $BRANCH..."
  git checkout $BRANCH
fi

echo "Switching directory to $BUILD_DIR..."
cd $BUILD_DIR

echo "Build command $BUILDCMD"
if [ ! -z "$BUILDCMD" ]
then 
  echo "Running $BUILDCMD..."
  echo $BUILDCMD > run.sh
  source run.sh

else  
  sed '/FROM/ a COPY mitmproxy-ca-cert.crt /usr/local/share/ca-certificates/' $DOCKER_FILE > Dockerfile.ca.1
  sed '/COPY mitm/ a RUN update-ca-certificates' Dockerfile.ca.1 > Dockerfile.ca

  echo "Copying proxy certificate to context directory"
  echo "cp /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt $CONTEXT_DIR"
  cp /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt $CONTEXT_DIR

  echo "Building target $TARGET..."
  docker build -f Dockerfile.ca $CONTEXT_DIR --network host -t $TARGET
fi

echo "Build time..."
T2=$(date +%s);
echo $((T2-T1)) | awk '{printf "%d:%02d:%02d", $1/3600, ($1/60)%60, $1%60}'

echo "Saving target..."
rm -rf out && mkdir out && cd out 

# could also write to attached STDOUT to save space 
docker image save $TARGET | gzip > image.tgz
docker image inspect $TARGET > inspect.json
docker history $TARGET > history.txt

echo "done."

echo "Obtaining claims..."
curl http://transparency.com/generateClaim