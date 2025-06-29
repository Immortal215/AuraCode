import SwiftUI

struct WelcomeHeader: View {
    var viewModel: AuthenticationViewModel
    @AppStorage("aura") var aura = 0
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 8) {
                
                VStack {
                    AsyncImage(url: URL(string: viewModel.getCurrentUser()?.photoURL?.absoluteString ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    
                    Button {
                        do {
                            try AuthenticationManager.shared.signOut()
                            userEmail = nil
                            userName = nil
                            userImage = nil
                            userType = nil
                            uid = nil
                            showSignInView = true
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                
                VStack {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.getCurrentUser()?.displayName ?? "User")!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 111/255, green: 80/255, blue: 247/255))
                    
                    Text("Check out a class page to see your progress and find helpful resources.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(24)
            .background(.systemGray4)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.05), radius: 8, x: 0, y: 2)
            
            Spacer()
            AuraCounterView(aura: $aura)
                .frame(width: 300, height: 200)
                .padding(.horizontal, 16)
           
        }
        
    }
}
