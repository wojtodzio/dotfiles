# Dotfiles

Nix flake-based configuration for macOS using nix-darwin, home-manager, and Determinate Nix.

## Quick Start

```bash
# Rebuild system
sudo darwin-rebuild switch --flake ~/.nixpkgs

# Update dependencies
cd ~/.nixpkgs
nix flake update
sudo darwin-rebuild switch --flake ~/.nixpkgs
```

## Structure

```
~/.nixpkgs/
├── flake.nix                # Flake definition
├── flake.lock               # Locked dependencies  
├── darwin-configuration.nix # Main system config
├── mac-config.nix           # macOS system settings
├── shell.nix                # Shell, packages, environment
├── emacs.nix                # Emacs configuration
└── pkgs/                    # Custom packages
```

## Key Features

- **Determinate Nix**: Uses Determinate's Nix distribution with FlakeHub integration
- **Flake-based**: No channels, fully reproducible via `flake.lock`
- **Binary caches**: Configured for nix-community, helix, devenv, nixpkgs-ruby/python
- **Homebrew integration**: Manages GUI apps via nix-darwin

## Configuration

### Nix Settings

Managed via `determinateNix.customSettings` in `darwin-configuration.nix`:
- Written to `/etc/nix/nix.custom.conf`
- Includes binary caches and performance settings

### System Customization

- **macOS settings**: `mac-config.nix` (keyboard, dock, finder, etc.)
- **Packages**: `shell.nix` and `emacs.nix`
- **Shell**: zsh with starship, fzf, yazi, atuin

## Common Tasks

```bash
# Check configuration
nix flake check

# Build without switching
nix build ~/.nixpkgs#darwinConfigurations.Wojciechs-MacBook-Pro.system

# Garbage collection
nix-collect-garbage -d

# List generations
darwin-rebuild --list-generations
```

## Notes

- Configuration name matches hostname: `Wojciechs-MacBook-Pro`
- Alias `macbook` also available for convenience
- New files must be staged: `git add <file>` before building
- The `~/.nixpkgs` directory is symlinked to `~/dotfiles/.nixpkgs`
