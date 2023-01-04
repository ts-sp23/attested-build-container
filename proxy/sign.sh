#!/bin/sh

POLICY_ISSUER=did:web:scitt.ht.vc
POLICY_FEED=delegation-policy
FEED=openssl

openssl ecparam -name prime256v1 -genkey -noout -out key.pem
openssl ec -in key.pem -pubout -out public.pem

scitt generate-attestation-report \
  --public-key public.pem \
  --get-snp-report /home/mitmproxy/get-snp-report \
  --out attestation.cbor

scitt sign \
  --key key.pem \
  --issuer "did:scitt:tee:$POLICY_FEED:$POLICY_ISSUER" \
  --feed "$FEED" \
  --content-type application/json \
  --claims claims.json \
  --attestation-report attestation.cbor \
  --out claims.cose

SCITT_URL="https://scitt-nord2.guest.corp.microsoft.com:8000"
scitt submit \
  --url $SCITT_URL \
  --development \
  --delegation-policy policy.cose \
  --receipt receipt.cose \
  claims.cose
