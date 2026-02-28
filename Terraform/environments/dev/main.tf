module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr = var.vpc_cidr
}

module "security_group" {
  source = "../../modules/security-groups"

  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "../../modules/iam"
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id         = var.ami_id
  instance_type  = var.instance_type
  subnet_id      = module.vpc.public_subnet_id
  sg_id          = module.security_group.sg_id
  instance_profile = module.iam.instance_profile
}