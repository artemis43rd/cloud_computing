resource "openstack_networking_secgroup_v2" "sg" {
  name = "cherdantsev-sg-trfm"
}

# SSH
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

# Postgres
resource "openstack_networking_secgroup_rule_v2" "db" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 5432
  port_range_max = 5432
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

# Kafka
resource "openstack_networking_secgroup_rule_v2" "kafka" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 9092
  port_range_max = 9092
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_compute_instance_v2" "server" {
  name            = "cherdantsev-server-trfm"
  image_name      = var.image_name
  flavor_name     = var.server_flavor
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.sg.name]

  network {
    name = var.network_name
  }
}

output "server_ip" {
  value = openstack_compute_instance_v2.server.access_ip_v4
}