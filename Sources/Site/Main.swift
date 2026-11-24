import SiteKit

@main struct Site {
   static func main() throws {
      try SiteBuilder.portfolio(configPath: "SiteConfig.yaml")
         .replacing(HomePageRenderer.self, with: LandingPageRenderer())
         .processor(IndexesKeepExistingPages(baseURL: "https://kitwayapp.github.io"))
         .run()
   }
}
