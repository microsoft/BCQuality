Hey @{{AUTHOR}} 👋

First off — thank you for jumping in and experimenting! It's awesome to see people pushing on the framework. 🎉

That said, let me gently redirect you, because I think there's a small but important misunderstanding about how the `custom` layer is meant to work:

The `custom` layer in *this* repo isn't a destination for PRs — it's the designated sandbox inside **your own fork**. Think of it as the "your timeline" branch of the multiverse 🌌: this repo is canon, your fork is where you get to remix the lore without needing anyone's approval. That's the whole point of the layer existing — so you *don't* have to upstream your team-specific or experimental work.

The intended workflow is:

1. 🍴 **Fork** BCQuality to your own GitHub account
2. Clone *your fork* locally
3. Drop your custom agents and knowledge into the `custom` layer **there**
4. Commit and push to your fork — no PR back to upstream needed for custom stuff

That way you get full control, your changes survive upstream updates cleanly, and you can pull in new core releases from this repo whenever you want. ✨

**Now — here's the fun part:** if while building out your fork you discover knowledge, patterns, or agents that you think would genuinely benefit *everyone* using BCQuality (not just your team), that's exactly what the `/community` layer is for! 🌟 PRs to `/community` here in the upstream repo are absolutely welcome and encouraged — it's how the collective hive mind 🧠 levels up. So please: tinker in your fork, and when you strike gold that's worth sharing, send it our way via `/community`.

Going to close this PR for now (since it's targeting `custom` rather than `/community`), but please don't read it as a "no" — it's a "yes, but let's route it correctly." 🙏 Happy to help if you hit any snags spinning up your fork, and genuinely looking forward to seeing what you contribute to `/community` down the line.

<details>
<summary>Files in this PR that triggered the auto-close</summary>

{{FILES}}
</details>

May your merges be conflict-free. 🚀

---
<sub>🤖 This PR was closed automatically by the `Guard custom layer` workflow because it adds or changes content under `/custom/`. If you were only updating the template (`custom/README.md` or a `.gitkeep`), a maintainer can re-open it. If you think this was closed in error, just comment here.</sub>
