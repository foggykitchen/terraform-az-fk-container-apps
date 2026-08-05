resource "tls_private_key" "test_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
