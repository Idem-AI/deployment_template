##############################################################################
#                                  OUTPUTS                                  #
##############################################################################
/* output "cloud_run_urls" {
  description = "URLs publiques des services Cloud Run"
  value       = { for k, s in google_cloud_run_v2_service.services : k => data.google_cloud_run_v2_service.services_data[k].uri }
}
*/
output "lb_ips" {
  description = "IP(s) publiques des Forwarding Rules"
  value       = { for k, f in google_compute_global_forwarding_rule.fwd : k => f.ip_address }
}

