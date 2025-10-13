# Debstrap

Debstrap is an Ansible-based setup framework for personal workstations. It automates the installation and configuration of system packages, programming environments, dotfiles, authentication setup, and user workspace customization (rice) across different machine types (laptop, desktop, server, etc.).

It includes a helper script `debstrap` for easy execution with tag-based task selection and autocompletion.

---

## Project Structure

```
playbooks/
└── laptop.yml        # Main playbook for a laptop machine type
inventory/
└── hosts.yml         # Inventory pointing to localhost
roles/
├── dotfiles/         # Configure dotfiles for root and user
├── authentication/   # Authentication setup (GPG, SSH)
├── pkg/              # Package installation and system utilities
├── rice/             # Workspace customization (Sway, Waybar, fonts, clipboard)
├── development/      # Development environment (Rust, Go, Zig, Emacs, etc.)
└── xdg/              # XDG directories and workspace setup
```

---

## Roles Overview

### 1. `dotfiles`
- Symlinks user dotfiles and copies root dotfiles from the repository.
- Subtags: `home`, `root`.

### 2. `authentication`
- Configures GPG, SSH, and smartcard integration.
- Subtags: `gpg`, `ssh`.

### 3. `packages`
- Installs essential packages.
- Subtags: `base`, `build`, `network`, `security`, `power`, `utility`, `libs`, `apps`, `audio`, `android`, `firefox`.

### 4. `rice`
- Sets up desktop environment customizations.
- Subtags: `sway`, `waybar`, `clipboard`, `fonts`, `ly`, `keyd`.

### 5. `development`
- Installs programming languages and tools.
- Subtags: `emacs`, `vagrant`, `docker`, `go`, `zig`, `rust`, `cpp`, `node`.

### 6. `xdg`
- Creates and manages XDG directories for workspace organization.
- Subtags: `data`, `config`, `bin`, `cache`, `state`, `workstation`, `media`, `org`, `apps`, `ssh`, `delete`.

---

## Usage

### Example Ansible command

Run the full playbook for all roles:

```bash
ansible-playbook -K playbooks/laptop.yml
```

Run only specific roles using tags:

```bash
ansible-playbook -K playbooks/laptop.yml --tags dot_home,auth_gpg
```

Skip specific tags:

```bash
ansible-playbook -K playbooks/laptop.yml --tags dot_home,auth_gpg --skip-tags auth_ssh
```

---

### Using the `debstrap` helper script

The `debstrap` script simplifies tag-based execution

```bash
# Run dot_home and auth_gpg tags
debstrap dot home, auth gpg

# Run dot_home and auth tags except auth_ssh
debstrap dot home, auth --skip auth ssh
```
---

## License

[MIT License](LICENSE)
