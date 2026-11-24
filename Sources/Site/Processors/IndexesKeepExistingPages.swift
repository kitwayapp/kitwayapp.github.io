import Foundation
import SiteKit

/// Removes entries for pages that were not written from `sitemap.xml` and `llms.txt`.
///
/// With no sections configured, SiteKit 1.0.2 still falls back to a "Blog" section and lists `/blog/` and its feed,
/// although the landing site has no blog. A search engine or an agent that follows those entries would get a 404.
struct IndexesKeepExistingPages: OutputProcessor {
   let baseURL: String

   func process(outputDirectory: URL, projectDirectory: URL, themeConfig: ThemeConfig?) throws {
      let files = FileManager.default.enumerator(at: outputDirectory, includingPropertiesForKeys: nil)?
         .compactMap { $0 as? URL } ?? []
      for file in files {
         switch file.lastPathComponent {
         case "sitemap.xml":
            try self.rewrite(file) { xml in
               xml.replacing(#/<url><loc>([^<]*)</loc>.*?</url>/#) { match in
                  self.exists(String(match.output.1), in: outputDirectory) ? String(match.output.0) : ""
               }
            }
         case "llms.txt":
            try self.rewrite(file) { text in
               text.split(separator: "\n", omittingEmptySubsequences: false).filter { line in
                  guard let match = line.firstMatch(of: #/^- \[[^\]]*\]\(([^)]*)\)/#) else { return true }
                  return self.exists(String(match.output.1), in: outputDirectory)
               }.joined(separator: "\n")
            }
         default:
            continue
         }
      }
   }

   private func rewrite(_ file: URL, _ transform: (String) -> String) throws {
      let original = try String(contentsOf: file, encoding: .utf8)
      let cleaned = transform(original)
      if cleaned != original {
         try cleaned.write(to: file, atomically: true, encoding: .utf8)
      }
   }

   /// Whether a URL on this site points to a written file. URLs on other sites always count as existing.
   private func exists(_ location: String, in outputDirectory: URL) -> Bool {
      guard location.hasPrefix(self.baseURL) else { return true }
      let path = String(location.dropFirst(self.baseURL.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      let target = path.isEmpty ? outputDirectory : outputDirectory.appendingPathComponent(path)
      let file = path.contains(".") ? target : target.appendingPathComponent("index.html")
      return FileManager.default.fileExists(atPath: file.path)
   }
}
