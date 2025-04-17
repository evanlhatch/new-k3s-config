# NixOS K3s Cluster Configuration

This repository contains the NixOS configuration for a K3s cluster, managed declaratively using Nix Flakes and deployed with `deploy-rs`.

**Cluster Nodes:**
*   `thinkpad-nixos`: Control Plane Node
*   `hetzner-1`: Worker Node
*   `auslander-nixos`: Worker Node
*   `thinkcenter-1`: Worker Node

**Current Features:**
*   K3s (Single Server Control Plane, Flannel CNI).
*   Tailscale for secure networking and SSH access.
*   Netdata for node monitoring.
*   Modular configuration separating roles, features, and host-specific details.
*   Deployment managed via `deploy-rs`.

**Planned Features (To be deployed *inside* K8s later):**
*   Flux (GitOps Controller)
*   Longhorn (Persistent Block Storage - RWO)
*   MinIO (S3 Object Storage)
*   Infisical (Secrets Management - Operator runs in K8s)
*   SigNoz (Observability Platform)
*   Cert-Manager (Automated TLS Certificates)
*   Cilium (Advanced CNI/Networking - Potential replacement for Flannel)
*   K3s HA (Embedded etcd or External Postgres)

## Structure

*   `flake.nix`: Main flake file defining inputs, outputs, common base settings (embedded), NixOS configurations, and `deploy-rs` setup.
*   `modules/`: Contains reusable NixOS modules for specific roles/features.
*   `hosts/`: Contains configurations specific to each machine, including hardware details.
*   `secrets/`: Contains placeholder files and instructions for managing secrets.

## Prerequisites

*   Nix package manager with Flakes enabled.
*   Git.
*   `deploy-rs` binary installed (e.g., via `nix profile install github:serokell/deploy-rs`).
*   SSH access configured to all target nodes (using the users defined in `flake.nix -> deploy.nodes`). Ensure your public SSH key is added correctly in `flake.nix`.

## Setup & Configuration (Manual Steps Required!)

1.  **Clone Repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```

2.  **CRITICAL: Fill/Verify Hardware Configuration:**
    *   Hardware details (`fileSystems`, `boot.loader`, kernel modules) are unique to each machine.
    *   **Verify** the pre-filled hardware sections in:
        *   `hosts/thinkpad-nixos/configuration.nix` (**Especially `boot.loader.grub.devices`**)
        *   `hosts/hetzner-1/configuration.nix`
    *   You **MUST** edit and fill the placeholder sections (`<<< ... >>>`) in:
        *   `hosts/auslander-nixos/configuration.nix`
        *   `hosts/thinkcenter-1/configuration.nix`
    *   **How to find info:** SSH into the target machine and use `lsblk -f` (to find UUIDs, labels, device paths) or look at `/etc/nixos/hardware-configuration.nix` (if it exists) *for reference*. Ensure `boot.loader.grub.devices` (or equivalent) points to the *physical disk*.

3.  **CRITICAL: Update Placeholders in `flake.nix`:**
    *   Verify your actual **Tailnet name** in `tailnetName`.
    *   Verify the **SSH public key** in `commonBaseModule`.
    *   Verify/set the correct deployment **IP addresses/hostnames** and **SSH users** for `auslander-nixos` and `thinkcenter-1` in the `deploy.nodes.deploymentMap`.

4.  **CRITICAL: Set Up Secrets:**
    *   Create and securely distribute the required secrets:
        *   `/run/secrets/k3s.token` - Shared token for K3s server and agents
        *   `/run/secrets/tailscale.key` - Tailscale auth key for automatic registration
    *   See `secrets/README.md` for detailed instructions on generating and managing these secrets.

5.  **(Optional but Recommended) Tailscale Authentication:**
    *   If not using the `authKeyFile` approach, manually authenticate Tailscale after first deploy:
      ```bash
      sudo tailscale up --accept-routes --accept-dns=true --ssh
      ```

## Deployment with deploy-rs

Once the hardware configurations, placeholders, and secrets are correctly set up:

1.  **Build and Deploy All Nodes:**
    ```bash
    deploy-rs .
    ```
    (Run from the flake's root directory)

2.  **Deploy to Specific Nodes:**
    ```bash
    deploy-rs . -o <hostname1> -o <hostname2> ...
    # e.g., deploy-rs . -o thinkpad-nixos -o hetzner-1
    ```

## Post-Deployment Verification

1.  **SSH into the control plane node (`thinkpad-nixos`):**
2.  **Check K3s node status:**
    ```bash
    sudo k3s kubectl get nodes -o wide
    ```
    You should see all configured nodes eventually listed with `STATUS` as `Ready`.
3.  **Check Tailscale status:**
    ```bash
    sudo tailscale status
    ```
4.  **Check Netdata:** Access `http://<node-tailscale-name>:19999`.

## Next Steps & Future Plans

See the `Planned Features` section above. Prioritize securing the K3s token and Tailscale auth keys. Then proceed to install Kubernetes applications like Flux, Longhorn, Cert-Manager, SigNoz using Helm *after* the base cluster is operational.
