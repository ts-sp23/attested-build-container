// A template for the delegation policy to an attested build container pod.
// This should be customized with the container-specific logic

const registration_window = 24*60*60; // 1 day
const min_version = "2.0"
const max_version = "3.0"

function fresh_enough(c){ return new Date(1000 * (c.policy_info.issued_at + registration_window)) > new Date() }
function safe_signature_alg(a){ return a == "ES256" || a == "ES384" }
function delegate_did(feed,did) { return "did:tee:" + feed + ":" + did; } 
function assert(b, msg){
  if(!b) throw new Error(msg);
}

function decode(buf)
{
    const algs = {"-6": "ES256", "-35": "ES384", "-36": "ES512", "-37":"PS256", "-38":"PS384", "-39":"PS512"};
    const envelope = CBOR.decode(buf);
    const headers = CBOR.decode(buf.value[0]);
    
    assert(envelope.tag == 18, "Invalid envelope");
    assert(headers.has(1) && headers.has(3) && headers.has(391) && headers.has(392) && headers.has(393), "Missing required COSE or SCITT headers")
    assert(headers.get(1) in algs, "Unknown algorithm");

    return {
        alg: algs[headers.get(1)],
        cty: headers.get(3),
        issuer: headers.get(391),
        feed: headers.get(392),
        policy_info: headers.get(393),
        payload: envelope.value[2]
    }
}

function valid_claim(claim, cty, feed) {
    assert(claim.cty == cty && 
    (feed == undefined || claim.feed == feed) &&
    safe_signature_alg(claim.alg) && 
    fresh_enough(claim),
    "Input claim is not valid for policy");
};

// This function will be called by the registration endpoint
function main(ctx)
{
    // First, create a JS representation of the input claims
    const claim = decode(ctx.request.claim);
    const delegate = decode(ctx.request.delegate);
    const supporting = ctx.request.supporting.forEach(decode);
    const init_claims = JSON.parse(ctx.attest.init);
    const runtime_claims = JSON.parse(ctx.attest.init);

    assert(claim.issuer == delegate_did(delegate.issuer, delegate.feed), "The claim to register is not compatible with the delegation policy");
    valid_claim(claim, "application/x-container-sbom", delegate.feed);

    let policy = JSON.parse(ctx.attestation.init_claims);
    assert(policy, "Failed to parse container security policy")

    // Check the UVM image and init configuration
    let config = JSON.parse(delegate.payload);
    assert(policy.init_hash == delegate.init_hash && JSON.stringify(policy.init_claims) == JSON.stringify(delegate.init_claims));

    return true;
}

