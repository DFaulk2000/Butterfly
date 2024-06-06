import SwiftUI


struct CoreDataDebugView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest(
    entity: ButterflyAsset.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \ButterflyAsset.assetId, ascending: true)]
  ) var butterflyAssets: FetchedResults<ButterflyAsset>
  
  var body: some View {
    ScrollView {
      ForEach(butterflyAssets, id: \.self) { asset in
        VStack(alignment: .leading) {
          Text("Asset ID: \(asset.assetId!)")
          Text("Object ID: \(asset.objectID)")
          Text("Locked: \(asset.locked ? "True" : "False")")
          Text("Original Date: \(ButterflyApp.dateFormatter.string(from: asset.originalDate!))")
          Text("Butterfly Date: \(ButterflyApp.dateFormatter.string(from: asset.butterflyDate!))")
        }
        .padding()
      }
    }
    .font(.subheadline)
    .toolbar {
      ToolbarItem {
        Button("Delete all data", role: .destructive) {
          ButterflyApp.dropDatabase()
        }
      }
    }
  }
}
