# indy-network

## Creating DIDs

Stewards and trustees will need to create one or more DIDs. The directions are as follows:

1. Install indy-cli-rs from https://github.com/hyperledger/indy-cli-rs
2. Generate random 32 character seed. Example in Bash: `head -c 32 /dev/random | base64 | head -c 32`
3. Run `indy-cli-rs`
4. Run `wallet create test key=password` (test and password can be replaced with other values, but make sure you remember both)
5. Run `wallet open test key=password`
6. Run `did new seed={seed}` (seed should be the random string you generated before)
7. Record the seed, DID, and VerKey
