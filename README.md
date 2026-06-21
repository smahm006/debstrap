# Debstrap

Ansible provisioning for all personal machines. Secrets are managed with [SOPS](https://github.com/getsops/sops) and decrypted at runtime via a YubiKey GPG key.

## Quick Start

```bash
# Install dependencies
ansible-galaxy collection install -r requirements.yml

# Provision
debstrap                              # full local machine
debstrap --target server              # full server remotely
debstrap dot home, auth gpg           # specific tags
```

## Machines

| Host       | Group    |
|------------|----------|
| sm-laptop  | clients  |
| sm-desktop | clients  |
| sm-server  | servers  |
| sm-rpi     | servers  |

## Structure

```
debstrap/
├── .sops.yaml                          # GPG fingerprint for encryption
├── ansible.cfg
├── requirements.yml
├── inventory/
│   ├── hosts.yaml                      # clients + servers groups
│   ├── group_vars                      # vars for all, clients and servers
│   └── host_vars                       # vars for individual hosts
├── playbooks/                          # playbooks for each machine
│   ├── laptop.yaml
│   ├── desktop.yaml
│   ├── server.yaml
│   └── rpi.yaml
└── roles/
    ├── xdg/                            # Directory creation + cleanup
    ├── dotfiles/                       # Config files + server templates
    ├── packages/                       # apt packages per category
    ├── authentication/                 # GPG, SSH, sshd, nftables, fail2ban
    ├── development/                    # Toolchains + dev tools
    └── rice/                           # Sway, Waybar, fonts, ly, keyd
    └── cluster/                        # home server deployed services
```

## SOPS

```bash
sops inventory/group_vars/all/secrets.sops.yaml        # edit
sops -d inventory/group_vars/all/secrets.sops.yaml     # view without writing to disk
```

Values are encrypted, keys are visible — `git diff` shows what changed. Decryption requires my YubiKey

## The `debstrap` Script

Located at `~/.local/bin/debstrap`, symlinked by the dotfiles role. Walks up the directory tree to find the repo root (`ansible.cfg`), resolves hostname to playbook, and translates space-separated words into underscore-joined tags.

```bash
debstrap                                 # full local provisioning
debstrap dot home                        # just home dotfiles → tag dot_home
debstrap pkg base, dev go                # two tags: pkg_base and dev_go
debstrap --skip rice                     # everything except rice
debstrap --target server                 # provision server remotely
debstrap --target server auth sshd       # just restart sshd on server
```
