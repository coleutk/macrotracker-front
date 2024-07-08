import SwiftUI

struct WelcomeView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingLoginScreen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 67/255, green: 67/255, blue: 75/255)
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255))
                Circle()
                    .scale(1.35)
                    .foregroundColor(Color(red: 20/255, green: 20/255, blue: 30/255))
                
                VStack (alignment: .leading){
                    Text("Welcome to MacroTracker!")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.20))
                        .bold()
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .foregroundColor(.white.opacity(0.70))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                            .cornerRadius(15)
                            .bold()
                    }
                    .frame(width: 300, height: 50)
                    .padding(.top, 5)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .foregroundColor(.white.opacity(0.70))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                            .cornerRadius(15)
                            .bold()
                    }
                    .frame(width: 300, height: 50)
                    .padding(.top, 5)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct WelcomeView_Preview: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
