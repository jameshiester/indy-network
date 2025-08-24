# indy-network

This repository is intended to provision a near production grade Hyperledger Indy Network including lower environments for development and testing.

## Folder Structure

The `terraform` directory includes two folders:

- `Repository:` This folder uses terraform to provision branches, branch protections, environments, environment variables, and secrets.

- `Infrastructure:` This folder uses terraform to provision the actual infrastructure. It is intended to be used by github actions triggered on specific branches for each environment. The input variables are a combination of environment variables and secrets configured by the repository folder.

The `docker` folder includes Dockfiles and scripts for several images that are used as part of the provisioning process, as well as services that will be part of the network.

The `packages` folder includes the javascript code associated with the API service and UI. This repository follows a turborepo monorepository pattern.

## Service Setup

- 4 Hyperledger Indy Nodes (see node Dockerfile) deployed across 2 EC2 instances in separate availability zones.
- An ECS service consisting of:
  - A `Server API` (see server Dockerfile) that pulls data from the nodes and creates a queryable interface for transactions, DIDs, Schemas, and Node status.
- An ECS sidecar container that allows the Server API to query the Node status.
- A Postgres DB used by the Server API

## Creating DIDs

Stewards and trustees will need to create one or more DIDs. The directions are as follows:

1. Install indy-cli-rs from https://github.com/hyperledger/indy-cli-rs
2. Generate random 32 character seed. Example in Bash: `head -c 32 /dev/random | base64 | head -c 32`
3. Run `indy-cli-rs`
4. Run `wallet create test key=password` (test and password can be replaced with other values, but make sure you remember both)
5. Run `wallet open test key=password`
6. Run `did new seed={seed}` (seed should be the random string you generated before)
7. Record the seed, DID, and VerKey
