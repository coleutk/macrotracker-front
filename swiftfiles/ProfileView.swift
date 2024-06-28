//
//  ProfileView.swift
//  macrotracker
//
//  Created by Cole Price on 6/3/24.
//

import SwiftUI

// Implement apiInterfaceUser so that you can pull the current Goal from /:userId

struct ProfileView: View {
    var username: String
    @State private var selectedGoal: SelectedGoal? = nil
    @State private var errorMessage: String? = nil

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
}

#Preview {
    ProfileView(username: "cratik") // Hardcoded temp
}
