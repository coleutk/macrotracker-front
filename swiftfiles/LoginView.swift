import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingHomeScreen = false
    
    @StateObject private var inventoryViewModel = InventoryViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 20/255, green: 20/255, blue: 30/255)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .scale(1.7)
                            .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2)
                        
                        Circle()
                            .scale(1.35)
                            .foregroundColor(Color(red: 67/255, green: 67/255, blue: 75/255))
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 1.2)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.20))
                        .bold()
                    Text("Back!")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.20))
                        .bold()
                        .padding(.bottom, 15)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        TextField("E-Mail", text: $username)
                            .foregroundColor(.white.opacity(0.90))
                            .padding(.leading, 1)
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongUsername))
                    
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        SecureField("Password", text: $password)
                            .foregroundColor(.white.opacity(0.90))
                            .padding(.leading, 1)
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongPassword))
                    
                    Button(action: {
                        authenticateUser(username: username, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white.opacity(0.70))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(.white.opacity(0.04))
                            .cornerRadius(15)
                            .bold()
                    }
                    .frame(width: 300, height: 50)
                    .padding(.top, 15)
                }
                .padding(.bottom, 100)
                .navigationDestination(isPresented: $showingHomeScreen) {
                    HomeView(username: username)
                        .environmentObject(inventoryViewModel) // So I can see saved data across tabs
                        .onAppear {
                            //inventoryViewModel.loadInventory()
                        }
                }

            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func authenticateUser(username: String, password: String) {
        if username.lowercased() == "cratik" {
            wrongUsername = 0
            if password.lowercased() == "soccer1119" {
                wrongPassword = 0
                showingHomeScreen = true
            } else {
                wrongPassword = 1
            }
        } else {
            wrongUsername = 1
        }
    }
}

struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
