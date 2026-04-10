#!/usr/bin/env bash

set -euo pipefail

checkpoint_url="https://checkpoint-api.hashicorp.com/v1/check/terraform"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to install Terraform" >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is required to install Terraform" >&2
  exit 1
fi

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$arch" in
  x86_64 | amd64)
    arch="amd64"
    ;;
  arm64 | aarch64)
    arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

version="$(
  curl -fsSL "$checkpoint_url" |
    sed -n 's/.*"current_version":"\([^"]*\)".*/\1/p'
)"

if [[ -z "$version" ]]; then
  echo "Failed to determine the latest Terraform version" >&2
  exit 1
fi

zip_name="terraform_${version}_${os}_${arch}.zip"
download_url="https://releases.hashicorp.com/terraform/${version}/${zip_name}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$download_url" -o "$tmp_dir/$zip_name"
unzip -q "$tmp_dir/$zip_name" -d "$tmp_dir"

install_dir="/usr/local/bin"

if [[ ! -w "$install_dir" ]]; then
  install_dir="$HOME/.local/bin"
  mkdir -p "$install_dir"
fi

install -m 0755 "$tmp_dir/terraform" "$install_dir/terraform"

echo "Installed Terraform ${version} to ${install_dir}/terraform"
