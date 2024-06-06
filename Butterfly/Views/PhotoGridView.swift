import SwiftUI
import Photos
import PhotosUI
import CoreData
import MapKit


struct PhotoGridView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest(
    entity: ButterflyAsset.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \ButterflyAsset.assetId, ascending: true)]
  ) var butterflyAssets: FetchedResults<ButterflyAsset>
  
  @State private var dragging: PHAsset?
  @State private var didMove: Bool = false
  @State private var hasEnteredGrid: Bool = false
  @State private var hasEnteredItem: Bool = false
  @State private var initialIndex: Int?
  @State private var finalIndex: Int?
  @State private var isShowingModificationView: Bool = false
  @State private var showInformationSheet: Bool = false
  @State private var lastChosenDate: Date?
  
  @ObservedObject var collectionWrapper: PHAssetCollectionWrapper
  var dragDropCatcher: DragDropCatcher
  
  var columns: [GridItem] = [GridItem(.adaptive(minimum: ButterflyApp.targetThumbnailSize.width, maximum: ButterflyApp.targetThumbnailSize.width), spacing: 2)]
  
  func lockedCount() -> Int {
    return butterflyAssets.filter{ $0.locked }.count
  }
  
  func resetImageDates() -> Void {
    for bAsset in butterflyAssets {
      let asset = collectionWrapper.assets.first(where: { asset in collectionWrapper.assetCloudIds[asset.localIdentifier] == bAsset.assetId })
      if asset != nil {
        ImageFunctions.changeDateForAsset(asset: asset!, newDate: bAsset.originalDate ?? Date())
        managedObjectContext.delete(bAsset)
      }
    }

    PersistenceController.shared.save()
  }
  
  init(collectionWrapper: PHAssetCollectionWrapper) {
    self.collectionWrapper = collectionWrapper
    self.dragDropCatcher = DragDropCatcher(wrapperReference: collectionWrapper)
  }
  
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 2) {
          ForEach(collectionWrapper.assets, id: \.self) { asset in
            PhotoGridItemView(
              asset: asset,
              collectionWrapper: collectionWrapper,
              dragging: $dragging,
              didMove: $didMove,
              hasEnteredGrid: $hasEnteredGrid,
              hasEnteredItem: $hasEnteredItem,
              initialIndex: $initialIndex,
              finalIndex: $finalIndex,
              isShowingModificationView: $isShowingModificationView,
              lastChosenDate: $lastChosenDate,
              butterflyAsset: butterflyAssets.first(where: { butterflyAsset in
                butterflyAsset.assetId == collectionWrapper.assetCloudIds[asset.localIdentifier]
              }),
              theButterflyEffect: TheButterFlyEffect(
                collectionWrapper: collectionWrapper,
                butterflyAssets: butterflyAssets,
                managedObjectContext: managedObjectContext
              ).theButterflyEffect,
              dragDropCatcher: self.dragDropCatcher
            )
          }
        }
        .padding(.bottom, 100)
      }
      .sheet(isPresented: $showInformationSheet) {
        InformationSheetView(resetDates: resetImageDates)
      }
      .onDrop(
        of: [UTType.image],
        delegate: DropOutsideDelegate(
          dragging: $dragging,
          didMove: $didMove,
          hasEnteredItem: $hasEnteredItem,
          hasEnteredGrid: $hasEnteredGrid,
          dragDropCatcher: self.dragDropCatcher
        )
      )
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Text(collectionWrapper.name)
          .bold()
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showInformationSheet.toggle() }) {
          HStack {
            if lockedCount() == 0 {
              Text("Tap on an image to set a date")
            } else if lockedCount() == 1 {
              Text("Set another date")
            } else {
              Text("Drag images to automatically set dates")
            }
            Image(systemName: "info.circle")
          }
        }
      }
    }
  }
}

