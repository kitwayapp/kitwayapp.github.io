# kitwayapp.github.io

The landing site of **Kitway**, an iPhone app that plans your free hours in a city: https://kitwayapp.github.io/

Built with [SiteKit](https://github.com/FlineDev/SiteKit) and published to GitHub Pages on every push to `main`.

```bash
swift run Site serve     # preview at http://localhost:8080
swift run Site build     # write the site to _Site/
swift run Site validate  # check the Ukrainian translations
```

- Landing text: `Content/Data/Landing.yaml` and `Landing.uk.yaml`; App Store id: `Content/Data/App.yaml`.
- Pages: `Content/Pages/` (Support, Terms, Licenses, Privacy).
- The privacy policy is copied from the Kitway app repository: `scripts/sync-privacy.sh <path-to-Kitway>`.

Rules for changes: `AGENTS.md`.
