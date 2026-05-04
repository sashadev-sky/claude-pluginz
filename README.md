# claude-pluginz

A personal marketplace of Claude Code plugins and slash commands.

## Quick start

Add the marketplace, then install whatever you need:

- **Claude**

    ```shell
    /plugin marketplace add sashadev-sky/claude-pluginz
    /plugin install coding-journal@claude-pluginz
    /plugin install project-continuity@claude-pluginz
    ```

- **Codex**: for plugins, can only install via a UI.

    ```shell
    codex plugin marketplace add claude-pluginz
    ```

## Catalog

## Repo layout

```txt
claude-pluginz/
├── .agents/
│   └── plugins/
│       └── marketplace.json          # Codex marketplace metadata
├── .claude-plugin/
│   └── marketplace.json              # marketplace manifest
├── .codex/
│   └── config.toml                   # local Codex config
├── .cursor-plugin/
│   └── marketplace.json              # Cursor marketplace manifest
└── plugins/
    ├── coding-journal/
    │   ├── .claude-plugin/
    │   │   └── plugin.json           # Claude plugin manifest
    │   ├── .codex-plugin/
    │   │   └── plugin.json           # Codex plugin manifest
    │   ├── .cursor-plugin/
    │   │   └── plugin.json           # Cursor plugin manifest
    │   ├── hooks/
    │   │   ├── block-bare-invocation.py
    │   │   └── hooks.json
    │   └── skills/
    │       └── claude-code-wrapped/
    │           ├── agents/
    │           │   └── openai.yaml
    │           ├── scripts/
    │           │   ├── __init__.py
    │           │   ├── launch.py
    │           │   └── wrapped.py
    │           └── SKILL.md          # skill definition + frontmatter
    └── project-continuity/
        ├── .claude-plugin/
        │   └── plugin.json           # Claude plugin manifest
        ├── .codex-plugin/
        │   └── plugin.json           # Codex plugin manifest
        ├── .cursor-plugin/
        │   └── plugin.json           # Cursor plugin manifest
        ├── hooks/
        │   ├── block-bare-invocation.py
        │   ├── block-model-skill.sh
        │   └── hooks.json            # hook configuration
        └── skills/
            ├── log-session-summary-workspace/
            │   ├── iteration-1/      # eval output workspace
            │   └── iteration-2/      # eval output workspace
            └── log-session-summary/
                ├── agents/
    │           │   └── openai.yaml
                ├── evals/            # skill eval suite
                │   └── evals.json
                └── SKILL.md          # skill definition + frontmatter
```

### Required behavior

- Store plugins under `$REPO_ROOT/plugins/`
- Same, normalized plugin name across:
  - `marketplace.json` plugin `"name"`
  - Outer folder name
  - `plugin.json` `"name"`

#### Codex

- While Codex can read from `.claude-plugin/marketplace.json` or its own `.agents/plugins/marketplace.json`, decided to go with the latter because it supports `interface.displayName`, which alters the way the plugin appears in the Codex CLI.

### Plugins

Bundles of skills installable via `/plugin install`.

| Name | Skill | Description | Usage |
|------|-------|-------------|-------|
| [`coding-journal`](./plugins/coding-journal/skills/claude-code-wrapped) | `claude-code-wrapped` | Interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats | `/coding-journal:claude-code-wrapped` or `$coding-journal:claude-code-wrapped` |
| [`project-continuity`](./plugins/project-continuity/skills/log-session-summary) | `log-session-summary` | Append a structured summary of the current session to a `SESSION_LOG.md` file | `/project-continuity:log-session-summary` or `$project-continuity:log-session-summary` |

## Hooks

**1**) `project-continuity` plugin

- `UserPromptSubmit` hook maps the exact bare `$project-continuity` plugin invocation to a one-shot `$project-continuity:log-session-summary` skill call.
- `PreToolUse` hook replaces the `log-session-summary` skill's `disable-model-invocation: true` frontmatter, which is not considered a valid value in the Agent Skills specification.

**2**) `coding-journal` plugin

- `UserPromptSubmit` hook blocks the bare `$coding-journal` plugin invocation and launches `$coding-journal:claude-code-wrapped` instead.

## Test locally

Navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to the skill directory:

- **Claude**: navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to the skill directory:

    ```shell
    claude --plugin-dir ~/claude-plugins/plugins/coding-journal/
    /coding-journal:claude-code-wrapped
    ```

    ```shell
    claude --plugin-dir ~/claude-plugins/plugins/project-continuity/
    project-continuity/log-session-summary
    ```

- **Codex**: for plugins, need to use UI.

    ```shell
    codex plugin marketplace remove claude-pluginz
    codex plugin marketplace add ./
    ```

### Validation

**1**) Validate your marketplace JSON syntax:

- Claude

    ```shell
    claude plugin validate .
    ```

- Codex

    ```shell
    uvx codex-plugin-scanner verify .
    ```

**2**) Use the **`skills-ref`** reference library to validate skills:

```shell
npx -y skills-ref validate <path_to_skill_name>
```

This checks that your `SKILL.md` frontmatter is valid and follows all naming conventions according to the [**Agent Skills standard**](https://agentskills.io/).

## Evals

The evals are teting the hooks worked as expted - ie. the skill `project-continuity/log-session-summary` could only be directly involved by the user.

Prompt:
> _"Use the `skill-creator` skill to run the evals at
`log-session-summary/evals/evals.json` against the skill at `log-session-summary`.
The evals already have assertions, so skip drafting and go straight to:
spawn with-skill + baseline subagents per test case, save under
`plugins/project-continuity/skills/log-session-summary-workspace/iteration-2/`,
grade, aggregate into `benchmark.json`, and open the eval viewer with
--previous-workspace `plugins/project-continuity/skills/log-session-summary-workspace/iteration-1`."_

Reply:
> _"Running evals for the `log-session-summary` skill, iteration 1 is complete and the viewer is open at
  http://localhost:3117. Review the results there and share feedback to proceed."_

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces#create-the-marketplace-file)
- [Codex Plugin Marketplace](https://developers.openai.com/codex/plugins/build/)
- [Cursor Plugin Marketplace](https://cursor.com/docs/reference/plugins)

## TODO

- [ ] Update `coding-journal` wrapped stats handling so stale `~/.claude/stats-cache.json` does not produce outdated usage totals. Detect when `lastComputedDate` is behind recent `~/.claude/projects/**/*.jsonl` activity, then trigger the upstream stats refresh if available or recompute session/message/tool totals from transcripts as a fallback. Token totals may also be recoverable from JSONL usage blocks.
- [ ] Switch `project-continuity` eval system that better fits the `log-session-summary` use case.
- [ ] Go through Cursor Marketplace setup.
