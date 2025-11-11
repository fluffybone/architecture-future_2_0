output "vm_public_ip" {
	description = "Публичный IP адрес ВМ"
	value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "bucket_name" {
	description = "Имя бакета Object Storage"
	value       = yandex_storage_bucket.raw.bucket
}

output "network_id" {
	description = "ID сети"
	value       = yandex_vpc_network.this.id
}