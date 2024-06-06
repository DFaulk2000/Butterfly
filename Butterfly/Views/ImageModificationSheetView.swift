import SwiftUI
import Photos
import CoreData

let oneHundredYears: Double = 3153600000

struct ImageModificationSheetView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest(
    entity: ButterflyAsset.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \ButterflyAsset.assetId, ascending: true)]
  ) var butterflyAssets: FetchedResults<ButterflyAsset>
  
  // Observe this so the view re-renders when the collection changes.
  // This should mean that our date ranges are calculated appropriately.
  @ObservedObject var collectionWrapper: PHAssetCollectionWrapper
  var asset: PHAsset
  @Binding var showModificationView: Bool
  @Binding var isShowingModificationView: Bool
  var butterflyAsset: ButterflyAsset?
  @Binding var lastChosenDate: Date?
  var theButterflyEffect: () -> Void
  
  @State private var date: Date
  
  func getValidDate(asset: PHAsset) -> Date {
    let bounds = getDateBounds()
    if asset.creationDate != nil && bounds.contains(asset.creationDate!) {
      return asset.creationDate ?? Date()
    } else {
      return bounds.lowerBound
    }
  }
  
  init(
    collectionWrapper: PHAssetCollectionWrapper,
    asset: PHAsset,
    showModificationView: Binding<Bool>,
    isShowingModificationView: Binding<Bool>,
    butterflyAsset: ButterflyAsset?,
    lastChosenDate: Binding<Date?>,
    theButterflyEffect: @escaping () -> Void
  ) {
    self.collectionWrapper = collectionWrapper
    self.asset = asset
    self._showModificationView = showModificationView
    self._isShowingModificationView = isShowingModificationView
    self.butterflyAsset = butterflyAsset
    self._date = State(initialValue: butterflyAsset?.butterflyDate ?? Date())
    self._lastChosenDate = lastChosenDate
    self.theButterflyEffect = theButterflyEffect
  }

  var body: some View {
    VStack(alignment: .center, spacing: 5) {
      HStack {
        if self.butterflyAsset?.locked ?? false {
          Button("Unlock", role: .destructive) {
            butterflyAsset!.locked = false
            PersistenceController.shared.save()
            showModificationView.toggle()
          }
        } else {
          Spacer()
        }
        Spacer()
        Text("Adjust Date")
          .font(.system(size: 18, weight: .bold))
        Spacer()
        Button("Dismiss") {
          showModificationView.toggle()
        }
      }
      DatePicker(
        "",
        selection: $date,
        in: getDateBounds(),
        displayedComponents: [.date]
      )
        .labelsHidden()
        .datePickerStyle(.wheel)
      Button(action: {
        runTheButterflyEffect()
        showModificationView.toggle()
        lastChosenDate = date
      }) {
        Text("Confirm")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .padding(.bottom)
//      if lastChosenDate != nil && getDateBounds().contains(lastChosenDate!) {
//        Button(action: {
//          self.date = self.lastChosenDate!
//          runTheButterflyEffect()
//          showModificationView.toggle()
//        }) {
//          Text("Use Recent: \(ButterflyApp.dateFormatter.string(from: lastChosenDate!))")
//            .frame(maxWidth: .infinity)
//        }
//        .buttonStyle(.borderedProminent)
//      }
    }
    .onAppear {
      isShowingModificationView = true
      self.date = butterflyAsset?.butterflyDate ?? getValidDate(asset: asset)
    }
    .onDisappear {
      isShowingModificationView = false
    }
    .padding()
  }
  
  func walkToLockedImage(imageIndex: Int, forwards: Bool) -> ButterflyAsset? {
    let limit = forwards ? self.collectionWrapper.assets.count : -1
    var lockedAsset: ButterflyAsset?
    var currentIndex = forwards ? imageIndex + 1 : imageIndex - 1
    
    while lockedAsset == nil && currentIndex != limit {
      let currentAsset = self.collectionWrapper.assets[currentIndex]
      let lockedButterflyAsset = butterflyAssets.first(where: { butterflyAsset in
        butterflyAsset.assetId == collectionWrapper.assetCloudIds[currentAsset.localIdentifier] && butterflyAsset.locked
      })
      
      if lockedButterflyAsset != nil {
        lockedAsset = lockedButterflyAsset
      }
      
      currentIndex = forwards ? currentIndex + 1 : currentIndex - 1
    }
    
    return lockedAsset
  }
  
  func getDateBounds() -> ClosedRange<Date> {
    var end: Date = Date()
    var start: Date = end.addingTimeInterval(-oneHundredYears)
    
    var range: ClosedRange<Date>
    let initialIndex = collectionWrapper.assets.firstIndex(of: asset)
    
    if initialIndex != nil {
      let startAsset = walkToLockedImage(imageIndex: initialIndex!, forwards: false)
      let endAsset = walkToLockedImage(imageIndex: initialIndex!, forwards: true)
      
      end = endAsset?.butterflyDate ?? Date()
      start = startAsset?.butterflyDate ?? end.addingTimeInterval(-oneHundredYears)
    }
    
    // TODO: Crashes if end is before start
    range = start...end
    
    return range
  }
  
  func runTheButterflyEffect() {
    guard let imageIndex = self.collectionWrapper.assets.firstIndex(of: self.asset) else {
      return
    }
    
    func createOrUpdateButterflyAsset(index: Int, locked: Bool = true, newDate: Date) {
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
    
    createOrUpdateButterflyAsset(index: imageIndex, locked: true, newDate: self.date)
    
    TheButterFlyEffect(
      collectionWrapper: collectionWrapper,
      butterflyAssets: butterflyAssets,
      managedObjectContext: managedObjectContext
    ).theButterflyEffect()
  }
}
