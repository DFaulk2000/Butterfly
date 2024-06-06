import SwiftUI


struct DragZoneView: View {
  @Binding var selectedImages: [AssetGridItem]
  
  var body: some View {
    HStack {
      Spacer()
      if selectedImages.count > 0 {
        ZStack {
          ForEach(Array(selectedImages), id: \.self) { assetGridItem in
            ZStack {
              ThumbnailView(
                asset: assetGridItem.asset,
                size: ButterflyApp.targetSmallThumbnailSize
              )
              .border(Color.black, width: 1)
              .shadow(radius: ButterflyApp.shadowRadius)
              .frame(
                width: ButterflyApp.targetSmallThumbnailSize.width,
                height: ButterflyApp.targetSmallThumbnailSize.height,
                alignment: .center
              )
              .rotationEffect(.degrees(Double.random(in: -20..<21)))
            }
          }
        }
        .onDrag {
          // We don't actually pass the data with the drag, the dropzone already has access
          let provider = NSItemProvider()
          return provider
        }
      } else {
        Text("Select images to batch update")
      }
      Spacer()
    }
    .background(.ultraThinMaterial)
  }
}
