import SwiftUI
import Photos


struct SidebarNavView: View {
  @EnvironmentObject var libraryCoordinator: LibraryCoordinator
  @State private var searchQuery: String = ""
  
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom) {
        List {
          ForEach(
            libraryCoordinator.phAssetCollectionWrappers.filter {
              searchQuery.isEmpty ? true : $0.phAssetCollection.localizedTitle!.lowercased().contains(searchQuery.lowercased())
            },
            id: \.self
          ) { phAssetCollectionWrapper in
            NavigationLink(
              destination: {
                PhotoGridView(collectionWrapper: phAssetCollectionWrapper)
              },
              label: {
                SidebarItemView(collectionWrapper: phAssetCollectionWrapper)
                  .drawingGroup() // For performance, draw the stacks off screen to render the shadows once.
              }
            )
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.sidebar)
        .id(UUID()) // This is a hack to disable the stupid list collapse animations that were causing flickers when changing album type
        .navigationTitle("Albums")
        .searchable(
          text: $searchQuery,
          placement: .navigationBarDrawer(displayMode: .always),
          prompt: "Search albums"
        )
      }
    }
  }
}
