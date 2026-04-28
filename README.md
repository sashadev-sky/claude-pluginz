# claude-pluginz

A personal marketplace of Claude Code plugins and slash commands.

## Quick start

Add the marketplace, then install whatever you need:

```shell
/plugin marketplace add sashadev-sky/claude-pluginz
/plugin install coding-journal@claude-pluginz
/plugin install project-continuity@claude-pluginz
```

## Catalog

### Plugins

Bundles of skills installable via `/plugin install`.

| Name | Skill | Description | Usage |
|------|-------|-------------|-------|
| [`coding-journal`](./skills/claude-code-wrapped) | `claude-code-wrapped` | Interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats | `/coding-journal:claude-code-wrapped` |
| [`project-continuity`](./skills/log-session-summary) | `log-session-summary` | Append a structured summary of the current session to a `SESSION_LOG.md` file | `/project-continuity:log-session-summary` |

## Repo layout

```
claude-pluginz/
├── .claude-plugin/
│   └── marketplace.json         # marketplace manifest
└── skills/
    ├── claude-code-wrapped/     # coding-journal plugin
    │   ├── scripts/             # python implementation
    │   └── SKILL.md             # skill definition + frontmatter
    └── log-session-summary/     # project-continuity plugin
        └── SKILL.md             # skill definition + frontmatter
```

## Test locally

Navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to the skill directory:

```shell
cd ~/your-project
claude --plugin-dir ~/claude-plugins/skills/claude-code-wrapped
claude --plugin-dir ~/claude-plugins/skills/log-session-summary
```

### Validation

Use the **`skills-ref`** reference library to validate skills:

```shell
npx -y skills-ref validate ./skills/<skill_name>
```

This checks that your `SKILL.md` frontmatter is valid and follows all naming conventions according to the [**Agent Skills standard**](https://agentskills.io/).

## Resources

- [Specification](https://agentskills.io/specification)
- [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces#create-the-marketplace-file)
