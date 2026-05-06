output "servers" {
  value = {
    serverip = openstack_compute_instance_v2.server.access_ip_v4
  }
}