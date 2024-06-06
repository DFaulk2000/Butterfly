import SwiftUI
import Photos

struct MainView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @StateObject var libraryCoordinator = LibraryCoordinator()
  @FetchRequest(
    entity: ButterflyAsset.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \ButterflyAsset.assetId, ascending: true)]
  ) var butterflyAssets: FetchedResults<ButterflyAsset>
  
  
  var body: some View {
    if libraryCoordinator.isPhotoLibraryAuthorized == nil {
      VStack {
        AppIconView()
          .padding()
        Text("Loading...")
          .bold()
      }
    } else {
      if libraryCoordinator.isPhotoLibraryAuthorized! {
        SidebarNavView()
          .onAppear() {
            ImageFunctions.removeDuplicates(butterflyAssets: butterflyAssets, managedObjectContext: managedObjectContext)
          }
          .environmentObject(libraryCoordinator)
      } else {
        HelpTextView(dismiss: nil, noPermissions: true)
      }
    }
  }
}
