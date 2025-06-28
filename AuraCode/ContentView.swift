import SwiftUI
import SwiftUIX
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    @State var code = "a = 32"
    @AppStorage("aura") var aura = 23
    @AppStorage("searchText") var searchText: String = ""
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var showSignInView = true
    var viewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if showSignInView {
                    VStack(alignment: .center) {
                        Text("Aura Code")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        AsyncImage(url: URL(string: "https://preview.redd.it/how-super-saiyan-blue-should-have-been-introduced-v0-xjkbvb5ugp2b1.jpg?width=1080&crop=smart&auto=webp&s=538cccac6afe0a85f5ab75797c48560099bf375a")) { Image in
                            Image
                                .resizable()
                                .frame(maxWidth:300)
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .offset(x: -25)
                        
                        VStack {
                            
                            Text("Sign In")
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            VStack {
                                
                                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                                    Task {
                                        do {
                                            try await viewModel.signInGoogle()
                                            withAnimation(.smooth) {
                                                showSignInView = false
                                            }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                                .padding()
                                .padding(.horizontal)
                                .frame(width: geo.size.width/3)
                                
                                HStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                    
                                    Text("or")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 10)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                .padding(.horizontal)
                                .frame(width: geo.size.width/4)
                                
                                Button {
                                    viewModel.signInAsGuest()
                                    showSignInView = false
                                } label: {
                                    HStack {
                                        Image(systemName: "person.fill")
                                        Text("Continue as Guest")
                                    }
                                }
                                .padding()
                                .background(.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            
                        }
                    }
                    .frame(width: geo.size.width)
                    
                } else {
                    ZStack {
                        // homepage
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                
                                SectionView(title: "Continue Learning", subtitle: "Pick up where you left off") {
                                    NavigationLink {
                                        // code = past code
                                        LessonView(code: $code)
                                    } label: {
                                        HomeCard(title: "Functions & Loops", progress: 0.65, accentColor: .blue)
                                    }
                                }
                                
                                SectionView(title: "Daily Challenge", subtitle: "Boost your streak with today’s quick task") {
                                    NavigationLink {
                                        // code = ai code for daily challenge
                                        LessonView(code: $code)
                                    } label: {
                                        HomeCard(title: "Today's Puzzle", progress: nil, accentColor: .purple, hasFlare: true)
                                    }
                                }
                                
                                SectionView(title: "Branch Out", subtitle: "Try something new today") {
                                    VStack(spacing: 12) {
                                        NavigationLink {
                                            // code = ai code
                                            LessonView(code: $code)
                                        } label: {
                                            HomeCard(title: "Intro to JS", progress: nil, accentColor: .green)
                                        }
                                        NavigationLink {
                                            // code = ai code
                                            LessonView(code: $code)
                                        } label: {
                                            HomeCard(title: "AP CS Prep", progress: nil, accentColor: .orange)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 48)
                            .buttonStyle(.plain)
                            
                        }

                        VStack {
                            HStack {
                                ProgressBarView(aura: aura)
                                
                                Text(viewModel.userName ?? "")
                                    .padding()
                                
                                AsyncImage(url: URL(string: viewModel.userImage ?? "")) { phase in
                                    if case let .success(image) = phase {
                                        image
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: 40, height: 40)
                                            .overlay(Circle().stroke(lineWidth: 5))
                                    } else  {
                                        Image(systemName: "person.crop.circle.badge.exclam")
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: 40, height: 40)
                                            .overlay(Circle().stroke(lineWidth: 5))
                                    }
                                }
                                
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
                                        print("error with guest signout")
                                    }
                                } label: {
                                    Image(systemName:"rectangle.portrait.and.arrow.right")
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel.isGuestUser {
                do {
                    try AuthenticationManager.shared.signOut()
                    userEmail = nil
                    userName = nil
                    userImage = nil
                    userType = nil
                    uid = nil
                    showSignInView = true
                } catch {
                    print("error with guest signout")
                }
            } else if viewModel.userEmail != nil {
                showSignInView = false
            }
        }
    }
}
