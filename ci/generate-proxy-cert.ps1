cd ../proxy

# Remove existing certs 
rm -rf mitmproxy-ca.pem
rm -rf mitmproxy-ca-cert.crt
rm -rf mitmproxy-ca-cert.pem
rm -rf mitmproxy-ca.key

# Generate new certs
# https://docs.mitmproxy.org/stable/concepts-certificates/
# Filename	Contents
# mitmproxy-ca.pem	The certificate and the private key in PEM format.
# mitmproxy-ca-cert.pem	The certificate in PEM format. Use this to distribute on most non-Windows platforms.
# mitmproxy-ca-cert.p12	The certificate in PKCS12 format. For use on Windows.
# mitmproxy-ca-cert.cer	Same file as .pem, but with an extension expected by some Android devices.

openssl genrsa -out mitmproxy-ca.key 2048
openssl req -x509 -new -nodes -key mitmproxy-ca.key -sha256 -days 1826 -out mitmproxy-ca-cert.crt -subj '/CN=MITM Proxy Root CA/C=UK/ST=Cambridge/L=Cambridge/O=MITMProxy'

cp mitmproxy-ca-cert.crt mitmproxy-ca-cert.pem
cat mitmproxy-ca.key mitmproxy-ca-cert.crt > mitmproxy-ca.pem

# Copy cert to build folder
cp mitmproxy-ca-cert.crt ../transparent-build/

cd ../ci
