# claude-pluginz

A personal marketplace of Claude Code plugins and slash commands.

## Quick start

Add the marketplace, then install whatever you need:

```shell
/plugin marketplace add sashadev-sky/claude-pluginz
/plugin install project-continuity@claude-pluginz
/plugin install coding-journal@claude-pluginz
```

## Catalog

### Plugins

Bundles of skills installable via `/plugin install`.

| Name | Description | Usage |
|------|-------------|-------|
| [`claude-code-wrapped`](./skills/coding-journal) | Generate an end-of-year wrapped summary of your Claude Code usage | `/coding-journal:claude-code-wrapped` |
| [`log-session-summary`](./skills/project-continuity) | Append a structured summary of the current session to a `SESSION_LOG.md` file | `/project-continuity:log-session-summary` |

## Repo layout

```txts
claude-pluginz/
├── .claude-plugin/
│   └── marketplace.json         # marketplace manifest
└── skills/
    ├── claude-code-wrapped/
    │   ├── scripts/             # python implementation
    │   └── SKILL.md             # skill definition + frontmatter
    └── project-continuity/
        └── SKILL.md             # skill definition + frontmatter
```

## Test locally

Navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to your plugin:

```shell
cd ~/your-project
claude --plugin-dir ~/claude-plugins/skills/project-continuity/log-session-summary
```

Type `/project-continuity:log-session-summary` to invoke the command.

### Validation

Use the **`skills-ref`** reference library to validate skills:

```shell
npx -y skills-ref validate ./plugins/<plugin_name>/skills/<skill_name>
```

This checks that your `SKILL.md` frontmatter is valid and follows all naming conventions according the [**Agent Skills standard**](https://agentskills.io/).

## Resources

- [Specification](https://agentskills.io/specification)
- [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces#create-the-marketplace-file)
