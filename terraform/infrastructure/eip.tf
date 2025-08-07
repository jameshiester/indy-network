resource "aws_network_interface" "public_1" {
  subnet_id   = module.vpc.public_subnets[0]
  private_ips = ["10.0.0.10"]
}

resource "aws_network_interface" "public_2" {
  subnet_id   = module.vpc.public_subnets[1]
  private_ips = ["10.0.1.10"]
}

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.public_1.id
  associate_with_private_ip = "10.0.0.10"
}

resource "aws_eip" "two" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.public_2.id
  associate_with_private_ip = "10.0.1.10"
}