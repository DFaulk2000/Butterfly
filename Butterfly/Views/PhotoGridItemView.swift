import SwiftUI
import Photos


struct PhotoGridItemView: View {
  var asset: PHAsset
  @ObservedObject var collectionWrapper: PHAssetCollectionWrapper
  @Binding var dragging: PHAsset?
  @Binding var didMove: Bool
  @Binding var hasEnteredGrid: Bool
  @Binding var hasEnteredItem: Bool
  @Binding var initialIndex: Int?
  @Binding var finalIndex: Int?
  @Binding var isShowingModificationView: Bool
  @Binding var lastChosenDate: Date?
  var butterflyAsset: ButterflyAsset?
  var theButterflyEffect: () -> Void
  var dragDropCatcher: DragDropCatcher
  
  @State var showModificationView: Bool = false
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack {
        ThumbnailView(
          asset: asset,
          size: ButterflyApp.targetThumbnailSizeCGSize,
          contentMode: .fill
        )
          .frame(width: ButterflyApp.targetThumbnailSize.width, height: ButterflyApp.targetThumbnailSize.height, alignment: .center)
          .clipped()
      }
      if butterflyAsset != nil {
        ThumbnailDateLabel(
          creationDate: butterflyAsset!.butterflyDate!,
          isLocked: butterflyAsset!.locked
        )
      }
    }
    .opacity(didMove && dragging?.localIdentifier == asset.localIdentifier ? 0.0 : 1)
    .contentShape(Rectangle())
    .frame(width: ButterflyApp.targetThumbnailSize.width, height: ButterflyApp.targetThumbnailSize.height, alignment: .center)
    .border(showModificationView ? Color.blue : ButterflyApp.backgroundColor.opacity(0), width: 2)
    .popover(isPresented: $showModificationView) {
      ImageModificationSheetView(
        collectionWrapper: collectionWrapper,
        asset: asset,
        showModificationView: $showModificationView,
        isShowingModificationView: $isShowingModificationView,
        butterflyAsset: butterflyAsset,
        lastChosenDate: $lastChosenDate,
        theButterflyEffect: theButterflyEffect
      )
    }
    .onTapGesture {
      if !isShowingModificationView {
        showModificationView.toggle()
      }
    }
    .onDrag {
      self.dragging = asset
      self.initialIndex = collectionWrapper.assets.firstIndex(of: dragging!)!
      
      // Snapshot the current gridin the drag drop catcher
      self.dragDropCatcher.setState(newState: collectionWrapper.assets, didMove: $didMove)
      
      let uiImage = ImageFunctions.getUIImageFromAssetSync(
        asset: asset,
        size: ButterflyApp.targetImageSize
      )
      let provider = NSItemProvider(object: uiImage ?? UIImage())
      return provider
    }
    .onDrop(
      of: [UTType.image],
      delegate: DragRelocateDelegate(
        asset: asset,
        collectionWrapper: collectionWrapper,
        dragging: $dragging,
        didMove: $didMove,
        hasEnteredItem: $hasEnteredItem,
        initialIndex: $initialIndex,
        finalIndex: $finalIndex,
        theButterflyEffect: theButterflyEffect,
        dragDropCatcher: dragDropCatcher
      )
    )
  }
}
