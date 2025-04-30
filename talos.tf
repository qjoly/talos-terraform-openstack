resource "talos_machine_secrets" "secret" {}

data "talos_machine_configuration" "controlplane" {
  depends_on = [ talos_machine_secrets.secret ]
  cluster_name     = "talos-openstack"
  machine_type     = "controlplane"
  cluster_endpoint = format("https://%s:6443", openstack_lb_loadbalancer_v2.lb_1.vip_address)
  machine_secrets  = talos_machine_secrets.secret.machine_secrets
  config_patches = [
        yamlencode({
            machine = {
                certSANs = [
                    openstack_lb_loadbalancer_v2.lb_1.vip_address,
                    openstack_networking_floatingip_v2.talos-controlplane.address,
                ] 
            }
        }), 
        yamlencode({
            cluster = {
                apiServer = {
                    certSANs = [
                        openstack_lb_loadbalancer_v2.lb_1.vip_address,
                        openstack_networking_floatingip_v2.talos-controlplane.address,
                    ]
                }
            }
        })
    ]
}

resource "talos_machine_configuration_apply" "worker" {
    client_configuration = talos_machine_secrets.secret.client_configuration
    node = openstack_compute_instance_v2.talos-workers[0].access_ip_v4
    endpoint = openstack_networking_floatingip_v2.talos-controlplane.address
    machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
    
}

resource "talos_machine_configuration_apply" "cp" {
    client_configuration = talos_machine_secrets.secret.client_configuration
    node = openstack_compute_instance_v2.talos-controlplane.access_ip_v4
    endpoint = openstack_networking_floatingip_v2.talos-controlplane.address
    machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
    # config_patches = [
    #     yamlencode({
    #         machine = {
    #             certSANs = [
    #                 openstack_lb_loadbalancer_v2.lb_1.vip_address,
    #                 openstack_networking_floatingip_v2.talos-controlplane.address,
    #             ] 
    #         }
    #     }), 
    #     yamlencode({
    #         cluster = {
    #             apiServer = {
    #                 certSANs = [
    #                     openstack_lb_loadbalancer_v2.lb_1.vip_address,
    #                     openstack_networking_floatingip_v2.talos-controlplane.address,
    #                 ]
    #             }
    #         }
    #     })
    # ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp
  ]
  node                 = openstack_compute_instance_v2.talos-controlplane.access_ip_v4
  client_configuration = talos_machine_secrets.secret.client_configuration
  endpoint            = openstack_networking_floatingip_v2.talos-controlplane.address

}

output "talosconfig" {
  value       = talos_machine_secrets.secret.client_configuration
  description = "Talos client configuration for accessing the cluster"
  sensitive   = true
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.secret.client_configuration
  endpoint = openstack_networking_floatingip_v2.talos-controlplane.address
  node                 = openstack_compute_instance_v2.talos-controlplane.access_ip_v4
}

output "kubeconfig" {
  value       = talos_cluster_kubeconfig.kubeconfig
  description = "Talos client configuration for accessing the cluster"
  sensitive   = true
}