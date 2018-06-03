app_env = "dev"

cidr = "10.10.0.0/16"

public_ca-central-1a_cidr = "10.10.0.0/24"

public_ca-central-1b_cidr = "10.10.1.0/24"

private_ca-central-1a_cidr = "10.10.2.0/24"

private_ca-central-1b_cidr = "10.10.3.0/24"

availability_zones_list = ["ca-central-1a", "ca-central-1b"]

availability_zones_map = {
  "private_ca-central-1a" = "ca-central-1a"
  "private_ca-central-1b" = "ca-central-1b"
}

