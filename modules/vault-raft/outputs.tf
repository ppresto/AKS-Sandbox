output "status" {
  value = helm_release.vault.status
}
output "name" {
  value = helm_release.vault.name
}
output "version" {
  value = helm_release.vault.version
}
output "values" {
  value = helm_release.vault.values
}
