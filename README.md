# Dotfiles

Multi-host Nix flake configuration for macOS (nix-darwin) and NixOS, with Determinate Nix and agenix secrets management.

## Hosts

| Host | System | Description |
|------|--------|-------------|
| `macbook` | aarch64-darwin | MacBook Pro with nix-darwin + home-manager |
| `posejdon` | x86_64-linux | NixOS homelab server |

## Quick Start

### Macbook

```bash
# Rebuild system
darwin-rebuild switch --flake ~/dotfiles#macbook

# Or use hostname alias
darwin-rebuild switch --flake ~/dotfiles#Wojciechs-MacBook-Pro
```

### Posejdon (local)

```bash
# SSH into posejdon and rebuild
ssh wojtek@posejdon
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#posejdon
```

### Posejdon (remote from macbook)

```bash
# Build and deploy from macbook
# Note: Requires nix-secrets to be available on posejdon
rsync -avz --delete --exclude='.git' ~/dotfiles/ wojtek@posejdon:~/dotfiles-deploy/
ssh -A wojtek@posejdon "cd ~/dotfiles-deploy && sudo nixos-rebuild switch --flake .#posejdon --override-input nix-secrets path:/home/wojtek/nix-secrets"
```

## Structure

```
~/dotfiles/
├── flake.nix              # Multi-host flake definition
├── flake.lock             # Locked dependencies
├── hosts/
│   ├── macbook/           # macOS host config
│   │   ├── default.nix    # Main darwin config + home-manager
│   │   └── system.nix     # macOS system settings
│   └── posejdon/          # NixOS host config
│       ├── default.nix    # Main NixOS config
│       ├── hardware.nix   # Hardware & boot settings
│       ├── networking.nix # Network, WiFi, Tailscale
│       ├── services.nix   # SSH, ZFS, system services
│       └── hardware-configuration.nix
├── modules/
│   ├── darwin/            # macOS-specific modules
│   │   ├── emacs.nix
│   │   └── pkgs/          # Custom darwin packages
│   ├── nixos/             # NixOS-specific modules (future)
│   └── shared/            # Shared across hosts
│       └── shell.nix      # Shell config, packages
└── overlays/
    ├── default.nix        # Auto-loader for overlays
    └── pinentry-touchid.nix
```

## Key Features

- **Multi-host**: Single flake manages macOS and NixOS systems
- **Determinate Nix**: Uses Determinate's Nix distribution with FlakeHub
- **Secrets Management**: agenix with private `nix-secrets` repo
- **Auto-loading Overlays**: Drop `.nix` files in `overlays/` to auto-load
- **Modular Config**: Split by domain (networking, services, hardware)

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix) and stored in a private `nix-secrets` repository.

- WiFi password (posejdon)
- SSH authorized keys (posejdon)

Secrets are encrypted with host SSH keys and decrypted at runtime to `/run/agenix/`.

## Common Tasks

```bash
# Update flake inputs
cd ~/dotfiles && nix flake update

# Check configuration
nix flake check

# Build without switching (macbook)
nix build .#darwinConfigurations.macbook.system

# Build without switching (posejdon)
nix build .#nixosConfigurations.posejdon.config.system.build.toplevel

# Garbage collection
nix-collect-garbage -d

# List generations (macbook)
darwin-rebuild --list-generations

# List generations (posejdon)
ssh wojtek@posejdon "nixos-rebuild list-generations"
```

## Notes

- New files must be staged with `git add` before building
- Posejdon uses Tailscale for SSH access (hostname: `posejdon`)
- WiFi password on posejdon uses `pskFile` pointing to agenix secret
- SSH authorized keys on posejdon are in `/etc/ssh/authorized_keys.d/` for pam_rssh compatibility
