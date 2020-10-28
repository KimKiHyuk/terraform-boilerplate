output "result" {
    value = "${formatlist("%s: %s", (module.multiple_key[*].key_name), (module.multiple_key[*].ssh_private_key_pem))}"
}
