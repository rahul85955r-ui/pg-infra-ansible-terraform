resource "aws_security_group" "this" {
  name   = var.name_tag
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "security_groups", [])
      description     = lookup(ingress.value, "description", "")
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = var.name_tag
    Role = var.role
    Env  = var.env
  }, var.tags)
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip
  vpc_security_group_ids      = [aws_security_group.this.id]

  # ONLY ONE user_data BLOCK ALLOWED
  user_data = <<-EOF
#!/bin/bash

# Create .ssh folder
mkdir -p /home/ubuntu/.ssh

# Add the private key from local file
cat << 'KEYEOF' > /home/ubuntu/.ssh/postgres-key
${file("${path.module}/../../keys/postgres-key")}
KEYEOF

chmod 600 /home/ubuntu/.ssh/postgres-key
chown ubuntu:ubuntu /home/ubuntu/.ssh/postgres-key

EOF

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  lifecycle {
    ignore_changes = [
      root_block_device,
      user_data,
    ]
  }

  tags = merge({
    Name = var.name_tag
    Role = var.role
    Env  = var.env
  }, var.tags)
}
