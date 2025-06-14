terraform {
    required_providers {
        openstack = {
            source  = "terraform-provider-openstack/openstack"
            version = "~> 3.2.0"
        }
        talos = {
        source = "siderolabs/talos"
        version = "0.8.0-alpha.0"
        }
    }
}

provider "openstack" {
    auth_url    = "https://api.pub1.infomaniak.cloud/identity"
    tenant_name = ""
    user_name   = ""
    password    = ""
}

