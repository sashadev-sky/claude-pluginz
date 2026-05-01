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
| [`coding-journal`](./plugins/coding-journal/skills/claude-code-wrapped) | `claude-code-wrapped` | Interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats | `/coding-journal:claude-code-wrapped` |
| [`project-continuity`](./plugins/project-continuity/skills/log-session-summary) | `log-session-summary` | Append a structured summary of the current session to a `SESSION_LOG.md` file | `/project-continuity:log-session-summary` |

## Repo layout

```txt
claude-pluginz/
├── .claude-plugin/
│   └── marketplace.json              # marketplace manifest
└── plugins/
    ├── coding-journal/
    │   ├── .claude-plugin/
    │   │   └── plugin.json           # plugin manifest
    │   └── skills/
    │       └── claude-code-wrapped/
    │           ├── scripts/          # python implementation
    │           │   ├── __init__.py
    │           │   └── wrapped.py
    │           └── SKILL.md          # skill definition + frontmatter
    └── project-continuity/
        ├── .claude-plugin/
        │   └── plugin.json           # plugin manifest
        ├── hooks/
        │   ├── block-model-skill.sh  # hook implementation
        │   └── hooks.json            # hook configuration
        └── skills/
            └── log-session-summary/
                ├── evals/            # skill eval suite
                │   └── evals.json
                └── SKILL.md          # skill definition + frontmatter
```

## Test locally

Navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to the skill directory:

```shell
claude --plugin-dir ~/claude-plugins/plugins/coding-journal/
/coding-journal:claude-code-wrapped
```

```shell
claude --plugin-dir ~/claude-plugins/plugins/project-continuity/
project-continuity/log-session-summary
```

### Validation

Validate your marketplace JSON syntax:

```shell
claude plugin validate .
```

Use the **`skills-ref`** reference library to validate skills:

```shell
npx -y skills-ref validate <path_to_skill_name>
```

This checks that your `SKILL.md` frontmatter is valid and follows all naming conventions according to the [**Agent Skills standard**](https://agentskills.io/).

## Hooks

The hooks are in place of `disable-model-invocation:  true` in `log-session-summary`, which is not considered a valid value in the Agent Skills specification.

## Evals

The evals are teting the hooks worked as expted - ie. the skill `project-continuity/log-session-summary` could only be directly involved by the user.

Prompt:
> _"Use the skill-creator skill to run the evals at
plugins/project-continuity/skills/log-session-summary/evals/evals.json
against the skill at plugins/project-continuity/skills/log-session-summary.
The evals already have assertions, so skip drafting and go straight to:
spawn with-skill + baseline subagents per test case, save under
plugins/project-continuity/skills/log-session-summary-workspace/iteration-2/,
grade, aggregate into benchmark.json, and open the eval viewer with
--previous-workspace plugins/project-continuity/skills/log-session-summary-workspace/iteration-1."_

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Create and distribute a plugin marketplace (Claude Code)](https://code.claude.com/docs/en/plugin-marketplaces#create-the-marketplace-file)
