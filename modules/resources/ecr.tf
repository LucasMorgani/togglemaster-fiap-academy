# 1. Lista dos seus serviços
variable "project_repos" {
  type    = set(string)
  default = ["togglemaster_auth-service", "togglemaster_flag-service", "togglemaster_targeting-service", "togglemaster_evaluation-service", "togglemaster_analytics-service"]
}

# 2. Criação dos Repositórios (Loop)
resource "aws_ecr_repository" "main" {
  for_each = var.project_repos

  name                 = each.value # O nome vem da lista acima
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 3. Criação das Policies (Loop atrelado aos repositórios criados)
resource "aws_ecr_lifecycle_policy" "main" {
  # Truque: Fazemos o loop baseado nos recursos JÁ criados acima, 
  # garantindo que a policy só seja criada se o repo existir.
  for_each = aws_ecr_repository.main 

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as ultimas 5 imagens"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}