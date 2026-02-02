# NixOS Multi-Host Configuration

Multi-host NixOS configuration with support for desktop, VM, and headless server setups.

## Available Hosts

- **nix-os** - Physical hardware with Plasma desktop, NVIDIA drivers, OBS
- **vm-nix-os** - Virtual machine with lightweight XFCE desktop
- **nix-server** - Headless server configuration (no GUI)

## Quick Start

### 1. Clone config repository

```bash
git clone https://github.com/MaciejGarncarski/nix-config.git ~/.nix-config
```

### 2. Choose your host configuration

Copy the appropriate host template or create a new one in `hosts/`:

```bash
# For a new host
mkdir -p ~/.nix-config/hosts/my-host
```

### 3. Generate hardware configuration

```bash
nixos-generate-config --show-hardware-config > ~/.nix-config/hosts/my-host/hardware-configuration.nix
```

### 4. Create host configuration

Create `~/.nix-config/hosts/my-host/configuration.nix`:

```nix
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    # Choose your desktop environment (optional):
    # ../../modules/desktop/plasma.nix
    # ../../modules/desktop/xfce.nix

    # Optional hardware modules:
    # ../../modules/nvidia.nix
    # ../../modules/obs.nix
  ];

  # Enable GUI packages (desktop environments, browsers, editors)
  custom.gui.enable = true;  # Set to false for headless servers

  # Set hostname
  networking.hostName = "my-hostname";

  # Configure bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Or use GRUB (common for VMs):
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.device = "nodev";
}
```

### 5. Add host to flake.nix

Add your new host to the `nixosConfigurations` in `flake.nix`:

```nix
my-host = nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = {
    username = "your-username";  # Change this
    inputs = inputs;
  };
  modules = [
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
    }
    ./home-manager/home.nix
    ./hosts/my-host/configuration.nix
    nix-flatpak.nixosModules.nix-flatpak
    { nixpkgs.config.allowUnfree = true; }
  ];
};
```

### 6. Build and switch

```bash
# Build specific host
nixos-rebuild switch --flake ~/.nix-config#my-host

# Or use the rebuild script (edit hostname inside first)
chmod +x ~/.nix-config/rebuild.sh
cd ~/.nix-config && ./rebuild.sh
```

## Configuration Options

### Username

Change username in `flake.nix` under `specialArgs`:

```nix
specialArgs = {
  username = "your-username";  # Change this
  inputs = inputs;
};
```

### Desktop Environment

Import one of the available desktop modules in your host configuration:

```nix
imports = [
  # ...
  ../../modules/desktop/plasma.nix  # KDE Plasma 6 (Wayland)
  # ../../modules/desktop/xfce.nix  # XFCE (lightweight)
];
```

### GUI vs Headless

Control GUI package installation with:

```nix
custom.gui.enable = true;  # Install desktop apps, browsers, editors
custom.gui.enable = false; # CLI tools only (servers)
```

When `custom.gui.enable = false`:

- No GUI applications (browsers, editors, office)
- No desktop environment packages
- Terminal-only tools (btop, lazygit, mise, etc.)
- Editor defaults to `vim` instead of VS Code

### Bootloader

Choose bootloader in your host configuration:

```nix
# systemd-boot (modern UEFI systems)
boot.loader.systemd-boot.enable = true;
boot.loader.systemd-boot.configurationLimit = 3;
boot.loader.efi.canTouchEfiVariables = true;

# OR GRUB (legacy/VM compatibility)
boot.loader.grub.enable = true;
boot.loader.grub.efiSupport = true;
boot.loader.grub.device = "nodev";
```

### Hardware-Specific Modules

Optional modules for specific hardware:

```nix
imports = [
  # ...
  ../../modules/nvidia.nix  # NVIDIA proprietary drivers
  ../../modules/obs.nix     # OBS Studio configuration
];
```

## Project Structure

```
nix-config/
├── flake.nix                    # Main flake configuration
├── hosts/                       # Per-host configurations
│   ├── nix-os/                 # Desktop configuration
│   ├── vm-nix-os/              # VM configuration
│   └── nix-server/             # Headless server
├── modules/                     # Shared system modules
│   ├── default.nix             # Core module imports
│   ├── boot.nix                # Common boot settings
│   ├── system.nix              # System-wide settings
│   ├── packages.nix            # System packages
│   ├── services.nix            # System services
│   ├── gui.nix                 # GUI enable option
│   ├── docker.nix              # Docker configuration
│   ├── nvidia.nix              # NVIDIA drivers
│   └── desktop/                # Desktop environments
│       ├── plasma.nix          # KDE Plasma 6
│       └── xfce.nix            # XFCE
└── home-manager/               # User environment
    ├── home.nix                # Home Manager config
    └── p10k.zsh                # Powerlevel10k theme
```

## Useful Commands

### Interactive TUI Manager

```bash
# Run the interactive configuration manager
~/.nix-config/nixos-manager.sh
```

The TUI manager provides an easy menu-driven interface for:

- Building and switching configurations for all hosts
- Updating flake inputs (all or specific)
- Checking flake validity
- Garbage collection with multiple options
- Viewing system information
- Formatting Nix files

### Manual Commands

```bash
# Build specific host
nixos-rebuild switch --flake .#nix-os
nixos-rebuild switch --flake .#vm-nix-os
nixos-rebuild switch --flake .#nix-server

# Test configuration without switching
nixos-rebuild test --flake .#nix-os

# Update flake inputs
nix flake update

# Check flake
nix flake check

# Clean old generations
nix-collect-garbage --delete-older-than 30d
sudo nix-collect-garbage --delete-older-than 30d
```
