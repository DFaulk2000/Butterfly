import Foundation
import Photos

class PHAssetCollectionWrapper: Hashable, Identifiable, ObservableObject {
  var id: String
  var name: String
  var phAssetCollection: PHAssetCollection
  var startDate: Date?
  var endDate: Date?
  
  @Published var assets: [PHAsset]
  @Published var assetCloudIds: [String: String]
  
  init(phAssetCollection: PHAssetCollection) {
    let assets = ImageFunctions.fetchImageAssetsForCollection(collection: phAssetCollection)
    
    self.id = phAssetCollection.localIdentifier
    self.name = phAssetCollection.localizedTitle ?? "No Album Name"
    self.phAssetCollection = phAssetCollection
    self.assets = assets
    self.assetCloudIds = ImageFunctions.getCloudIdentifiersMap(assets: assets)
    self.startDate = phAssetCollection.startDate
    self.endDate = phAssetCollection.endDate
  }
  
  static func == (lhs: PHAssetCollectionWrapper, rhs: PHAssetCollectionWrapper) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  func updateAssets(newPhAssetCollection: PHAssetCollection) {
    DispatchQueue.main.async {
      let assets = ImageFunctions.fetchImageAssetsForCollection(collection: newPhAssetCollection)
      self.assets = assets
      self.assetCloudIds = ImageFunctions.getCloudIdentifiersMap(assets: assets)
      self.startDate = newPhAssetCollection.startDate
      self.endDate = newPhAssetCollection.endDate
      self.objectWillChange.send()
    }
  }
}


class LibraryCoordinator: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
  @Published var isPhotoLibraryAuthorized: Bool?
  @Published var phAssetCollectionWrappers: [PHAssetCollectionWrapper] = []

  override init() {
    super.init()
    
    // TODO: Fix "authorized" being the status even when no photos are given
    PHPhotoLibrary.requestAuthorization { status in
      switch status {
        case
          .authorized:
          PHPhotoLibrary.shared().register(self)
          self.updateStatus()
        default:
          self.isPhotoLibraryAuthorized = false
      }
    }
  }

  func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.async {
      for wrapper in self.phAssetCollectionWrappers {
        let changeDetails = changeInstance.changeDetails(for: wrapper.phAssetCollection)
        if changeDetails != nil {
          wrapper.updateAssets(newPhAssetCollection: changeDetails!.objectAfterChanges!)
          print(changeDetails!.objectAfterChanges!.startDate ?? "No start date")
        }
      }
      print("Photo library has changed")
      self.updateStatus()
    }
  }
  
  func getPhAssetCollections() {
    var assetCollections: [PHAssetCollectionWrapper] = []
    DispatchQueue.main.async {
      let photoGroupsOptions = PHFetchOptions()
      let results = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: photoGroupsOptions)
      results.enumerateObjects {(assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
        // Disable shared albums
        if assetCollection.assetCollectionSubtype != PHAssetCollectionSubtype.albumCloudShared {
          let collectionWrapper = PHAssetCollectionWrapper(phAssetCollection: assetCollection)
          assetCollections.append(collectionWrapper)
        }
      }
      self.phAssetCollectionWrappers = assetCollections
    }
  }
  
  private func updateStatus() {
    DispatchQueue.main.async {
      if self.isPhotoLibraryAuthorized == nil || !self.isPhotoLibraryAuthorized! {
        self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        if self.phAssetCollectionWrappers.isEmpty {
          self.getPhAssetCollections()
        }
      }
    }
  }
}
