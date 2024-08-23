//
//  ProfileView.swift
//  macrotracker
//
//  Created by Cole Price on 6/3/24.
//

import SwiftUI

struct ProfileView: View {
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
                            } else if selectedGoal == nil {
                                Text("[No goal selected]")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white.opacity(0.80))
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
                print("fetchUserSelectedGoal() called")
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
                if (error as NSError).code == 404 { // Assuming 404 is the error code for no goal found
                    DispatchQueue.main.async {
                        self.selectedGoal = nil // No goal found
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
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
    
    // Boolean variables for managing alerts
    @State private var showInfoUpdateAlert = false
    @State private var showPasswordUpdateAlert = false
    @State private var showDeleteAccountAlert = false
    
    @State private var showDeleteConfirmation = false
    @State private var isDeleted = false
    
    // State variables for toggling password visibility
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    // Track original values for comparison
    @State private var originalUsername: String = ""
    @State private var originalEmail: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            Spacer()
            
            VStack {
                Spacer()
                
                Text("Edit Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                if userDetails != nil {
                    HStack {
                        MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                        
                        ZStack(alignment: .leading) {
                            if username.isEmpty {
                                Text("Enter Username...")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            TextField("", text: $username)
                                .foregroundColor(.white.opacity(0.90))
                        }
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
                    
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text("Enter E-Mail...")
                                .foregroundColor(.white.opacity(0.35))
                        }
                        TextField("", text: $email)
                            .foregroundColor(.white.opacity(0.90))
                    }
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
                    updateUser()
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(width: UIScreen.main.bounds.width * 0.90, height: UIScreen.main.bounds.width * 0.10)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                }
                .alert(isPresented: $showInfoUpdateAlert) {
                    Alert(
                        title: Text(alertMessage ?? ""),
                        dismissButton: .default(Text("OK")) {
                            // Dismiss the view if needed
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
                
                Spacer()
                
                Text("Change Password:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Current", color: Color(.white))
                    
                    ZStack(alignment: .trailing) {
                        ZStack(alignment: .leading) {
                            if currentPassword.isEmpty {
                                Text("Current Password")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            
                            if isCurrentPasswordVisible {
                                TextField("", text: $currentPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            } else {
                                SecureField("", text: $currentPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            }
                        }
                        
                        Button(action: {
                            isCurrentPasswordVisible.toggle()
                        }) {
                            Image(systemName: isCurrentPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color.white.opacity(0.30))
                                .padding(.trailing, 8)
                        }
                    }
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
                    
                    ZStack(alignment: .trailing) {
                        ZStack(alignment: .leading) {
                            if newPassword.isEmpty {
                                Text("New Password")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            
                            if isNewPasswordVisible {
                                TextField("", text: $newPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            } else {
                                SecureField("", text: $newPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            }
                        }
                        
                        Button(action: {
                            isNewPasswordVisible.toggle()
                        }) {
                            Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color.white.opacity(0.30))
                                .padding(.trailing, 8)
                        }
                    }
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
                    
                    ZStack(alignment: .trailing) {
                        ZStack(alignment: .leading) {
                            if confirmPassword.isEmpty {
                                Text("Confirm Password")
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            
                            if isConfirmPasswordVisible {
                                TextField("", text: $confirmPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            } else {
                                SecureField("", text: $confirmPassword)
                                    .foregroundColor(.white.opacity(0.90))
                            }
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(Color.white.opacity(0.30))
                                .padding(.trailing, 8)
                        }
                    }
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
                    updatePassword()
                }) {
                    Text("Confirm Changes")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(width: UIScreen.main.bounds.width * 0.90, height: UIScreen.main.bounds.width * 0.10)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                }
                .alert(isPresented: $showPasswordUpdateAlert) {
                    Alert(
                        title: Text(passwordErrorMessage ?? "Password updated successfully!"),
                        dismissButton: .default(Text("OK")) {
                            if passwordErrorMessage == nil {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
                
                Button(action: {
                    alertMessage = "Account Deleted Successfully!"
                    showDeleteAccountAlert = true
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(width: UIScreen.main.bounds.width * 0.90, height: UIScreen.main.bounds.width * 0.10)
                        .background(Color.red.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                }
                .alert(isPresented: $showDeleteAccountAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                            logout()
                            isDeleted = true
                            showDeleteAccountAlert = false
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Spacer()
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.top, -90)
        }
        .onAppear {
            fetchUserDetails()
        }
        .navigationDestination(isPresented: $isDeleted) {
            WelcomeView()
        }
    }
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.synchronize()
    }
    
    private func deleteAccount() {
        deleteUserAccount { success, error in
            DispatchQueue.main.async {
                if success {
                    UserDefaults.standard.removeObject(forKey: "token")
                    UserDefaults.standard.synchronize()
                    alertMessage = "Account deleted successfully!"
                    showDeleteAccountAlert = true
                } else {
                    alertMessage = error ?? "Failed to delete account."
                    showDeleteAccountAlert = true
                }
            }
        }
    }
    
    private func fetchUserDetails() {
        getUserDetails { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userDetails):
                    self.userDetails = userDetails
                    self.originalUsername = userDetails.username
                    self.originalEmail = userDetails.email
                    self.username = userDetails.username
                    self.email = userDetails.email
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateUser() {
        guard username != originalUsername || email != originalEmail else {
            alertMessage = "Nothing was changed"
            showInfoUpdateAlert = true
            return
        }
        
        updateUserDetails(username: username, email: email) { result in
            switch result {
            case .success:
                self.errorMessage = nil
                self.alertMessage = "Information updated successfully!"
                self.showInfoUpdateAlert = true
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.alertMessage = error.localizedDescription
                self.showInfoUpdateAlert = true
            }
        }
    }
    
    private func updatePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            passwordErrorMessage = "All password fields are required"
            showPasswordUpdateAlert = true
            return
        }
        
        guard newPassword.count >= 6 else {
            passwordErrorMessage = "New password must be at least 6 characters long"
            showPasswordUpdateAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            passwordErrorMessage = "New passwords do not match"
            showPasswordUpdateAlert = true
            return
        }
        
        passwordErrorMessage = nil
        
        updateUserPassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword) { result in
            switch result {
            case .success:
                showPasswordUpdateAlert = true
                passwordErrorMessage = nil
            case .failure(let error):
                self.passwordErrorMessage = error.localizedDescription
                showPasswordUpdateAlert = true
            }
        }
    }
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
