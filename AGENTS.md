# Working on the Kitway site

This is the landing site of Kitway, an iPhone day planner: https://kitwayapp.github.io/. It is built with SiteKit
(below) and published to GitHub Pages by `.github/workflows/deploy.yml` on every push to `main`.

## Kitway rules

- **The privacy policy text lives in the Kitway app repository**, `docs/privacy/privacy-policy.{en,uk}.md`. Never edit
  `Content/Pages/Privacy*.md` by hand: change the Kitway files, then run `scripts/sync-privacy.sh <path-to-Kitway>`.
  Kitway's `Skills/scripts/check-privacy-site.sh` fails when the copies differ.
- **No third-party requests.** No web fonts, CDNs, analytics, embeds or cookies: the privacy policy says so.
  Fonts are Apple system fonts; Font Awesome icons are inlined at build time.
- **App Store id:** `Content/Data/App.yaml`. While it is empty, the site shows "Coming soon" and no Smart App Banner.
- **Languages:** English (default) and Ukrainian (`*.uk.md`, `Landing.uk.yaml`). Ukrainian copy uses «ти», like the app.
- **Colours** come from the app's DesignSystem tokens (`Theme/theme.yaml`, `Theme/css/kitway.css`); keep WCAG AA in
  light and dark.
- **Art:** the fox images come from the app's `KitwayPoses.xcassets`; do not draw new ones here.
- **Build output stays off the internal disk** on the owner's Mac: pass
  `--scratch-path /Volumes/KINGSTON/DeveloperData/Xcode/ProjectBuilds/kitwayapp.github.io/site` to `swift run`.

## SiteKit

This website is built with **SiteKit** – a static site generator written in Swift, driven by AI agents. You (the AI assistant) do the work through SiteKit's skill; this file tells you when to load which part of it, so the guidance is always at hand while the site is live.

## Load the SiteKit skill first

The guidance lives in the `sitekit` agent skill. If it isn't already available in your environment, install it once – it works across Claude Code, Codex, Cursor, Windsurf, Xcode 26, and more:

```
npx skills add FlineDev/SiteKit
```

In Claude Code you can instead install the plugin: `/plugin marketplace add FlineDev/SiteKit` then `/plugin install sitekit@sitekit`.

## When to load which reference

Before you act, load the matching reference from the `sitekit` skill:

| The user wants to… | Load this reference |
|---|---|
| Write or edit a post or page | `content-writing` |
| Add or manage a language | `localization` |
| Add an imprint, privacy, or other legal page | `legal-pages` |
| Change colours, fonts, or layout | `themes` |
| Deploy, or fix a broken deploy | `deployment` |
| Improve SEO / metadata | `seo-aso` |
| Understand a build error or unexpected output | `troubleshooting` |
| Add a custom page type or output file (Swift) | the SiteKit `AGENTS.md` and `custom-pages` |

When in doubt, the skill's `SKILL.md` routes any task to the right reference.

## Everyday commands

```bash
swift run Site serve      # local preview at http://localhost:8080
swift run Site build      # build the static output into _Site/
swift run Site validate   # check translations on multilingual sites
```

Content lives in `Content/`, the look in `Theme/theme.yaml`, and site metadata in `SiteConfig.yaml`.
