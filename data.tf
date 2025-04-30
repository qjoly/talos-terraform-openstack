data "openstack_compute_flavor_v2" "s1-small" {
    name = "a2-ram4-disk50-perf1"
}

data "openstack_compute_flavor_v2" "s1-medium" {
    name = "a2-ram4-disk50-perf1"
}

data "openstack_networking_network_v2" "public-network" {
    name = "ext-floating1"
}
