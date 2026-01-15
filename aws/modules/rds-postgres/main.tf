# ------------------------------------------------------------------------------
# RDS PostgreSQL Module
# Creates a PostgreSQL RDS instance with optional read replica,
# security groups, and parameter groups.
# ------------------------------------------------------------------------------

locals {
  port = 5432
}

# ------------------------------------------------------------------------------
# Subnet Group
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

# ------------------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "main" {
  name        = "${var.name}-rds"
  description = "Security group for ${var.name} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-rds"
  })
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.allowed_security_group_ids) > 0 ? length(var.allowed_security_group_ids) : 0

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.main.id
  description              = "Allow PostgreSQL from authorized security groups"
}

resource "aws_security_group_rule" "ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.main.id
  description       = "Allow PostgreSQL from authorized CIDR blocks"
}

# ------------------------------------------------------------------------------
# Parameter Group
# ------------------------------------------------------------------------------

resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-params"
  family = "postgres${var.engine_version}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# RDS Instance
# ------------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = var.name

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  port = local.port

  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name

  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  delete_automated_backups  = true
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"
  skip_final_snapshot       = var.skip_final_snapshot

  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  deletion_protection = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# Secrets Manager (optional)
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "main" {
  count = var.create_secret ? 1 : 0

  name        = "${var.name}-db-credentials"
  description = "Database credentials for ${var.name}"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "main" {
  count = var.create_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.main[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password
    host     = aws_db_instance.main.address
    port     = local.port
    database = var.database_name
    url      = "postgresql://${var.master_username}:${var.master_password}@${aws_db_instance.main.address}:${local.port}/${var.database_name}"
  })
}
