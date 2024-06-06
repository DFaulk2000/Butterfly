import SwiftUI

import Photos
import PhotosUI
import CoreData

import Sentry

@main
struct ButterflyApp: App {
  @Environment(\.scenePhase) var scenePhase
  
  // TODO: We should start caching images somewhere (https://developer.apple.com/documentation/photokit/phcachingimagemanager)
  static let cachedImageManager: PHCachingImageManager = PHCachingImageManager()
  static let imageManager: PHImageManager = PHImageManager()
  static let targetImageSize: CGSize = CGSize(width: 2000, height: 2000)
  static let targetSmallThumbnailSize = CGSize(width: 85, height: 85)
  static let targetThumbnailSize: CGSize = CGSize(width: 200, height: 200)
  static let targetThumbnailSizeCGSize: CGSize = CGSize(width: 450, height: 450)
  static let thumbnailBorderRadius: CGFloat = 3
  static let illustrationBorderRadius: CGFloat = 6
  static let shadowRadius: CGFloat = 2
  static let thumbnailShadowRadius: CGFloat = 5
  static let animationDuration: Double = 0.125
  static let backgroundColor = Color(UIColor.systemBackground)
  static let springAnimation = Animation.spring(response: 0.9, dampingFraction: 0.65).speed(3)
  static let dateFormatter = DateFormatter()
  
  let persistenceController = PersistenceController.shared
  
  init() {
    ButterflyApp.dateFormatter.dateStyle = .medium;
    ButterflyApp.dateFormatter.timeStyle = .none;
    // TODO: Localise this
    ButterflyApp.dateFormatter.locale = Locale(identifier: "en_GB");
    
    SentrySDK.start { options in
      options.dsn = "https://6bee428eb7c1425e831b99cb76afe66f@o426946.ingest.sentry.io/6532096"
      options.debug = false
      options.tracesSampleRate = 0.05
    }
  }
  
  
  static func dropDatabase() {
    PersistenceController.shared.dropData()
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onChange(of: scenePhase) { _ in // Save data when app moves to the background
          persistenceController.save()
        }
    }
  }
}

extension Bundle {
  public var icon: UIImage? {
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
      let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
      let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
      let lastIcon = iconFiles.last {
      return UIImage(named: lastIcon)
    }
    return nil
  }
}
