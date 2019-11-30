
region = "eu-central-1"

availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

namespace = "lazyorange"

stage = "staging"

name = "eks"

instance_type = "t2.small"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

autoscaling_policies_enabled = true

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20

associate_public_ip_address = true

kubernetes_version = "1.14"

gitlab_worker_opts = {
  lifecycle = "OnDemand"

  ng = {
    min_size = 0
    max_size = 2
  }
}


dns_zone = "staging.lazyorange.xyz"

oidc_provider_enabled = true

cluster_autoscaler_enabled = true

local_exec_interpreter = "/bin/bash"