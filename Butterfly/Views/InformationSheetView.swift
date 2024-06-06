import SwiftUI


struct AppIconView: View {
  var body: some View {
      Image(uiImage: Bundle.main.icon ?? UIImage())
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 7, x: 3, y: 3)
  }
}

struct HelpTextView: View {
  var dismiss: DismissAction?
  var noPermissions: Bool = false
  var requestAuth: (() -> Void)?
  
  var body: some View {
    VStack() {
      Spacer()
      HStack() {
        VStack(spacing: 5) {
          AppIconView()
            .padding(.bottom)
          Text("Butterfly")
            .bold()
          Text("Old albums made new again.")
        }
      }
      Spacer()
      HStack(spacing: 20) {
        VStack(spacing: 5) {
          Image(systemName: "square.grid.2x2")
          Text("Sort Photos")
            .bold()
          Text("Adjust the order of your photos by dragging them.")
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(10)
        VStack(spacing: 5) {
          Image(systemName: "calendar.badge.plus")
          Text("Set a Date...")
            .bold()
          Text("Tap a photo to give it an accurate or approximate date.")
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(10)
        VStack(spacing: 5) {
          Image(systemName: "calendar.badge.plus")
          Text("...And Set Another")
            .bold()
          Text("Tap a second photo to set its date. Then watch...")
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(10)
      }
      .multilineTextAlignment(.center)
      .frame(maxWidth: 700)
      Spacer()
      
      VStack(alignment: .center) {
        if noPermissions {
          Text("Photos between these two will have their dates magically calculated. **Butterfly needs access to your entire library to work.**")
        } else {
          Text("**Photos between these two will have their dates magically calculated.** Repeating this process will organise an album in just minutes. If your photos are not digital, scan them into your Photos Library and Butterfly will do the rest.")
        }
      }
      .multilineTextAlignment(.center)
      Spacer()
      Button(
        action: {
          if noPermissions {
            if requestAuth == nil {
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else {
              requestAuth!()
            }
          } else {
            dismiss!()
          }
        }) {
          if noPermissions {
            Text(requestAuth == nil ? "Go to Settings" : "Request Photo Access")
              .padding([.leading, .trailing], 70)
              .padding([.top, .bottom], 5)
          } else {
            Text("Okay, Got It")
              .padding([.leading, .trailing], 70)
              .padding([.top, .bottom], 5)
          }
      }
      .buttonStyle(.borderedProminent)
      Spacer()
    }
    .frame(maxWidth: 700)
  }
}

struct InformationSheetView: View {
  @Environment(\.dismiss) var dismiss
  var resetDates: () -> Void
  
  var body: some View {
    VStack {
      HStack {
        Button("Reset Original Dates For Album", role: .destructive) {
          resetDates()
          dismiss()
        }
        Spacer()
      }
      .padding()
      HelpTextView(dismiss: dismiss)
        .padding([.bottom, .leading, .trailing], 50)
    }
  }
}

func resetDates() {
  print("view reset")
}

struct InformationSheetView_Preview: PreviewProvider {
  static var previews: some View {
    InformationSheetView(resetDates: resetDates)
      .previewLayout(.device)
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
