import Photos
import SwiftUI
import CoreData

struct TheButterFlyEffect {
  var collectionWrapper: PHAssetCollectionWrapper
  var butterflyAssets: FetchedResults<ButterflyAsset>
  var managedObjectContext: NSManagedObjectContext
 
  private func getButterflyDateForAsset(_ asset: PHAsset) -> Date {
    let butterflyAsset = butterflyAssets.first(where: { butterflyAsset in
      butterflyAsset.assetId == collectionWrapper.assetCloudIds[asset.localIdentifier]
    })
    
    return butterflyAsset?.butterflyDate ?? Date()
  }
  
  private func createOrUpdateButterflyAsset(index: Int, locked: Bool = true, newDate: Date) {
    let assetToChange = collectionWrapper.assets[index]
    let butterflyAsset = butterflyAssets.first(where: { butterflyAsset in
      butterflyAsset.assetId == collectionWrapper.assetCloudIds[assetToChange.localIdentifier]
    })

    let originalDate = butterflyAsset?.originalDate ?? assetToChange.creationDate
    let newButterflyAsset = butterflyAsset ?? ButterflyAsset(context: managedObjectContext)
    
    newButterflyAsset.assetId = collectionWrapper.assetCloudIds[assetToChange.localIdentifier]
    newButterflyAsset.originalDate = originalDate
    newButterflyAsset.locked = locked
    newButterflyAsset.butterflyDate = newDate
    ImageFunctions.changeDateForAsset(asset: assetToChange, newDate: newDate)
    
    PersistenceController.shared.save()
  }
  
  private func isValidLockedPosition(firstLocked: (index: Int?, butterflyAsset: ButterflyAsset?), lastLocked: (index: Int?, butterflyAsset: ButterflyAsset?)) -> Bool {
    guard let firstDate = firstLocked.butterflyAsset?.butterflyDate else { return true }
    guard let currentDate = lastLocked.butterflyAsset?.butterflyDate else { return true }
    return (firstDate <= currentDate)
  }
  
  private func getNextLockedImages(startIndex: Int = 0) -> (start: (index: Int?, butterflyAsset: ButterflyAsset?), end: (index: Int?, butterflyAsset: ButterflyAsset?)) {
    var currentIndex = startIndex
    var firstLocked: (index: Int?, butterflyAsset: ButterflyAsset?) = (nil, nil)
    var lastLocked: (index: Int?, butterflyAsset: ButterflyAsset?) = (nil, nil)
    
    while (firstLocked.index == nil || lastLocked.index == nil) && currentIndex < collectionWrapper.assets.count {
      let currentAsset = collectionWrapper.assets[currentIndex]
      let currentButterflyAsset = butterflyAssets.first(where: { butterflyAsset in
        butterflyAsset.assetId == collectionWrapper.assetCloudIds[currentAsset.localIdentifier]
      })
      
      if currentButterflyAsset != nil && currentButterflyAsset!.locked {
        if firstLocked.index == nil {
          firstLocked.index = currentIndex
          firstLocked.butterflyAsset = currentButterflyAsset
        } else {
          lastLocked = (index: currentIndex, butterflyAsset: currentButterflyAsset)
        }
      }
      
      currentIndex += 1
    }
    
    return (start: firstLocked, end: lastLocked)
  }
  
  private func repairLockedImages(startIndex: Int = 0) -> Void {
    var currentIndex = startIndex

    while (currentIndex < collectionWrapper.assets.count) {
      let (firstLocked, lastLocked) = getNextLockedImages(startIndex: currentIndex)
      
      // TODO: Fix the issue where this results in an image whose date cannot be re-locked with the default date picker value
      if !isValidLockedPosition(firstLocked: firstLocked, lastLocked: lastLocked) {
        firstLocked.butterflyAsset!.locked = false
        PersistenceController.shared.save()
      } else {
        currentIndex += 1
      }
    }
  }
  
  func theButterflyEffect() {
    // Validate and repair locked images
    repairLockedImages()
    
    var lockedImages = getNextLockedImages()
    
    while lockedImages.start.index != nil && lockedImages.end.index != nil {
      // We have to use the local ButterflyAsset date because the photo library will not have updated yet and returned the new dates
      let startDate = getButterflyDateForAsset(collectionWrapper.assets[lockedImages.start.index!])
      let endDate = getButterflyDateForAsset(collectionWrapper.assets[lockedImages.end.index!])
      let diff = abs(Int(endDate.timeIntervalSince(startDate)) / (lockedImages.end.index! - lockedImages.start.index!))
      
      var runningDiff = diff
      for index in lockedImages.start.index! + 1..<lockedImages.end.index! {
        let newDate = startDate.addingTimeInterval(Double(runningDiff))
        createOrUpdateButterflyAsset(index: index, locked: false, newDate: newDate)
        runningDiff += diff
      }
      
      lockedImages = getNextLockedImages(startIndex: lockedImages.end.index!)
    }
    PersistenceController.shared.save()
  }
}
