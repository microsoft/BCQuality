# Custom layer

This folder is the template for partner- and customer-specific overrides. Use it to add knowledge and skills that apply to your organization but are not appropriate for the shared Microsoft or Community layers.

## Structure

```
custom/
├── knowledge/    # Your organization's knowledge files (same format as /microsoft/knowledge/)
└── skills/       # Your organization's action skills
```

## How to use

Use a fork or organization-controlled copy of BCQuality, not the upstream
repository or your AL app's source folder. Confirm `git remote get-url origin`
points at your repository before adding custom content. Upstream does not
accept custom rules.

Follow [Customizing BCQuality](../docs/customizing-bcquality.md) for a worked
rule, plugin configuration, installing your fork, and keeping it up to date.
Adding a rule here does not update an existing upstream plugin installation;
your host must consume your copy.

Knowledge files follow [READ](../skills/read.md) and action skills follow
[DO](../skills/do.md). With the Custom layer enabled, applicable custom
knowledge overrides contradictory Community or Microsoft guidance. The report
records the displaced article; non-conflicting guidance remains additive.
