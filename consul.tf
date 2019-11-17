resource "aws_instance" "server" {
  ami             = "${lookup(var.ami, "${var.region}-${var.platform}")}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  count           = "${var.servers}"
  security_groups = ["${aws_security_group.consul.id}"]
  subnet_id       = "${lookup(var.subnets, count.index % var.servers)}"

  connection {
    user        = "${lookup(var.user, var.platform)}"
    private_key = "${file("${var.key_path}")}"
  }

  #Instance tags
  tags {
    Name       = "${var.tagName}-${count.index}"
    ConsulRole = "Server"
  }

}

resource "aws_security_group" "consul" {
  name        = "consul_${var.platform}"
  description = "Consul internal traffic + maintenance."
  vpc_id      = "${var.vpc_id}"

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
