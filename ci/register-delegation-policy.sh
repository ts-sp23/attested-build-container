SCITT_URL="https://scitt-nord2.guest.corp.microsoft.com:8000"
POLICY_FEED=delegation-policy
WORKDIR=.

openssl ecparam -name prime256v1 -genkey -noout -out priv.pem
openssl ec -in key.pem -pubout -out public.pem

scitt sign \
  --key $PRIVATE_KEY \
  --issuer did:web:scitt.ht.vc \
  --out $WORKDIR/policy.cose \
  --content-type application/json \
  --claims $WORKDIR/policy.json \
  --feed $POLICY_FEED

scitt submit \
  --url $SCITT_URL \
  --development \
  $WORKDIR/policy.cose
  