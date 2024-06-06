import SwiftUI
import Photos


struct ThumbnailDateLabel: View {
  var creationDate: Date
  var isLocked: Bool = false
  
  var body: some View {
    HStack(spacing: 3) {
      if isLocked {
        Image(systemName: "lock.fill")
          .padding(.init(top: 3, leading: 3, bottom: 3, trailing: 0))
      }
      Text(ButterflyApp.dateFormatter.string(from: creationDate))
        .padding(.init(top: 3, leading: !isLocked ? 3 : 0, bottom: 3, trailing: 3))
    }
    .font(.caption)
    .background(isLocked ? .ultraThickMaterial : .ultraThinMaterial, in: RoundedRectangle(cornerRadius: ButterflyApp.thumbnailBorderRadius))
    .padding(10)
  }
}

struct ThumbnailView: View {
  @State private var uiImage: UIImage = UIImage()
   
  var asset: PHAsset
  var size: CGSize
  var contentMode: ContentMode = .fill
  var async: Bool = true

  var body: some View {
    Image(uiImage: self.uiImage)
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .clipped()
      .onAppear {
        if async {
          ImageFunctions.getUIImageFromAsset(
            asset: asset,
            size: size,
            resultHandler: { image, _ in
              self.uiImage = image ?? UIImage()
            }
          )
        } else {
          self.uiImage = ImageFunctions.getUIImageFromAssetSync(asset: asset, size: size) ?? UIImage()
        }
      }
  }
}

struct UiImageThumbnailView: View {
  var uiImage: UIImage
  var size: CGSize
  var contentMode: ContentMode = .fill
  var async: Bool = true

  var body: some View {
    Image(uiImage: self.uiImage)
      .resizable()
      .aspectRatio(contentMode: contentMode)
  }
}
