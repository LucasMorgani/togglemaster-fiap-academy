module "eks_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = local.tags
}

module "eks_cluster" {
  source           = "./modules/cluster"
  project_name     = var.project_name
  tags             = local.tags
  public_subnet_1a = module.eks_network.public_subnet_1a
  public_subnet_1b = module.eks_network.public_subnet_1b
}

module "eks_mng" {
  source            = "./modules/manage-node-group"
  project_name      = var.project_name
  tags              = local.tags
  cluster_name      = module.eks_cluster.cluster_name
  private_subnet_1a = module.eks_network.private_subnet_1a
  private_subnet_1b = module.eks_network.private_subnet_1b
  eks_cluster_sg    = module.eks_cluster.eks_cluster_sg
}

module "resources" {
  source            = "./modules/resources"
  project_name      = var.project_name
  tags              = local.tags
  vpc_id            = module.eks_network.vpc_id
  vpc_cidr          = module.eks_network.vpc_cidr
  private_subnet_1a = module.eks_network.private_subnet_1a
  private_subnet_1b = module.eks_network.private_subnet_1b
  db_user           = var.db_user
  db_password       = var.db_password
}

module "kubernetes" {
  source           = "./modules/kubernetes"
  project_name     = var.project_name
  tags             = local.tags
  db_user          = var.db_user
  db_password      = var.db_password
  db_auth_endpoint = module.resources.db_auth_endpoint
  #db_auth_name      = module.resources.db_auth_name
  db_flag_endpoint = module.resources.db_flag_endpoint
  #db_flag_name      = module.resources.db_flag_name
  db_targeting_endpoint = module.resources.db_targeting_endpoint
  #db_targeting_name      = module.resources.db_targeting_name
  evaluation_db_endpoint = module.resources.evaluation_db_endpoint
  sqs_queue_url          = module.resources.sqs_queue_url
  dynamodb_url           = module.resources.dynamodb_url
  depends_on             = [module.eks_cluster, module.eks_mng]
}