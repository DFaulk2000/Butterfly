import SwiftUI


struct NeedsPermissionsView: View {
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
        Text("Butterfly")
          .font(.largeTitle)
      }
      VStack(alignment: .center, spacing: 12) {
        Text("Butterfly scans your library for albums to allow you to set dates and other metadata on photos that do not have them.")
        Text("To do this, Butterfly requires access to your entire Photos Library. No photos will leave your device.")
        Button("Open Settings", action: {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
      }
      .frame(width: 500)
      .multilineTextAlignment(.center)
      Spacer()
    }
  }
}

struct NeedsPermissionsView_Preview: PreviewProvider {
  static var previews: some View {
    NeedsPermissionsView()
      .previewLayout(.device)
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
