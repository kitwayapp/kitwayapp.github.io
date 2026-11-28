# kitwayapp.github.io

The landing, legal and support site for **Kitway**, an iPhone day planner, served at
<https://kitwayapp.github.io/>.

The app itself is developed in a separate, private repository. This repository holds only
the published site, because an organization Pages site has to be served from a repository
named `<org>.github.io`.

The site is built with [SiteKit](https://github.com/FlineDev/SiteKit), a static site
generator written in Swift.

```bash
swift run Site serve     # preview at http://localhost:8080
swift run Site build     # write the site to _Site/
swift run Site validate  # check the Ukrainian translations
```

## What is here

| Path | Serves |
|---|---|
| `Content/Data/Landing.yaml` | `/` — the landing page, the App Store listing's Marketing URL |
| `Content/Pages/Privacy.md` | `/privacy/` — Privacy Policy, shipped in the app and the listing |
| `Content/Pages/Support.md` | `/support/` — Support URL for the listing |
| `Content/Pages/Terms.md` | `/terms/` — Terms of Use for the listing |
| `Content/Pages/Licenses.md` | `/licenses/` — licences of the open-source software inside the app |
| `*.uk.md`, `Landing.uk.yaml` | `/uk/…` — the Ukrainian twin of each page |
| `Content/Data/App.yaml` | the App Store id |
| `Theme/` | colours, layout and scripts of the site |
| `Sources/Site/` | the Swift code that renders the landing page |

English is the default language. The Ukrainian copy uses «ти», like the app.

## App Store id

`Content/Data/App.yaml` holds the numeric App Store id. While it is empty, the landing page
shows "Coming soon" instead of the App Store button, and the pages have no Smart App
Banner. Put the id there when the app is live.

## Deploying

`.github/workflows/deploy.yml` builds the site in the official `swift:6.4-noble` image on
every pull request and push, and deploys only from `main`. Pages source must be set to
**GitHub Actions** in Settings → Pages.

Before the deploy, the workflow:

1. builds the site with `swift run -c release Site build`;
2. checks the translations with `swift run -c release Site validate`;
3. runs `scripts/check-assets.sh _Site`, which fails when a page or a stylesheet links a file
   of this site that the build did not write.

The asset check is case-sensitive, as GitHub Pages is. A folder named `Images` under a link
to `/images/` works on a Mac and breaks on the live site; the check stops that before the
deploy.

## No third-party requests

The site loads nothing from another host: no web fonts, CDNs, analytics, embeds or
cookies. The privacy policy says so. Fonts are Apple system fonts, and the Font Awesome
icons are inlined at build time. Keep it that way when you add a page or a theme change.

## Privacy policy

The policy text lives in the app repository, in `docs/privacy/privacy-policy.{en,uk}.md`.
Do not edit `Content/Pages/Privacy*.md` by hand. Change the app's files, then copy them:

```bash
scripts/sync-privacy.sh <path-to-Kitway>
```

The app repository has a check that fails when the two copies differ. App Review rejects
an unreachable or contradictory privacy link.

## Art and screenshots

- The fox images in `Content/Assets/images/` come from the app's `KitwayPoses.xcassets`.
  Do not draw new ones here.
- `Content/Assets/images/screens/` holds the screenshots the landing page frames: one set
  for each language and each appearance, `<lang>-<light|dark>-<screen>.jpg`.
- The colours come from the app's DesignSystem tokens (`Theme/theme.yaml`,
  `Theme/css/kitway.css`). Keep WCAG AA contrast in light and dark.

Rules for agents that change this site: `AGENTS.md`.
