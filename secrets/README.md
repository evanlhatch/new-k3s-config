# Secrets Directory

This directory contains placeholder files for secrets that should be securely managed.

## Required Secrets

1. **k3s.token** - A shared token used by both the K3s server and agents for authentication
   - Generate with: `head -c 32 /dev/urandom | base64`
   - This token must be identical on all nodes

2. **tailscale.key** - Tailscale auth key for automatic node registration
   - Generate from Tailscale admin console: https://login.tailscale.com/admin/settings/keys
   - Can be unique per node or use a reusable key with appropriate expiration

## Secure Deployment

For production use, consider:

1. Using [sops-nix](https://github.com/Mic92/sops-nix) for encrypted secrets
2. Using [agenix](https://github.com/ryantm/agenix) for age-encrypted secrets
3. Using a proper secrets management solution like Vault

## Example Deployment Process

1. Generate the secrets locally
2. Deploy them to each node in `/run/secrets/` before NixOS activation
3. Update the deployment script to handle secret distribution

**IMPORTANT: Never commit actual secret values to version control!**
