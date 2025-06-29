import SwiftUI

struct TopBarView: View {
    var viewModel: AuthenticationViewModel
    @Binding var aura: Int
    var onSignOut: () -> Void

    var body: some View {
        VStack {
            HStack {
                ProgressBarView(aura: $aura)

                Text(viewModel.userName ?? "")
                    .padding()

                AsyncImage(url: URL(string: viewModel.userImage ?? "")) { phase in
                    if case let .success(image) = phase {
                        image.resizable()
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(lineWidth: 5))
                    } else {
                        Image(systemName: "person.crop.circle.badge.exclam")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(lineWidth: 5))
                    }
                }

                Button(action: onSignOut) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            Spacer()
        }
    }
}
