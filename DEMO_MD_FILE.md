# DEMO_MD_FILE.md — Neovim Config

This is a very long file with repeating works that is going to be used to check the markdown LSP stack. We want the
linting and the formatting to work together to limit line length to 120 chars.

## Architecture & Structure

- **Root**: Ansible playbooks in `/playbooks/`, roles in `/roles/`
- **Collections**: Community Ansible collections and Prometheus collection in `/collections/`
- **Configuration**: `inventory.ini` (hosts), `group_vars/all/` (global vars), `host_vars/` (per-host overrides)
- **Documentation**: `/documentation/` directory with service-specific guides
- **Key files**: `ansible.cfg` (roles/collections paths), `makefile` (all commands), `.ansible-lint` (lint rules)
