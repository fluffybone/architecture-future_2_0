variable "project" {
	description = "Название проекта"
	type        = string
	default     = "future20"
}

variable "cloud_id" {
	description = "Cloud ID Yandex Cloud"
	type        = string
}

variable "folder_id" {
	description = "Folder ID Yandex Cloud"
	type        = string
}

variable "zone" {
	description = "Зона размещения"
	type        = string
	default     = "ru-central1-a"
}

variable "public_subnet_cidr" {
	description = "CIDR публичной подсети"
	type        = string
	default     = "10.30.1.0/24"
}

variable "private_subnet_cidr" {
	description = "CIDR приватной подсети"
	type        = string
	default     = "10.30.2.0/24"
}

variable "ssh_ingress_cidr" {
	description = "Разрешенный диапазон SSH"
	type        = string
	default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
	description = "Публичный SSH ключ в формате OpenSSH"
	type        = string
}

variable "image_family" {
	description = "Семейство образов для ВМ"
	type        = string
	default     = "ubuntu-2004-lts"
}

variable "data_disk_size_gb" {
	description = "Размер дополнительного диска"
	type        = number
	default     = 20
}

variable "object_storage_access_key" {
	description = "Доступ Object Storage access key"
	type        = string
}

variable "object_storage_secret_key" {
	description = "Доступ Object Storage secret key"
	type        = string
	sensitive   = true
}

