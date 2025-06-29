import SwiftUI

struct WelcomeHeader: View {
    var viewModel: AuthenticationViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back,")
                    .font(.title2)
                    .foregroundColor(.black)

                Text("\(viewModel.getCurrentUser()?.displayName ?? "User")!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 111/255, green: 80/255, blue: 247/255))

                Text("Check out a class page to see your progress and find helpful resources.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                // Profile action
            }) {
                AsyncImage(url: URL(string: viewModel.getCurrentUser()?.photoURL?.absoluteString ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
