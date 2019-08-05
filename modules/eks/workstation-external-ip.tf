#
# Workstation External IP

data "http" "workstation-external-ip" {
  url = "http://icanhazip.com"
}

