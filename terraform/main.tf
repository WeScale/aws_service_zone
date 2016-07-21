provider "aws" {}

resource "aws_iam_role" "ami_building_role" {
  name = "ami_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ami_building_policy" {

  name = "ami_service_policy"

  role = "${aws_iam_role.ami_building_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ami_building_instance_profile" {
  name = "ami_service_instance_profile"
  roles = ["${aws_iam_role.ami_building_role.name}"]
}


resource "aws_instance" "bastion" {

  ami = "${var.bastion_ami_id}"
  instance_type = "${var.bastion_instance_type}"
  key_name = "${var.keypair}"
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.bastions.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ami_building_instance_profile.id}"

  user_data = <<EOF
#cloud-config
write_files:
  - path: /etc/default/aws_env
    permissions: 440
    content: |
      PUBLIC_SUBNET_ID: "${var.public_subnet_id}"
      PRIVATE_SUBNET_ID: "${var.private_subnet_id}"
      BASTION_REALM_SG_ID: "${aws_security_group.bastion_realm.id}"
EOF

  tags {
    Name = "bastion-${var.vpc_name}-${var.az_1}"
    Bastion_realm_sg_id = "${aws_security_group.bastion_realm.id}"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.vpc_name}-bucket"
  acl = "private"

  tags {
    Name = "${var.vpc_name}-bucket"
    Environment = "${var.vpc_name}"
  }
}

resource "aws_security_group" "bastions" {
  name = "service_bastions"
  description = "Allow SSH traffic from the internet"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_realm" {
  name = "service_bastion_realm"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastions.id}"]
  }
}
