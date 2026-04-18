# session-logger

A plugin called `session-logger` that adds a `/session-logger:summarize` command. When invoked, Claude reviews the conversation and appends a structured summary to `SESSION_LOG.md`.

## Test locally

Navigate to any project where you want to use the plugin, then start Claude Code with the `--plugin-dir` flag pointing to your plugin:

```shell
cd ~/your-project
claude --plugin-dir ~/claude-plugins/session-logger
```

Type `/session-logger:summarize` to invoke the command.
