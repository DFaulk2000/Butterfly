import SwiftUI

import Photos
import PhotosUI
import CoreData

struct ImageFunctions {
  /// Retrieve all `PHAsset`s of `PHAssetMediaType.image` for a `PHAssetCollection`.
  static func fetchImageAssetsForCollection(collection: PHAssetCollection)->[PHAsset] {
    var assets: [PHAsset] = []
    let fetchResults = PHAsset.fetchAssets(in: collection, options: nil)
    fetchResults.enumerateObjects {(asset: PHAsset, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
      switch asset.mediaType {
      case PHAssetMediaType.image:
        assets.append(asset)
      default:
        break
      }
    }
    
    return assets
  }
  
  /// Synchronously retrieve a `UIImage` for a given `PHAsset` and `CGSize`
  static func getUIImageFromAssetSync(asset: PHAsset, size: CGSize)->UIImage? {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.isSynchronous = true
    var uiImage: UIImage?
    
    ButterflyApp.imageManager.requestImage(
      for: asset,
      targetSize: size,
      contentMode: .aspectFill,
      options: options,
      resultHandler: { image, _ in
        uiImage = image
      }
    )
    
    return uiImage
  }

  /// Asynchronously retrieve a `UIImage` for a given `PHAsset` and `CGSize`. Pass in a `resultHandler` to update the image as varying levels of quality are returned.
  static func getUIImageFromAsset(asset: PHAsset, size: CGSize, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void)->Void {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.isSynchronous = false
    
    ButterflyApp.imageManager.requestImage(
      for: asset,
      targetSize: size,
      contentMode: .aspectFill,
      options: options,
      resultHandler: resultHandler
    )
  }
  
  static func changeDateForAsset(asset: PHAsset, newDate: Date) {
    PHPhotoLibrary.shared().performChanges {
      let request = PHAssetChangeRequest(for: asset)
      request.creationDate = newDate
    } completionHandler: { success, error in
      print("Finished updating assets. " + (success ? "Success." : "Error"))
    }
  }
  
  static func getCloudIdentifiersMap(assets: [PHAsset]) -> [String: String] {
    let cloudIDs = PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: assets.map({ asset in asset.localIdentifier }))
    do {
      return try Dictionary(uniqueKeysWithValues: cloudIDs.map{($0, try $1.get().stringValue)})
    } catch {
      print("error")
      return [:]
    }
  }
  
  static func getLocalIdentifiersForCloudIdentifiersMap(identifiers: [PHCloudIdentifier]) -> [PHCloudIdentifier: String] {
    let localIds = PHPhotoLibrary.shared().localIdentifierMappings(for: identifiers)
    do {
      return try Dictionary(uniqueKeysWithValues: localIds.map{($0, try $1.get())})
    } catch {
      print("error")
      return [:]
    }
  }
  
  static func getAssetsFromLocalIdentifiers(identifiers: [PHCloudIdentifier: String]) -> [PHCloudIdentifier: PHAsset] {
    return Dictionary(uniqueKeysWithValues: identifiers.map({
      return ($0.key, PHAsset.fetchAssets(withLocalIdentifiers: [$0.value], options: nil).firstObject ?? PHAsset())
    }))
  }
  
  static func removeDuplicates(butterflyAssets: FetchedResults<ButterflyAsset>, managedObjectContext: NSManagedObjectContext) {
    // This deletes butterfly assets that have duplicate IDs
    // It deletes the ones that don't match the date of the photo in the library.
    
    // The assumption is that if we have duplicates, at least one will match.
    if (butterflyAssets.count > 0) {
      let localIDs = ImageFunctions.getLocalIdentifiersForCloudIdentifiersMap(identifiers: butterflyAssets.map({ butterflyAsset in PHCloudIdentifier(stringValue: butterflyAsset.assetId!) }))
      let assets = ImageFunctions.getAssetsFromLocalIdentifiers(identifiers: localIDs)
      
      let crossReference = Dictionary(grouping: butterflyAssets, by: { $0.assetId })
      let duplicates = crossReference.filter { $1.count > 1 }
      
      duplicates.forEach({
        let butterflyAssets = $1
        butterflyAssets.forEach({
          let butterflyAsset = $0
          let asset = assets[PHCloudIdentifier(stringValue: butterflyAsset.assetId!)]
          let assetDate = asset?.creationDate
          if assetDate! != butterflyAsset.butterflyDate! {
            managedObjectContext.delete(butterflyAsset)
          }
        })
      })
      
      PersistenceController.shared.save()
    }
  }
}
