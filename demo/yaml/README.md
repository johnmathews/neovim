# LSP Demo - YAML Files

This directory contains real-world YAML configuration files designed to demonstrate Neovim's LSP capabilities for YAML schema validation.

## Files

- **docker-compose.yml** - Docker Compose configuration with multi-service setup
- **kubernetes.yml** - Kubernetes manifest with multiple resource types
- **github-actions.yml** - GitHub Actions CI/CD workflow with complex job dependencies

## YAML Features & Schema Validation

All files are designed to work with **yamlls** (YAML Language Server) which provides:

- **Schema validation** - Real-time validation against Docker Compose, Kubernetes, and GitHub Actions schemas
- **Auto-completion** - Context-aware suggestions for valid properties
- **Hover documentation** - Field descriptions and allowed values
- **Diagnostic messages** - Helpful error messages for schema violations

### Docker Compose Features (docker-compose.yml)

**Demonstrates:**
- Service definitions with proper nesting
- Volume mounts and environment variables
- Container health checks
- Network configuration
- Dependency ordering
- Named volumes and data persistence

### Kubernetes Features (kubernetes.yml)

**Demonstrates:**
- Multiple resource kinds (Namespace, ConfigMap, Secret, Deployment, Service, HPA)
- Resource references and selectors
- Environment variables from ConfigMaps and Secrets
- Resource requests and limits
- Health probes (liveness and readiness)
- Auto-scaling configuration

### GitHub Actions Features (github-actions.yml)

**Demonstrates:**
- Workflow triggers (push, pull_request, schedule)
- Job definitions and dependencies
- Matrix strategy for multiple versions
- Secrets and environment variables
- Conditional execution (if conditions)
- Reusable actions from GitHub marketplace
- Artifacts and caching

## LSP Keybindings to Try

### Navigation
| Keybinding | Action | Try on |
|---|---|---|
| `gd` | Go to anchor references | YAML anchors and references (`&`, `*`) |
| `gr` | Show all references | Service names or resource names |
| `K` | Hover documentation | Any property to see schema definition |

### Diagnostics
| Keybinding | Action | Try on |
|---|---|---|
| `gra` | Code actions | Schema violations or missing required fields |
| `<Tab>dd` | Cycle diagnostics | View errors, warnings, info messages |

### Information
| Keybinding | Action | Try on |
|---|---|---|
| `<LocalLeader>t` | Active tools | See YAML schema being used |

## Demo Workflow

### Docker Compose Demo
1. Open `docker-compose.yml`: `nvim demo/yaml/docker-compose.yml`
2. Try `K` on properties like `image`, `ports`, `environment`
3. Try hovering over `depends_on` and `networks` to see documentation
4. Try adding an invalid property to trigger schema validation

### Kubernetes Demo
1. Open `kubernetes.yml`: `nvim demo/yaml/kubernetes.yml`
2. Try `K` on `kind`, `metadata`, `spec` to see schema
3. Place cursor on `demo-api-service` and press `gr` to see references
4. Try modifying a field to see real-time validation

### GitHub Actions Demo
1. Open `github-actions.yml`: `nvim demo/yaml/github-actions.yml`
2. Try `K` on `on`, `jobs`, `runs-on` to see workflow schema
3. Place cursor on `test` job and press `gr` to see where it's referenced
4. Try adding invalid properties to the workflow structure

## Features Demonstrated

✅ **Schema validation** - Real-time checking against official schemas  
✅ **Auto-completion** - Context-aware suggestions for valid properties  
✅ **Documentation** - Hover to see field descriptions and constraints  
✅ **Error detection** - Immediate feedback on schema violations  
✅ **Code navigation** - Jump between related definitions  

## Common Issues & Fixes

### YAML Schema Not Loading

If hovering doesn't show documentation:

1. Check LSP attachment:
   ```vim
   :LspInfo
   ```

2. Verify yamlls is installed:
   ```vim
   :Mason
   ```

3. Try restarting LSP:
   ```vim
   :LspRestart
   ```

### Adding Custom Schemas

YAML LSP can validate against custom schemas. Add to your Neovim config:

```lua
-- lua/plugins/lsp.lua
["yamlls"] = function()
	lspconfig.yamlls.setup({
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/docker-compose.json"] = "*docker-compose.yml",
					["https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-patch/swagger.json"] = "*kubernetes.yml",
					["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
				},
			},
		},
	})
end,
```

## Notes

- YAML LSP is configured in `lua/plugins/lsp.lua`
- Schema validation happens automatically based on file patterns
- Try `:LspInfo` to see active schemas for current buffer
- Indent errors in YAML will be caught by LSP

## Related Files

- LSP configuration: See `docs/LSP.md` for YAML LSP setup details
- Keybindings: See `docs/KEYMAPS.md` for all available LSP keybindings
