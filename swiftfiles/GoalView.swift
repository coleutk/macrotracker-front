import SwiftUI

struct GoalView: View {
    @State private var isAddGoalSheetPresented = false
    
    // For Goal Add Sheet
    @State private var newGoalName = ""
    @State private var newGoalCalories = ""
    @State private var newGoalProtein = ""
    @State private var newGoalCarbs = ""
    @State private var newGoalFats = ""
    
    @State private var goals: [Goal] = []
    @State private var selectedGoalId: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        ForEach(goals, id: \.id) { goal in
                            NavigationLink(destination: EditGoalView(
                                goal: bindingGoal(for: goal),
                                selectedGoalId: selectedGoalId,
                                onSave: {
                                    loadGoals()
                                },
                                onDelete: {
                                    loadGoals()
                                }
                            )) {
                                Text(goal.name)
                                    .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                                    .foregroundColor(.white.opacity(0.70))
                            }
                        }
                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .foregroundColor(.white)
                    .onAppear {
                        loadGoals()
                    }
                    
                    Button(action: {
                        resetAddGoalFields()
                        isAddGoalSheetPresented.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10) // Rounded rectangle background
                                .foregroundColor(Color(red: 44/255, green: 44/255, blue: 53/255)) // Background color
                                .frame(width: 100, height: 55)
                            
                            VStack {
                                Image(systemName: "scope")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                Text("Add Goal")
                                    .padding(.top, -5)
                                    .font(.system(size: 15))
                                    .bold()
                            }
                            .foregroundColor(.white.opacity(0.50))
                        }
                    }
                    .buttonStyle(MyButtonStyle())
                }
                .sheet(isPresented: $isAddGoalSheetPresented) {
                    AddGoalSheet(goalName: $newGoalName, goalCalories: $newGoalCalories, goalProtein: $newGoalProtein, goalCarbs: $newGoalCarbs, goalFat: $newGoalFats, isSheetPresented: $isAddGoalSheetPresented, goals: $goals)
                        .onDisappear {
                            loadGoals()
                        }
                }
                .background(Color(red: 20/255, green: 20/255, blue: 30/255))
            }
            .navigationTitle("Goals")
        }
    }
    
    struct MyButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(5)
                .foregroundColor(.white.opacity(0.70))
        }
    }
    
    private func resetAddGoalFields() {
        newGoalName = ""
        newGoalCalories = ""
        newGoalProtein = ""
        newGoalCarbs = ""
        newGoalFats = ""
    }
    
    private func loadGoals() {
        print("loadGoals called")
        getAllGoals { result in
            switch result {
            case .success(let goals):
                print("Goals loaded: \(goals)") // Debug print
                self.goals = goals
                // Fetch the selected goal's ID
                getUserSelectedGoal { result in
                    switch result {
                    case .success(let selectedGoal):
                        self.selectedGoalId = selectedGoal.id
                    case .failure(let error):
                        print("Failed to load selected goal: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Failed to load goals: \(error.localizedDescription)")
            }
        }
    }
    
    private func bindingGoal(for goal: Goal) -> Binding<Goal> {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else {
            fatalError("Goal not found")
        }
        return $goals[index]
    }
}


struct EditGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Saving Goal Details
    @State private var showAlert = false
    @State private var alertMessage = "Changes saved!"
    
    @Binding var goal: Goal
    var selectedGoalId: String?
    var onSave: (() -> Void)?
    var onDelete: (() -> Void)? // Callback for deletion
    
    @State var goalName: String
    @State var goalCalories: String
    @State var goalProtein: String
    @State var goalCarbs: String
    @State var goalFat: String
    
    // Initialize the text fields with default values
    init(goal: Binding<Goal>, selectedGoalId: String?, onSave: (() -> Void)?, onDelete: (() -> Void)?) {
        _goal = goal
        self.selectedGoalId = selectedGoalId
        self.onDelete = onDelete
        
        _goalName = State(initialValue: goal.wrappedValue.name)
        _goalCalories = State(initialValue: String(goal.wrappedValue.calorieGoal))
        _goalProtein = State(initialValue: String(goal.wrappedValue.proteinGoal))
        _goalCarbs = State(initialValue: String(goal.wrappedValue.carbGoal))
        _goalFat = State(initialValue: String(goal.wrappedValue.fatGoal))
    }
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            VStack {
                Text("Edit Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Goal Name", text: $goalName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $goalCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Protein", text: $goalProtein)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Carbs", text: $goalCarbs)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Fats", text: $goalFat)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                // Save Changes Button
                Button(action: {
                    // Save changes here
                    goal.name = goalName
                    goal.calorieGoal = Int(goalCalories) ?? goal.calorieGoal
                    goal.proteinGoal = Int(goalProtein) ?? goal.proteinGoal
                    goal.carbGoal = Int(goalCarbs) ?? goal.carbGoal
                    goal.fatGoal = Int(goalFat) ?? goal.fatGoal
                    
                    // Call the editFood function
                    editGoal(goal) { result in
                        switch result {
                        case .success(let updatedGoal):
                            onSave?()
                            print("Changes saved: \(updatedGoal)")
                            alertMessage = "Changes saved!"
                            showAlert = true
                            goal = updatedGoal // Update the food with the returned updatedFood
                        case .failure(let error):
                            print("Failed to save changes: \(error)")
                            alertMessage = "Failed to save changes: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    
                    presentationMode.wrappedValue.dismiss()
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
                
                // Delete Item Button
                Button(action: {
                    // Handle deletion here
                    deleteGoal(goal) { result in
                        switch result {
                        case .success:
                            onDelete?() // Call the onDelete callback
                            print("Goal deleted!")
                            alertMessage = "Goal deleted!"
                            showAlert = true
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print("Failed to delete goal: \(error)")
                            alertMessage = "Failed to delete goal: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    // Dismiss the view and go back to inventory
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Delete \(goalName)")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
                
                // Make Goal = Selected
                if goal.id != selectedGoalId {
                    Button(action: {
                        makeNewSelectedGoal(
                            goalId: goal.id,
                            name: goal.name,
                            calorieGoal: goal.calorieGoal,
                            proteinGoal: goal.proteinGoal,
                            carbGoal: goal.carbGoal,
                            fatGoal: goal.fatGoal
                        ) { success, message in
                            if success {
                                print("Selected goal updated successfully")
                            } else {
                                print("Failed to update selected goal: \(message ?? "Unknown error")")
                            }
                        }
                        // Dismiss the view and go back to inventory
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Switch \(goalName) to Current")
                            .foregroundColor(.white.opacity(0.70))
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.50))
                            .cornerRadius(15)
                            .padding(.horizontal, 22)
                            .padding(.top, 20)
                    }
                }
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.bottom, 50)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Changes Saved"), message: Text("Your changes have been saved."), dismissButton: .default(Text("OK")))
            }
        }
    }
}


struct AddGoalSheet: View {
    @Binding var goalName: String
    @Binding var goalCalories: String
    @Binding var goalProtein: String
    @Binding var goalCarbs: String
    @Binding var goalFat: String
    @Binding var isSheetPresented: Bool
    @Binding var goals: [Goal]
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Goal Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                TextField("Goal Name", text: $goalName)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                TextField("Calories", text: $goalCalories)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                HStack {
                    TextField("Protein", text: $goalProtein)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                HStack {
                    TextField("Carbs", text: $goalCarbs)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                HStack {
                    TextField("Fat", text: $goalFat)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 90)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                
                Button(action: {
                    guard let goalCalories = Int(goalCalories),
                          let goalProtein = Int(goalProtein),
                          let goalCarbs = Int(goalCarbs),
                          let goalFat = Int(goalFat) else {
                        print("Invalid input")
                        return
                    }
                    
                    addGoal(name: goalName, calorieGoal: goalCalories, proteinGoal: goalProtein, carbGoal: goalCarbs, fatGoal: goalFat) { success, message in
                        if success {
                            print("Goal created successfully")
                        } else {
                            print("Failed to create goal: \(message ?? "Unknown error")")
                        }
                    }

                    
                    isSheetPresented = false
                }) {
                    Text("Add Goal")
                        .foregroundColor(.white.opacity(0.70))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.50))
                        .cornerRadius(15)
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                }
            }
            .foregroundColor(.white.opacity(0.70))
        }
    }
}


struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView()
    }
}
