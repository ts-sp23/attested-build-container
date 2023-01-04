"""
Run as follows: mitmproxy -s issuer.py
"""
from mitmproxy import http
import logging
import json
from hashlib import sha256
import os

class Event(dict): 
    def __init__(self, url, response_digest):
        dict.__init__(self, url=url, response_digest=response_digest)

class Issuer:
    def __init__(self):
        self.events = list()

    def generateClaim(self, flow):
        logging.info("Number of urls:" + str(len(self.events)))
        claim_file = open("claims.json", "w")
        claim_file.write(json.dumps(self.__dict__))
        claim_file.close()

        ret = os.system('/bin/sh -c ./sign.sh')
        flow.response = http.Response.make(
            200 if ret == 0 else 404
        )

    def request(self, flow):
        logging.info("Request:" + flow.request.pretty_url)
        if flow.request.pretty_url == "http://transparency.com/generateClaim":
            self.generateClaim(flow)

    def response(self, flow):
        digest = 0
        if flow.response.content:
            digest = sha256(flow.response.get_content()).hexdigest()
            logging.info("Response:" + str(flow.response.status_code) + ":" + digest)
        self.events.append(Event(flow.request.pretty_url, digest))

addons = [Issuer()]
