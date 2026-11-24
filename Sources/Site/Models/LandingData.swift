import Foundation

/// Facts about the app that are the same in every language: `Content/Data/App.yaml`.
struct AppData: Decodable, Sendable {
   /// The numeric App Store id from App Store Connect; empty until the app has one.
   /// While it is empty the site shows no App Store button and no Smart App Banner.
   let appStoreID: String

   var appStoreURL: String? {
      guard !self.appStoreID.isEmpty, self.appStoreID.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
      return "https://apps.apple.com/app/id\(self.appStoreID)"
   }
}

/// The text of the landing page in one language: `Content/Data/Landing.yaml`, `Landing.uk.yaml`.
struct LandingData: Decodable, Sendable {
   let pageTitle: String
   let hero: HeroSection
   let trio: TrioSection
   let features: FeaturesSection
   let screens: ScreensSection
   let pricing: PricingSection
   let faq: FAQSection
   let cta: CTASection
}

struct HeroSection: Decodable, Sendable {
   let eyebrow: String
   let title: String
   let subtitle: String
   let imageAlt: String
   /// Shown instead of the App Store button while the app has no App Store id.
   let comingSoon: String
   let appStoreBadgeAlt: String
}

struct TrioSection: Decodable, Sendable {
   let title: String
   let subtitle: String
   let items: [TrioItem]
}

struct TrioItem: Decodable, Sendable {
   /// `see`, `taste` or `unwind`: picks the category colour, as in the app.
   let category: String
   let name: String
   let description: String
   let imagePath: String
   let imageAlt: String
}

struct FeaturesSection: Decodable, Sendable {
   let title: String
   let items: [Feature]
}

struct Feature: Decodable, Sendable {
   let title: String
   let description: String
   let imagePath: String
   let imageAlt: String
}

/// The app's screens on phones. Each screen has a light and a dark capture per language:
/// `/assets/images/screens/<language>-<light|dark>-<id>.jpg`.
struct ScreensSection: Decodable, Sendable {
   let title: String
   let subtitle: String
   let items: [Screen]
}

struct Screen: Decodable, Sendable {
   let id: String
   let caption: String
   let imageAlt: String
}

struct PricingSection: Decodable, Sendable {
   let title: String
   let subtitle: String
   let note: String
   let tiers: [PricingTier]
}

struct PricingTier: Decodable, Sendable {
   let name: String
   let badge: String?
   let summary: String
   let features: [String]
   let highlighted: Bool?
}

struct FAQSection: Decodable, Sendable {
   let title: String
   let items: [FAQItem]
}

struct FAQItem: Decodable, Sendable {
   let question: String
   let answer: String
}

struct CTASection: Decodable, Sendable {
   let title: String
   let subtitle: String
   let buttonText: String
}
