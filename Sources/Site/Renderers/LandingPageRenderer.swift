import Foundation
import SiteKit

/// The home page: hero, the See · Taste · Unwind trio, features, Free and Premium, FAQ, call to action.
/// Text comes from `Content/Data/Landing(.uk).yaml`, the App Store id from `Content/Data/App.yaml`.
struct LandingPageRenderer: Renderer {
   func render(context: BuildContext) throws -> [OutputFile] {
      let helper = OutputFileRenderer(context: context)
      let dataDirectory = context.projectDirectory
         .appendingPathComponent(context.config.contentDirectory)
         .appendingPathComponent("Data")

      let locale = context.uiStrings.locale
      let suffix = locale == context.config.effectiveDefaultLanguage ? "" : ".\(locale)"
      let data = try YAMLLoader<LandingData>().load(
         source: YAMLSource(url: dataDirectory.appendingPathComponent("Landing\(suffix).yaml"))
      )
      let app = try YAMLLoader<AppData>().load(
         source: YAMLSource(url: dataDirectory.appendingPathComponent("App.yaml"))
      )

      let canonicalURL = context.config.baseURL + context.router.homePath()
      let description = context.config.localization?.localeOverrides?[locale]?.description
         ?? context.config.description
      var head = helper.buildHead(
         title: data.pageTitle,
         description: description,
         canonicalURL: canonicalURL,
         ogType: "website",
         image: context.config.baseURL + "/assets/images/fox-welcome.png",
         imageAlt: data.hero.imageAlt,
         jsonLD: self.applicationJSONLD(name: context.config.name, description: description, url: canonicalURL, app: app),
         hreflang: helper.buildHreflangForAllLanguages { $0.homePath() },
         preloadImageURL: "/assets/images/fox-welcome.png"
      )
      // Smart App Banner: Safari on iPhone shows it only when the app has an App Store id.
      if app.appStoreURL != nil {
         head += "<meta name=\"apple-itunes-app\" content=\"app-id=\(app.appStoreID)\"/>"
      }

      let sections = [
         self.renderHero(data.hero, app: app),
         self.renderTrio(data.trio),
         self.renderFeatures(data.features),
         self.renderScreens(data.screens, language: locale),
         self.renderPricing(data.pricing),
         self.renderFAQ(data.faq),
         self.renderCTA(data.cta, hero: data.hero, app: app),
      ]
      let html = helper.renderPageShell(
         head: head,
         bodyClass: "sk-page-home landing kw-landing",
         content: "<main class=\"sk-main landing-page kw-map\"><svg class=\"kw-route\" aria-hidden=\"true\" focusable=\"false\"></svg>\(sections.joined())</main>"
      )

      let outputPath = context.outputDirectory
         .appendingPathComponent(String(context.router.homePath().dropFirst()))
         .appendingPathComponent("index.html")
      return [OutputFile(outputPath: outputPath, content: html)]
   }

   // MARK: - Sections

   private func renderHero(_ hero: HeroSection, app: AppData) -> String {
      """
      <section class="kw-hero">
         <div class="landing-container kw-hero-inner">
            <div class="kw-hero-text">
               <p class="kw-eyebrow">\(hero.eyebrow.htmlEscaped)</p>
               <h1 class="kw-hero-title">\(hero.title.htmlEscaped)</h1>
               <p class="kw-hero-subtitle">\(hero.subtitle.htmlEscaped)</p>
               <div class="kw-hero-actions" data-kw-stop="start">\(self.storeAction(hero: hero, app: app))</div>
            </div>
            <img class="kw-hero-fox" src="/assets/images/fox-welcome.png" alt="\(hero.imageAlt.htmlEscaped)" width="720" height="720" fetchpriority="high"/>
         </div>
      </section>
      """
   }

   private func renderTrio(_ trio: TrioSection) -> String {
      let cards = trio.items.map { item in
         """
         <li class="kw-trio-card kw-\(item.category.htmlEscaped)" data-kw-stop="\(item.category.htmlEscaped)">
            <img src="\(item.imagePath.htmlEscaped)" alt="\(item.imageAlt.htmlEscaped)" width="480" height="480" loading="lazy"/>
            <h3 class="kw-trio-name">\(item.name.htmlEscaped)</h3>
            <p>\(item.description.htmlEscaped)</p>
         </li>
         """
      }.joined()
      return """
      <section id="how-it-works" class="kw-section kw-trio">
         <div class="landing-container">
            <h2 class="landing-section-title">\(trio.title.htmlEscaped)</h2>
            <p class="kw-section-subtitle">\(trio.subtitle.htmlEscaped)</p>
            <ol class="kw-trio-grid">\(cards)</ol>
         </div>
      </section>
      """
   }

   private func renderFeatures(_ features: FeaturesSection) -> String {
      let rows = features.items.map { feature in
         """
         <li class="kw-feature" data-kw-stop="feature">
            <img src="\(feature.imagePath.htmlEscaped)" alt="\(feature.imageAlt.htmlEscaped)" width="480" height="480" loading="lazy"/>
            <div>
               <h3>\(feature.title.htmlEscaped)</h3>
               <p>\(feature.description.htmlEscaped)</p>
            </div>
         </li>
         """
      }.joined()
      return """
      <section id="features" class="kw-section kw-features">
         <div class="landing-container">
            <h2 class="landing-section-title">\(features.title.htmlEscaped)</h2>
            <ul class="kw-feature-list">\(rows)</ul>
         </div>
      </section>
      """
   }

   private func renderScreens(_ screens: ScreensSection, language: String) -> String {
      let phones = screens.items.map { screen in
         let base = "/assets/images/screens/\(language.htmlEscaped)"
         let id = screen.id.htmlEscaped
         return """
         <li class="kw-shot">
            <div class="kw-phone">
               <img class="kw-shot-light" src="\(base)-light-\(id).jpg" alt="\(screen.imageAlt.htmlEscaped)" width="390" height="844" loading="lazy" decoding="async"/>
               <img class="kw-shot-dark" src="\(base)-dark-\(id).jpg" alt="\(screen.imageAlt.htmlEscaped)" width="390" height="844" loading="lazy" decoding="async"/>
            </div>
            <p class="kw-shot-caption">\(screen.caption.htmlEscaped)</p>
         </li>
         """
      }.joined()
      return """
      <section id="screens" class="kw-section kw-screens">
         <div class="landing-container">
            <h2 class="landing-section-title">\(screens.title.htmlEscaped)</h2>
            <p class="kw-section-subtitle">\(screens.subtitle.htmlEscaped)</p>
            <ul class="kw-shot-row" data-kw-stop="screens">\(phones)</ul>
         </div>
      </section>
      """
   }

   private func renderPricing(_ pricing: PricingSection) -> String {
      let cards = pricing.tiers.map { tier in
         let highlighted = (tier.highlighted ?? false) ? " kw-tier-highlighted" : ""
         let badge = tier.badge.map { "<span class=\"kw-tier-badge\">\($0.htmlEscaped)</span>" } ?? ""
         let items = tier.features.map { "<li>\($0.htmlEscaped)</li>" }.joined()
         return """
         <div class="kw-tier\(highlighted)">
            <div class="kw-tier-header"><h3>\(tier.name.htmlEscaped)</h3>\(badge)</div>
            <p class="kw-tier-summary">\(tier.summary.htmlEscaped)</p>
            <ul>\(items)</ul>
         </div>
         """
      }.joined()
      return """
      <section id="pricing" class="kw-section kw-pricing">
         <div class="landing-container">
            <h2 class="landing-section-title">\(pricing.title.htmlEscaped)</h2>
            <p class="kw-section-subtitle">\(pricing.subtitle.htmlEscaped)</p>
            <div class="kw-tier-grid" data-kw-stop="pricing">\(cards)</div>
            <p class="kw-pricing-note">\(pricing.note.htmlEscaped)</p>
         </div>
      </section>
      """
   }

   private func renderFAQ(_ faq: FAQSection) -> String {
      let items = faq.items.map { item in
         """
         <details class="landing-faq-item">
            <summary>\(item.question.htmlEscaped)</summary>
            <p>\(item.answer.htmlEscaped)</p>
         </details>
         """
      }.joined()
      return """
      <section id="faq" class="kw-section landing-faq">
         <div class="landing-container">
            <h2 class="landing-section-title">\(faq.title.htmlEscaped)</h2>
            \(items)
         </div>
      </section>
      """
   }

   private func renderCTA(_ cta: CTASection, hero: HeroSection, app: AppData) -> String {
      """
      <section class="kw-section kw-cta">
         <div class="landing-container">
            <h2 class="landing-section-title">\(cta.title.htmlEscaped)</h2>
            <p class="kw-section-subtitle">\(cta.subtitle.htmlEscaped)</p>
            <div class="kw-hero-actions" data-kw-stop="finish">\(self.storeAction(hero: hero, app: app, label: cta.buttonText))</div>
         </div>
      </section>
      """
   }

   /// The App Store button, or a "coming soon" note while the app has no App Store id.
   private func storeAction(hero: HeroSection, app: AppData, label: String? = nil) -> String {
      guard let url = app.appStoreURL else {
         return "<p class=\"kw-coming-soon\">\(hero.comingSoon.htmlEscaped)</p>"
      }
      return "<a class=\"kw-store-button\" href=\"\(url)\">\((label ?? hero.appStoreBadgeAlt).htmlEscaped)</a>"
   }

   // MARK: - Structured data

   private func applicationJSONLD(name: String, description: String, url: String, app: AppData) -> String {
      var json: [String: Any] = [
         "@context": "https://schema.org",
         "@type": "MobileApplication",
         "name": name,
         "description": description,
         "url": url,
         "operatingSystem": "iOS 26",
         "applicationCategory": "TravelApplication",
         "offers": ["@type": "Offer", "price": "0", "priceCurrency": "USD"],
      ]
      if let storeURL = app.appStoreURL {
         json["installUrl"] = storeURL
      }
      guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]),
            let string = String(data: data, encoding: .utf8)
      else { return "{}" }
      // `</` would end the <script> element early.
      return string.replacing("</", with: "<\\/")
   }
}
