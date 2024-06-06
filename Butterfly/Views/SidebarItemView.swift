import SwiftUI
import Photos


struct SidebarItemView: View {
  @ObservedObject var collectionWrapper: PHAssetCollectionWrapper
  var collection: PHAssetCollection
  var title: String
  var sidebarDateFormatter: DateFormatter = DateFormatter()
  
  init(collectionWrapper: PHAssetCollectionWrapper) {
    self.sidebarDateFormatter.timeStyle = .none
    self.sidebarDateFormatter.locale = Locale(identifier: "en_GB")
    self.sidebarDateFormatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
    
    self.collectionWrapper = collectionWrapper
    self.collection = collectionWrapper.phAssetCollection
    self.title = self.collection.localizedTitle ?? "No Title"
  }
  
  func formatDate(_ date: Date) -> String {
    sidebarDateFormatter.string(from: date)
  }
  
  func getDateView(_ startDate: Date?, _ endDate: Date?) -> some View {
    if startDate != nil && endDate != nil {
      let start = formatDate(startDate!)
      let end = formatDate(endDate!)
      let view = Text(start == end ? start : "\(start) – \(end)")
      return view
    } else {
      return Text("No valid dates")
    }
  }
  
  var body: some View {
    HStack {
      VStack {
        ZStack {
          ForEach(Array(self.collectionWrapper.assets.prefix(3).reversed().enumerated()), id: \.element) { index, element in
            ZStack {
              ThumbnailView(
                asset: element,
                size: ButterflyApp.targetSmallThumbnailSize,
                contentMode: .fit,
                async: true
              )
                .cornerRadius(ButterflyApp.thumbnailBorderRadius)
                .shadow(radius: ButterflyApp.thumbnailShadowRadius)
                .frame(
                  width: ButterflyApp.targetSmallThumbnailSize.width,
                  height: ButterflyApp.targetSmallThumbnailSize.height,
                  alignment: .center
                )
                .offset(y: CGFloat(index) * 4)
                .layoutPriority(-1)
                .padding(.top)
                .padding(.bottom)
            }
          }
        }
        .offset(y: -4) // offset entire thumbnail stack so it's centred
        .padding(.leading)
        .padding(.trailing)
      }
      VStack(alignment: .leading) {
        Spacer()
        Text(self.title).fontWeight(.bold)
          .padding(.bottom, 1)
        Text("\(self.collectionWrapper.assets.count) photos")
          .font(.caption)
        getDateView(self.collectionWrapper.startDate, self.collectionWrapper.endDate)
          .font(.caption)
        Spacer()
      }
      .font(.body)
      .multilineTextAlignment(.leading)
    }
  }
}
