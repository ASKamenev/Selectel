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
     ansible = {
      source = "habakke/ansible"
      version = "~> 1.0"
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
  pool = "external-network"
}

################ Volume Creation ####################

resource "openstack_blockstorage_volume_v3" "volume_rabbitmq_0" {
  name                 = "volume_rabbitmq_0"
  size                 = "20"
  image_id             = "8f3c4108-de09-4333-87ab-c53523d93557" 
  volume_type          = var.volume_type 
  availability_zone    = var.az_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_rabbitmq_1" {
  name                 = "volume_rabbitmq_1"
  size                 = "20"
  image_id             = "8f3c4108-de09-4333-87ab-c53523d93557"
  volume_type          = var.volume_type
  availability_zone    = var.az_zone
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_blockstorage_volume_v3" "volume_rabbitmq_2" {
  name                 = "volume_rabbitmq_2"
  size                 = "20"
  image_id             = "8f3c4108-de09-4333-87ab-c53523d93557"
  volume_type          = var.volume_type
  availability_zone    = var.az_zone 
  enable_online_resize = true
  lifecycle {
    ignore_changes = [image_id]
  }
}

################ Stack Creation ####################

# Deploying first stack
resource "openstack_compute_instance_v2" "server_rabbitmq_0" {
  name              = "server_rabbitmq_0"
  flavor_id         = var.flavor
  key_pair          = openstack_compute_keypair_v2.key_rabbitmq.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_rabbitmq.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_rabbitmq_0.id
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

# Attach floating IP to first stack
resource "openstack_compute_floatingip_associate_v2" "fip_rabbitmq-0" {
  floating_ip = openstack_networking_floatingip_v2.fip_rabbitmq.address
  instance_id = openstack_compute_instance_v2.server_rabbitmq_0.id
}

# Deploying second stack
resource "openstack_compute_instance_v2" "server_rabbitmq_1" {
  name              = "server_rabbitmq_1"
  flavor_id         = var.flavor
  key_pair          = openstack_compute_keypair_v2.key_rabbitmq.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_rabbitmq.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_rabbitmq_1.id
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

# Deploying third stack
resource "openstack_compute_instance_v2" "server_rabbitmq_2" {
  name              = "server_rabbitmq_2"
  flavor_id         = var.flavor
  key_pair          = openstack_compute_keypair_v2.key_rabbitmq.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_rabbitmq.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_rabbitmq_2.id
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


