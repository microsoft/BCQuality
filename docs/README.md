# BCQuality documentation

**New to BCQuality? Start with the [quick start](../README.md#quick-start).**
Install the plugin, discover its skills, and try an app review. No knowledge
of BCQuality's internal protocol is needed.

## Partner guides

| Goal | Guide |
| --- | --- |
| Review an app, file, changes, or branch | [Using BCQuality](using-bcquality.md) |
| Understand a report and its limitations | [Reading your results](using-bcquality.md#reading-your-results) |
| Find a particular rule or example | [Knowledge by domain](using-bcquality.md#knowledge-by-domain) |
| Fix setup problems or report an incorrect finding | [Troubleshooting and support](troubleshooting.md) |
| Select layers, add company rules, or maintain a fork | [Customizing BCQuality](customizing-bcquality.md) |
| Add or improve shared knowledge | [Contributing](contributing.md) |

## Integration and technical reference

These pages are for people building integrations or maintaining skills, not
prerequisites for using the plugin.

| Reference | Purpose |
| --- | --- |
| [How agents consume BCQuality](agent-consumption.md) | Architecture, repository structure, routing, and delivery of findings. |
| [Standalone runner](standalone-runner.md) | Optional model selection, scheduling, retries, and telemetry. |
| [Global skills](../skills/README.md) | Host adapters versus internal protocol files. |
| [Entry](../skills/entry.md) | Task context and skill dispatch. |
| [READ](../skills/read.md) | Knowledge schema, applicability, and precedence. |
| [DO](../skills/do.md) | Action-skill format and structured output contract. |
| [WRITE](../skills/write.md) | Knowledge-authoring rules. |
| [Review evaluation](../evaluation/README.md) | Sample conventions, fixture preparation, and scoring. |
