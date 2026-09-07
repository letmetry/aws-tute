resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "app_secret" {
  name                    = "${var.environment}-database-credentials"
  description             = "Database configuration map allocated for internal app server tracking"
  recovery_window_in_days = 0 

  tags = {
    Name        = "${var.environment}-database-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secret_val" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    username = "admin_user"
    password = random_password.db_password.result
    dbname   = "production_db"
  })
}
