//
//  ProfileView.swift
//  macrotracker
//
//  Created by Cole Price on 6/3/24.
//

import SwiftUI

struct ProfileView: View {
    var username: String
    @State private var selectedGoal: SelectedGoal? = nil
    @State private var errorMessage: String? = nil
    @State private var showLogoutAlert = false
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()

                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 20/255, green: 20/255, blue: 30/255))
                            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                        
                        VStack {
                            if let goal = selectedGoal {
                                Text("Current Goal")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal, 60)
                                
                                Text(goal.name)
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.70))
                                    .padding(.bottom, 3)
                                    .padding(.horizontal, 20)
                            } else if let errorMessage = errorMessage {
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                            } else {
                                ProgressView("Loading...")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(red: 30/255, green: 30/255, blue: 40/255).opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    List {
                        NavigationLink (destination: GoalView()){
                            Text("Goals")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.70))
                        }
                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .padding(.vertical, 10)
                        
                        NavigationLink (destination: EditProfileView()){
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.70))
                        }
                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .padding(.vertical, 10)
                        
                        // Custom Logout Button with background NavigationLink
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red.opacity(0.70))
                        }
                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        .padding(.vertical, 10)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .navigationTitle("Profile")
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                fetchUserSelectedGoal()
            }
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        logout()
                        isLoggedOut = true
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $isLoggedOut) {
                WelcomeView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func fetchUserSelectedGoal() {
        getUserSelectedGoal { result in
            switch result {
            case .success(let goal):
                DispatchQueue.main.async {
                    self.selectedGoal = goal
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.synchronize()
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userDetails: UserDetails? = nil
    @State private var errorMessage: String? = nil
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var passwordErrorMessage: String? = nil
    @State private var alertMessage: String? = nil
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            VStack {
                Text("Edit Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                if userDetails != nil {
                    HStack {
                        MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                        
                        TextField("Enter Username...", text: $username)
                            .padding(14)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.20))
                            .cornerRadius(15)
                            .padding(.trailing, 22)
                            .padding(.leading, -10)
                    }
                    .padding(3)
                }
                
                HStack {
                    MacroDisplayVertical(nutrient: "E-Mail", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter E-Mail...", text: $email)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                Button(action: {
                    // Save changes here
                    updateUser()
                    
                    alertMessage = "Information updated successfully!"
                    showAlert = true
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                
                .padding(.bottom, 45)
                
                Text("Change Password:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Current", color: Color(.white))
                    
                    SecureField("Current Password", text: $currentPassword)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "New", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    SecureField("Current Password", text: $newPassword)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Confirm", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    SecureField("Current Password", text: $confirmPassword)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                
                Button(action: {
                    // Save changes here
                    updatePassword()
                    alertMessage = "Password updated successfully!"
                    showAlert = true
                    //presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                
                if let passwordErrorMessage = passwordErrorMessage {
                    Text(passwordErrorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.top, -90)
        }
        .onAppear {
            fetchUserDetails()
        }
        .alert(isPresented: $showAlert) { // Show confirmation alert
            Alert(
                title: Text(alertMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    // Dismiss the view if needed
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func fetchUserDetails() {
        getUserDetails { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userDetails):
                    self.userDetails = userDetails
                    self.username = userDetails.username
                    self.email = userDetails.email
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateUser() {
        updateUserDetails(username: username, email: email) { result in
            switch result {
            case .success:
                self.errorMessage = nil
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            
        }
    }
    
    func updatePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            passwordErrorMessage = "All password fields are required"
            return
        }
        
        guard newPassword == confirmPassword else {
            passwordErrorMessage = "New passwords do not match"
            return
        }
        
        passwordErrorMessage = nil
        
        updateUserPassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword) { result in
            switch result {
            case .success:
                //self.passwordErrorMessage = "Password updated successfully!"
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                self.passwordErrorMessage = error.localizedDescription
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: "cratik")
    }
}
