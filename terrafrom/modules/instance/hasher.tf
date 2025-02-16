locals {
  key_paths = {
    ci_pubkey   = var.ci_pubkey_path
    user_pubkey = var.pubkey_path
  }
}

data "local_file" "pubkey" {
  for_each = local.key_paths
  filename = each.value
}

locals {
  passwds_with_salt = {
    "user" = {
      passwd = var.passwd,
      salt   = var.passwd_salt
    },
    "ciuser" = {
      passwd = var.ci_passwd,
      salt   = var.passwd_salt
    }
  }
}

data "external" "hasher" {
  for_each = local.passwds_with_salt
  program  = ["scripts/passwd_hasher.sh", each.value.passwd, each.value.salt]
}

output "hashed_passwords" {
  value = {
    root   = data.external.hasher["user"].result.hashed_password,
    ciuser = data.external.hasher["ciuser"].result.hashed_password
  }
}