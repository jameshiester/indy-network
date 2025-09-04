# Genesis Transaction Setup

One challenge of provisioning an Indy network is that the genesis transaction needs to be created before starting the nodes. The genesis transaction includes node address information so that other nodes and agents can be bootstrapped to the network. This requires defining both the public and private IP for each node as well as their associated public keys.

## Handling Node IPs

Indy requires having a constant IP address assigned to each node. This makes it more difficult to leverage serverless architectures or solutions where IP addresses may be more transient, such as with Kubernetes. While it is possible to address these challenges using load balancers and other networking/configuration methods, the intended use case for this repository benefits from using the EC2 instance approach with each node being provisioned inside a VPC.

1.  The Node IP address can be hardcoded to an IP within the CIDR range of the VPC.
2.  The Node IP can only be accessed from within the VPC, providing some level of protection from DDoS and other attack vectors.
3.  The Node traffic can be routed within the VPC, without going out over public internet providing greater security, performance, and lower costs.
4.  Development complexity is significantly lower

## Handling Seeds

Seeds for each node, the genesis stewards, and genesis trustees are provisioned by the Terraform infrastructure using AWS Secrets Manager before the container is started. The terraform uses these seeds as well as scripts in the genesis container, which generates the same keys that will be used by the actual node container (the algorithm is deterministic) but saves the public components to the csv file that is used in the terraform to generate the genesis transaction.

## Creating the Genesis Transaction

The genesis files are created using a local-exec resource in terraform and saved as objects in S3. Scripts within Docker containers are used to simplify the dependencies that must be installed in the build progress and ensure continuing support for the crypto libraries which depend on older versions of Ubuntu and Python. There are technically mutliple genesis files, but the pool file is most significant
