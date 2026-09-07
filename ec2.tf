# ==========================================
# 1. IAM ACCESS MAPPINGS FOR EC2 CONTEXT
# ==========================================

resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "://amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "${var.environment}-secrets-read-policy"
  description = "Allows explicit reading mechanics across production secrets containers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.app_secret.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "aws_iam_policy.secrets_read_policy.arn"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ==========================================
# 2. ISOLATED INSTANCE FIREWALL DEFENCE
# ==========================================

resource "aws_security_group" "private_instance_sg" {
  name        = "${var.environment}-private-ec2-sg"
  description = "Shield boundaries enclosing internal compute resources"
  vpc_id      = aws_vpc.main.id

  # Completely omits port 22 entry vectors—connections run purely inside systems manager endpoints.

  egress {
    description = "Allow outward network mapping"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-private-ec2-sg"
    Environment = var.environment
  }
}

# ==========================================
# 3. RESOURCE COMPOSITION (AMI & COMPUTE)
# ==========================================

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Executing endpoint interface testing algorithms..." > /var/log/endpoint_test.log
              nslookup secretsmanager.${var.aws_region}.amazonaws.com >> /var/log/endpoint_test.log
              nslookup ssm.${var.aws_region}.amazonaws.com >> /var/log/endpoint_test.log
              EOF

  tags = {
    Name        = "${var.environment}-private-app-server"
    Environment = var.environment
  }
}
