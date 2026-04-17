# Custom layer

This folder is the template for partner- and customer-specific overrides. Use it to add knowledge and skills that apply to your organization but are not appropriate for the shared Microsoft or Community layers.

## Structure

```
custom/
├── knowledge/    # Your organization's knowledge files (same format as /microsoft/knowledge/)
└── skills/       # Your organization's action skills
```

## How to use

Fork or clone BCQuality into your own repository and add your content here. Knowledge files in `/custom/knowledge/` follow the same frontmatter schema and section requirements as every other layer. Action skills in `/custom/skills/` follow the Action Skill template defined in `/skills/`.

When agents consume BCQuality, the custom layer is loaded alongside Microsoft and Community — your overrides apply automatically.
