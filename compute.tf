
resource "openstack_networking_floatingip_v2" "talos-controlplane" {
    pool    = "ext-floating1"
    port_id = openstack_networking_port_v2.talos-controlplane.id
}

resource "openstack_networking_port_v2" "talos-controlplane" {
    depends_on         = [openstack_networking_subnet_v2.talos-subnet-1]
    name               = "talos-controlplane"
    network_id         = openstack_networking_network_v2.talos.id
    admin_state_up     = true
    security_group_ids = [openstack_networking_secgroup_v2.talos-controlplane.id]
}

resource "openstack_networking_port_v2" "talos-workers" {
    depends_on         = [openstack_networking_subnet_v2.talos-subnet-1]
    count              = 2
    name               = "talos-worker-${count.index}"
    network_id         = openstack_networking_network_v2.talos.id
    admin_state_up     = true
    security_group_ids = [openstack_networking_secgroup_v2.talos-workers.id]
}

resource "openstack_compute_instance_v2" "talos-controlplane" {
    name      = "talos-controlplane"
    image_id  = "3a0d365b-bceb-4607-ad29-1921089ae44f"
    flavor_id = data.openstack_compute_flavor_v2.s1-small.id
    # user_data = yamlencode(data.talos_machine_configuration.controlplane)

    network {
        port = openstack_networking_port_v2.talos-controlplane.id
    }
}

resource "openstack_compute_instance_v2" "talos-workers" {
    count     = 2
    name      = "talos-worker-${count.index}"
    image_id  = "3a0d365b-bceb-4607-ad29-1921089ae44f"
    flavor_id = data.openstack_compute_flavor_v2.s1-small.id
    #user_data = yamlencode(data.talos_machine_configuration.controlplane)

    network {
        port = openstack_networking_port_v2.talos-workers[count.index].id
    }
}

