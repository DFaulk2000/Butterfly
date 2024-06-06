import SwiftUI

import Photos
import PhotosUI


class AssetGridItem: Identifiable, Equatable, Hashable, ObservableObject, NSCopying {
  let id: String
  let asset: PHAsset
  
  @Published var uiImage: UIImage?
  @Published var originalCreationDate: Date
  @Published var newCreationDate: Date?

  init(asset: PHAsset, creationDate: Date? = nil) { // creationDate here is only for testing
    self.asset = asset
    self.id = asset.localIdentifier
    
    self.originalCreationDate = creationDate ?? self.asset.creationDate ?? Date()
  }
  
  static func == (lhs: AssetGridItem, rhs: AssetGridItem) -> Bool {
    lhs.id == rhs.id &&
    lhs.originalCreationDate == rhs.originalCreationDate &&
    lhs.newCreationDate == rhs.newCreationDate
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  func copy(with zone: NSZone? = nil) -> Any {
    return AssetGridItem(asset: asset, creationDate: originalCreationDate)
  }
  
  func createUiImage() {
    ImageFunctions.getUIImageFromAsset(
      asset: asset,
      size: ButterflyApp.targetThumbnailSizeCGSize,
      resultHandler: { image, _ in
        self.uiImage = image ?? UIImage()
      }
    )
  }
}
