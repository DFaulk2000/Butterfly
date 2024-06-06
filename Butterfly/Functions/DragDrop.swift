import SwiftUI
import Photos
import PhotosUI

struct DragRelocateDelegate: DropDelegate {
  @State var asset: PHAsset?
  
  @ObservedObject  var collectionWrapper: PHAssetCollectionWrapper
  @Binding var dragging: PHAsset?
  @Binding var didMove: Bool
  @Binding var hasEnteredItem: Bool
  @Binding var initialIndex: Int?
  @Binding var finalIndex: Int?
  var theButterflyEffect: () -> Void
  var dragDropCatcher: DragDropCatcher
  
  func dropEntered(info: DropInfo) {
    self.dragDropCatcher.event(DragEvent.DragEnterThumbnail)
    
    self.didMove = true
    self.hasEnteredItem = true
    
    if (self.dragging == nil) {
      self.dragging = asset
    }
    
    let from = collectionWrapper.assets.firstIndex(of: dragging!)!
    let to = collectionWrapper.assets.firstIndex(of: asset!)!
    self.finalIndex = to
    
    if collectionWrapper.assets[finalIndex!].localIdentifier != dragging!.localIdentifier {
      collectionWrapper.assets.move(
        fromOffsets: IndexSet(integer: from),
        toOffset: to > from ? to + 1 : to
      )
    }
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .move)
  }
  
  func dropExited(info: DropInfo) {
    self.dragDropCatcher.event(DragEvent.DragExitThumbnail)
    
    self.hasEnteredItem = false
  }

  func performDrop(info: DropInfo) -> Bool {
    self.dragDropCatcher.event(DragEvent.DropThumbnail)
    if self.initialIndex != nil {
      PHPhotoLibrary.shared().performChanges({
        let request = PHAssetCollectionChangeRequest(for: collectionWrapper.phAssetCollection)
        request?.moveAssets(
          at: IndexSet(integer: self.initialIndex!),
          to: finalIndex!
        )
      }, completionHandler: { (success: Bool, error: Error?) -> Void in
        theButterflyEffect()
      })
    }
    
    self.dragging = nil
    self.didMove = false
    self.hasEnteredItem = false
    return true
  }
}

struct DropOutsideDelegate: DropDelegate {
  @Binding var dragging: PHAsset?
  @Binding var didMove: Bool
  @Binding var hasEnteredItem: Bool
  @Binding var hasEnteredGrid: Bool
  var dragDropCatcher: DragDropCatcher
  
  func dropEntered(info: DropInfo) {
    self.dragDropCatcher.event(DragEvent.DragEnterGrid)
    self.hasEnteredGrid = true
  }
  
  func dropExited(info: DropInfo) {
    self.dragDropCatcher.event(DragEvent.DragExitGrid)
//    self.hasEnteredGrid = false
//    if !self.hasEnteredItem {
//      self.dragging = nil
//      self.didMove = false
//    }
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    self.dragging = nil
    self.hasEnteredItem = false
    self.hasEnteredGrid = false
    return true
  }
}

enum DragEvent {
  case DragExitThumbnail
  case DragEnterThumbnail
  case DropThumbnail
  case DragEnterGrid
  case DragExitGrid
}

class DragDropCatcher {
  @ObservedObject var wrapperReference: PHAssetCollectionWrapper
  
  var didMove: Binding<Bool>? = nil
  var initialState: [PHAsset]? = nil
  var lastEvent: DragEvent? = nil
  
  init(wrapperReference: PHAssetCollectionWrapper) {
    self.wrapperReference = wrapperReference
  }
  
  func setState(newState: [PHAsset], didMove: Binding<Bool>) {
    self.initialState = newState
    self.didMove = didMove
  }
  
  func event(_ event: DragEvent) {
    self.lastEvent = event
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      if self.lastEvent != nil && self.initialState != nil {
        switch self.lastEvent! {
        case
          DragEvent.DragExitGrid,
          DragEvent.DragExitThumbnail:
          self.wrapperReference.assets = self.initialState!
          self.didMove?.wrappedValue = false
        default:
          return
        }
      }
    }
  }
}
