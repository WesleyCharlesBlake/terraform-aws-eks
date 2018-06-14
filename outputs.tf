output "kubeconfig" {
  value = "${module.config.kubeconfig}"
}

output "config-map" {
  value = "${module.config.config-map-aws-auth}"
}
