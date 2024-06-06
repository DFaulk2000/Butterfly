import Photos
import PhotosUI

struct ImageAssetManager {
  static var cachedAssets: [PHAsset] = []
  
  static func updateCachedAssets(assets: [PHAsset]) {
    ImageAssetManager.cachedAssets.append(contentsOf: assets)
    print("Caching assets for album, count: \(assets.count)")
    ButterflyApp.cachedImageManager.startCachingImages(
      for: ImageAssetManager.cachedAssets,
      targetSize: ButterflyApp.targetThumbnailSizeCGSize,
      contentMode: .aspectFill,
      options: nil
    )
  }
  
  static func getCachedAssets()->[PHAsset] {
    return ImageAssetManager.cachedAssets
  }
  
  static func resetCachedAssets() {
    ImageAssetManager.cachedAssets = []
    ButterflyApp.cachedImageManager.stopCachingImagesForAllAssets()
  }
}
