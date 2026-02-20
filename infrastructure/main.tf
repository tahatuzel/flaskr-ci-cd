# --- Networking ---
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# --- Security Groups ---
module "security" {
  source         = "./modules/security"
  project_name   = var.project_name
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
}

# --- ECR ---
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

# --- IAM ---
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

# --- ALB ---
module "alb" {
  source                = "./modules/alb"
  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
}

# --- ECS ---
module "ecs" {
  source                = "./modules/ecs"
  project_name          = var.project_name
  aws_region            = var.aws_region
  ecr_repository_url    = module.ecr.repository_url
  execution_role_arn    = module.iam.ecs_task_execution_role_arn
  task_role_arn         = module.iam.ecs_task_role_arn
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_port        = var.container_port
  cpu                   = var.cpu
  memory                = var.memory
  desired_count         = var.desired_count
}
