terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.43.0"
    }
     selectel = {
      source  = "selectel/selectel"
      version = "~> 3.6.2"
    }
  }
}

# Access data for Openstack
provider "openstack" {
  auth_url    = "https://api.selvpc.ru/identity/v3"
  domain_name = "222924"
  tenant_id = "6d026ff572a344f5ba7586a33997feef"
  user_name   = var.username
  password    = var.password
  region      = var.region
}

# Creating key-pair
resource "openstack_compute_keypair_v2" "key_rabbitmq" {
  name       = "key_tf"
  region     = var.region
  public_key = var.public_key
}

################ Network Operations ####################

# Filling external network variable
data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

# Creating a router
resource "openstack_networking_router_v2" "router_rabbitmq" {
  name                = "router_rabbitmq"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

# Creating a network
resource "openstack_networking_network_v2" "network_rabbitmq" {
  name = "network_rabbitmq"
}

# Creating a subnet
resource "openstack_networking_subnet_v2" "subnet_rabbitmq" {
  network_id = openstack_networking_network_v2.network_rabbitmq.id
  name       = "subnet_rabbitmq"
  cidr       = var.subnet_cidr
}

# Attaching subnet to the router
resource "openstack_networking_router_interface_v2" "router_interface_rabbitmq" {
  router_id = openstack_networking_router_v2.router_rabbitmq.id
  subnet_id = openstack_networking_subnet_v2.subnet_rabbitmq.id
}

# Floating address creation
resource "openstack_networking_floatingip_v2" "fip_rabbitmq" {
  count = var.vms_count
  pool  = "external-network"
}

################ Volume Creation ####################

resource "openstack_blockstorage_volume_v3" "volume_rabbitmq" {
  name                 = "volume_rabbitmq_${count.index}"
  count                = var.vms_count
  size                 = "20"
  image_id             = "8f3c4108-de09-4333-87ab-c53523d93557"
  volume_type          = var.volume_type
  availability_zone    = var.az_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}


################ Instance Creation ####################


resource "openstack_compute_instance_v2" "server_rabbitmq" {
  name              = "server_rabbitmq_${count.index}"
  count             = var.vms_count
  flavor_id         = var.flavor
  key_pair          = openstack_compute_keypair_v2.key_rabbitmq.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_rabbitmq.id
  }
  block_device {
    uuid             = "${element(openstack_blockstorage_volume_v3.volume_rabbitmq[*].id, count.index)}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }
  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}

################ Floating IP attaching ####################

resource "openstack_compute_floatingip_associate_v2" "afip_rabbitmq_0" {
  count = var.vms_count
  floating_ip = "${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.server_rabbitmq[*].id, count.index)}"
}

################ Ansible section ####################

# Rendering inventory	
resource "local_file" "inventory" {
  content = templatefile("./templates/inventory.tmpl",
    {
      ip0 = "${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 0)}"
      ip1 = "${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 1)}"
      ip2 = "${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 2)}"
    }
  )
  filename = "./inventory/hosts"
}

resource "local_file" "haproxy_vars" {
  content = <<-DOC
    ---
    server_rabbitmq_0: ${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 0)}
    server_rabbitmq_1: ${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 1)}
    server_rabbitmq_2: ${element(openstack_networking_floatingip_v2.fip_rabbitmq[*].address, 2)}
    DOC
  filename = "./roles/haproxy/vars/main.yml"
}


#####This role is starting to run before any vms is created, IDK why####
#resource "null_resource" "ansible-play" {
#  provisioner "local-exec" {
#    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ./inventory --private-key ~/.ssh/selectel deploy_servers.yml"
#  }
#}
