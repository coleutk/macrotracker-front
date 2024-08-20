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
                        self.selectedGoalId = selectedGoal?.id
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
    
    @State private var showValidationError = false
    
    @Binding var goal: Goal
    var selectedGoalId: String?
    var onSave: (() -> Void)?
    var onDelete: (() -> Void)? // Callback for deletion
    
    @State var goalName: String
    @State var goalCalories: String
    @State var goalProtein: String
    @State var goalCarbs: String
    @State var goalFat: String
    
    @State private var addingCarbs: String = ""
    @State private var addingFat: String = ""
    
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
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $goalName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalName.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $goalCalories)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalCalories.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $goalProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalProtein.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    if goalCarbs == "0" {
                        TextField("Enter Amount...", text: $addingCarbs)
                            .padding(14)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.20))
                            .cornerRadius(15)
                            .padding(.trailing, 22)
                            .padding(.leading, -10)
                    } else {
                        TextField("Enter Amount...", text: $goalCarbs)
                            .padding(14)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.20))
                            .cornerRadius(15)
                            .padding(.trailing, 22)
                            .padding(.leading, -10)
                    }
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    if goalFat == "0" {
                        TextField("Enter Amount...", text: $addingFat)
                            .padding(14)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.20))
                            .cornerRadius(15)
                            .padding(.trailing, 22)
                            .padding(.leading, -10)
                    } else {
                        TextField("Enter Amount...", text: $goalFat)
                            .padding(14)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.20))
                            .cornerRadius(15)
                            .padding(.trailing, 22)
                            .padding(.leading, -10)
                    }
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                // Save Changes Button
                Button(action: {
                    if goalName.isEmpty || goalCalories.isEmpty || goalProtein.isEmpty {
                        showValidationError = true
                    } else {
                        showValidationError = false
                        // Save changes here
                        goal.name = goalName
                        goal.calorieGoal = Int(goalCalories) ?? goal.calorieGoal
                        goal.proteinGoal = Int(goalProtein) ?? goal.proteinGoal
                        
                        // Update carb and fat goals if changed
                        if goalCarbs.isEmpty || goalCarbs == "0" {
                            goal.carbGoal = Int(addingCarbs) ?? 0
                        } else {
                            goal.carbGoal = Int(goalCarbs) ?? goal.carbGoal
                        }
                        
                        if goalFat.isEmpty || goalFat == "0" {
                            goal.fatGoal = Int(addingFat) ?? 0
                        } else {
                            goal.fatGoal = Int(goalFat) ?? goal.fatGoal
                        }
                        
                        // Call the editGoal function
                        editGoal(goal) { result in
                            switch result {
                            case .success(let updatedGoal):
                                onSave?()
                                print("Changes saved: \(updatedGoal)")
                                alertMessage = "Changes saved!"
                                showAlert = true
                                goal = updatedGoal // Update the goal with the returned updatedGoal
                            case .failure(let error):
                                print("Failed to save changes: \(error)")
                                alertMessage = "Failed to save changes: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
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
                    deleteGoal(goal, selectedGoalId: selectedGoalId) { result in
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
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var showValidationError = false
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            VStack {
                Text("Goal Details:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white.opacity(0.70))
                
                HStack {
                    MacroDisplayVertical(nutrient: "Name", color: Color(.white))
                    
                    TextField("Type Here...", text: $goalName)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalName.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Cals", color: Color(red: 10/255, green: 211/255, blue: 255/255))
                    
                    TextField("Enter Amount...", text: $goalCalories)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalCalories.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Protein", color: Color(red: 46/255, green: 94/255, blue: 170/255))
                    
                    TextField("Enter Amount...", text: $goalProtein)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(showValidationError && goalProtein.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                                .opacity(0.60)
                        )
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Carbs", color: Color(red: 120/255, green: 255/255, blue: 214/255))
                    
                    TextField("Enter Amount...", text: $goalCarbs)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                HStack {
                    MacroDisplayVertical(nutrient: "Fat", color: Color(red: 171/255, green: 169/255, blue: 195/255))
                    
                    TextField("Enter Amount...", text: $goalFat)
                        .padding(14)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.trailing, 22)
                        .padding(.leading, -10)
                    
                    Text("g")
                        .padding(14)
                        .frame(width: 80, height: 60)
                        .background(Color.black.opacity(0.20))
                        .cornerRadius(15)
                        .padding(.leading, -20)
                        .padding(.trailing, 22)
                        .foregroundColor(.white.opacity(0.50))
                }
                .padding(3)
                
                Button(action: {
                    if goalName.isEmpty || goalCalories.isEmpty || goalProtein.isEmpty {
                        showValidationError = true
                    } else {
                        showValidationError = false
                        
                        guard let goalCalories = Int(goalCalories),
                              let goalProtein = Int(goalProtein) else {
                            print("Invalid input")
                            return
                        }
                        
                        let goalCarbsOpt = Int(goalCarbs)
                        let goalFatOpt = Int(goalFat)
                        
                        addGoal(name: goalName, calorieGoal: goalCalories, proteinGoal: goalProtein, carbGoal: goalCarbsOpt ?? 0, fatGoal: goalFatOpt ?? 0) { success, message in
                            if success {
                                print("Goal created successfully")
                            } else {
                                print("Failed to create goal: \(message ?? "Unknown error")")
                            }
                        }
                        
                        
                        isSheetPresented = false
                    }
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
