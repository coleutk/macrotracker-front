import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var wrongUsername = 0
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    @State private var showingHomeScreen = false
    @State private var errorMessage = ""
    @State private var isPasswordVisible = false
    
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
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 1.3)
                        
                        Circle()
                            .scale(1.35)
                            .foregroundColor(Color(red: 67/255, green: 67/255, blue: 75/255))
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 1.3)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Create")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.40))
                        .bold()
                    Text("Account")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.40))
                        .bold()
                        .padding(.bottom, 15)
                    
                    // Username Field
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        ZStack(alignment: .leading) {
                            if username.isEmpty {
                                Text("Username")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            TextField("", text: $username)
                                .foregroundColor(.white.opacity(0.90))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongUsername))
                    
                    // Email Field
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        ZStack(alignment: .leading) {
                            if email.isEmpty {
                                Text("E-Mail")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            TextField("", text: $email)
                                .foregroundColor(.white.opacity(0.90))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongEmail))
                    
                    // Password Field
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        ZStack(alignment: .leading) {
                            if password.isEmpty {
                                Text("Password")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            
                            if isPasswordVisible {
                                TextField("", text: $password)
                                    .foregroundColor(.white.opacity(0.90))
                            } else {
                                SecureField("", text: $password)
                                    .foregroundColor(.white.opacity(0.90))
                            }
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color.white.opacity(0.30))
                                .padding(.trailing, 8)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongPassword))
                    
                    // Confirm Password Field
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(.leading, 10)
                            .foregroundColor(Color.white.opacity(0.10))
                        
                        ZStack(alignment: .leading) {
                            if confirmPassword.isEmpty {
                                Text("Confirm Password")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            
                            if isPasswordVisible {
                                TextField("", text: $confirmPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            } else {
                                SecureField("", text: $confirmPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            }
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color.white.opacity(0.30))
                                .padding(.trailing, 8)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                    .background(Color.black.opacity(0.30))
                    .cornerRadius(15)
                    .border(Color.red, width: CGFloat(wrongPassword))
                    
                    // Sign Up Button
                    Button(action: {
                        registerUser(username: username, email: email, password: password)
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white.opacity(0.70))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(.white.opacity(0.04))
                            .cornerRadius(15)
                            .bold()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                    .padding(.top, 15)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .frame(width: UIScreen.main.bounds.width * 0.76, height: UIScreen.main.bounds.width * 0.13)
                            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                    }
                }
                .padding(.bottom, 100)
                .navigationDestination(isPresented: $showingHomeScreen) {
                    HomeView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func registerUser(username: String, email: String, password: String) {
        if !username.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty {
            if password != confirmPassword {
                wrongPassword = 1
                errorMessage = "Passwords do not match"
                return
            }
            
            userSignUp(username: username, email: email, password: password) { success, message in
                if success {
                    userLogin(email: email, password: password) { success, message in
                        if success {
                            DispatchQueue.main.async {
                                showingHomeScreen = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                wrongEmail = 1
                                wrongPassword = 1
                                errorMessage = message ?? "Invalid email or password"
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        showingHomeScreen = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = message ?? "Unknown error"
                    }
                }
            }
        } else {
            wrongUsername = username.isEmpty ? 1 : 0
            wrongEmail = email.isEmpty ? 1 : 0
            wrongPassword = password.isEmpty ? 1 : 0
            errorMessage = "Please fill in all fields"
        }
    }
}

struct SignUpView_Preview: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
