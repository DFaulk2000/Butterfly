import SwiftUI

import Photos
import PhotosUI

import MapKit

class ViewModel: ObservableObject {
  @Published var coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020), latitudinalMeters: 1000, longitudinalMeters: 1000)
  @Published var mapPins: [AnnotationItem] = [AnnotationItem()]
}

struct AnnotationItem: Identifiable {
  var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
  let id = UUID()
}

struct PhotoMetadataView: View {
  var asset: PHAsset
  @State var region: MKCoordinateRegion = MKCoordinateRegion()
  @ObservedObject var viewModel: ViewModel
  
  init(asset: PHAsset, viewModel: ViewModel = ViewModel()) {
    self.asset = asset
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      VStack {
        ThumbnailView(asset: asset, size: ButterflyApp.targetThumbnailSize)
          .frame(
            width: ButterflyApp.targetThumbnailSize.width,
            height: ButterflyApp.targetThumbnailSize.height
          )
          .cornerRadius(ButterflyApp.thumbnailBorderRadius, antialiased: true)
          .shadow(radius: ButterflyApp.shadowRadius)
        Spacer()
      }
      .padding()
      VStack {
        List {
          if (asset.creationDate != nil) {
            Text("Created: \(ButterflyApp.dateFormatter.string(from: asset.creationDate!))")
          }
          
          if (asset.modificationDate != nil) {
            Text("Modified: \(ButterflyApp.dateFormatter.string(from: asset.modificationDate!))")
          }

          Text("Dimensions: \(asset.pixelWidth) x \(asset.pixelHeight)")
          Map(
            coordinateRegion: $viewModel.coordinateRegion,
            annotationItems: viewModel.mapPins,
            annotationContent: { item in
              MapPin(coordinate: item.coordinate)
            }
          )
          .frame(width: 400, height: 300)
        }
        .listStyle(InsetListStyle())
      }
    }.onAppear {
      if (asset.location != nil) {
        viewModel.coordinateRegion = MKCoordinateRegion(
          center: asset.location!.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        viewModel.mapPins = [AnnotationItem(coordinate: asset.location!.coordinate)]
      }
    }
    .padding()
  }
}
