//
//  ProfileView.swift
//  macrotracker
//
//  Created by Cole Price on 6/3/24.
//

import SwiftUI

struct ProfileView: View {
    var username: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .ignoresSafeArea()
                
                VStack {
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ProfileView(username: "cratik") // Hardcoded temp
}

