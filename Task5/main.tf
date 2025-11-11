terraform {
	required_version = ">= 1.5.0, < 2.0.0"
	required_providers {
		yandex = {
			source  = "yandex-cloud/yandex"
			version = "~> 0.115"
		}
		random = {
			source  = "hashicorp/random"
			version = "~> 3.6"
		}
	}
}

provider "yandex" {
	cloud_id  = var.cloud_id
	folder_id = var.folder_id
	zone      = var.zone
}

# Сеть
resource "yandex_vpc_network" "this" {
	name = "${var.project}-net"
}

resource "yandex_vpc_subnet" "public" {
	name           = "${var.project}-subnet-public"
	network_id     = yandex_vpc_network.this.id
	zone           = var.zone
	v4_cidr_blocks = [var.public_subnet_cidr]
}

resource "yandex_vpc_subnet" "private" {
	name           = "${var.project}-subnet-private"
	network_id     = yandex_vpc_network.this.id
	zone           = var.zone
	v4_cidr_blocks = [var.private_subnet_cidr]
	route_table_id = yandex_vpc_route_table.private.id
}

# Общий egress gateway и маршрут для приватной подсети
resource "yandex_vpc_gateway" "egress" {
	name                 = "${var.project}-egress"
	shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
	network_id = yandex_vpc_network.this.id
	static_route {
		destination_prefix = "0.0.0.0/0"
		gateway_id         = yandex_vpc_gateway.egress.id
	}
}

# Security Group
resource "yandex_vpc_security_group" "vm_sg" {
	name       = "${var.project}-sg"
	network_id = yandex_vpc_network.this.id

	ingress {
		description    = "SSH"
		protocol       = "TCP"
		port           = 22
		v4_cidr_blocks = [var.ssh_ingress_cidr]
	}

	ingress {
		description    = "HTTP"
		protocol       = "TCP"
		port           = 80
		v4_cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description    = "Any"
		protocol       = "ANY"
		from_port      = 0
		to_port        = 65535
		v4_cidr_blocks = ["0.0.0.0/0"]
	}
}

# Образ
data "yandex_compute_image" "ubuntu" {
	family = var.image_family
}

# Виртуальная машина в публичной подсети с публичным IP
resource "yandex_compute_instance" "vm" {
	name        = "${var.project}-vm"
	platform_id = "standard-v3"

	resources {
		cores  = 2
		memory = 2
	}

	boot_disk {
		initialize_params {
			image_id = data.yandex_compute_image.ubuntu.id
			size     = 15
		}
	}

	secondary_disk {
		disk_id = yandex_compute_disk.data.id
	}

	network_interface {
		subnet_id          = yandex_vpc_subnet.public.id
		nat                = true
		security_group_ids = [yandex_vpc_security_group.vm_sg.id]
	}

	metadata = {
		ssh-keys = "ubuntu:${var.ssh_public_key}"
	}
}

resource "yandex_compute_disk" "data" {
	name     = "${var.project}-data-disk"
	type     = "network-hdd"
	size     = var.data_disk_size_gb
	zone     = var.zone
}

# Объектное хранилище
resource "random_id" "bucket_suffix" {
	byte_length = 4
}

resource "yandex_storage_bucket" "raw" {
	access_key         = var.object_storage_access_key
	secret_key         = var.object_storage_secret_key
	bucket             = "${var.project}-raw-${random_id.bucket_suffix.hex}"
	default_storage_class = "STANDARD"
}

