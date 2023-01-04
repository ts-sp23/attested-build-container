#!/bin/sh
dockerd &> dockerd-logfile &
sleep 5

echo "Cloning repo $GITHUB_REPO..."
if [ ! -z $USERNAME ] && [ ! -z $PERSONAL_ACCESS_TOKEN ]
then
  git clone https://$USERNAME:$PERSONAL_ACCESS_TOKEN@$GITHUB_REPO code 
else 
  git clone https://$GITHUB_REPO code 
fi
cd code 

echo "Checking if confcom tool is loaded"
az confcom -h

echo "Generating policy from $POLICY_IN"
POLICY=$(az confcom acipolicygen --input $POLICY_IN)
echo "Generated policy $POLICY"

echo "Obtaining claims..."
curl http://transparency.com/generateClaim