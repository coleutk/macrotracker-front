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
    
    // For Editing Goal
    @State private var goalName = ""
    @State private var goalCalories = ""
    @State private var goalProtein = ""
    @State private var goalCarbs = ""
    @State private var goalFats = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 53/255)
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        ForEach(goals.indices, id: \.self) { index in
                            let goal = goals[index]
                            NavigationLink(destination: EditGoalView(goalName: $goalName, goalCalories: $goalCalories, goalProtein: $goalProtein, goalCarbs: $goalCarbs, goalFats: $goalFats, goals: $goals, goalIndex: index)
                                           
                                .onAppear {
                                    goalName = goal.name
                                    goalCalories = goal.calories
                                    goalProtein = goal.protein
                                    goalCarbs = goal.carbs
                                    goalFats = goal.fats
                                }
                            ) {
                                Text(goal.name)
                                    .foregroundColor(.white.opacity(0.70))
                            }
                        }
                        .listRowBackground(Color(red: 20/255, green: 20/255, blue: 30/255))
                        
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(red: 44/255, green: 44/255, blue: 53/255))
                    .foregroundColor(.white)
                    
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
                    AddGoalSheet(goalName: $newGoalName, goalCalories: $newGoalCalories, goalProtein: $newGoalProtein, goalCarbs: $newGoalCarbs, goalFats: $newGoalFats, isSheetPresented: $isAddGoalSheetPresented, goals: $goals)
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
}

struct Goal: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let calories: String
    let protein: String
    let carbs: String
    let fats: String
}

struct EditGoalView: View {
    @Binding var goalName: String
    @Binding var goalCalories: String
    @Binding var goalProtein: String
    @Binding var goalCarbs: String
    @Binding var goalFats: String
    @Binding var goals: [Goal] // Add this line
    let goalIndex: Int // Add this line
    
    // Initialize the text fields with default values
    init(goalName: Binding<String>, goalCalories: Binding<String>, goalProtein: Binding<String>, goalCarbs: Binding<String>, goalFats: Binding<String>, goals: Binding<[Goal]>, goalIndex: Int) {
        _goalName = goalName
        _goalCalories = goalCalories
        _goalProtein = goalProtein
        _goalCarbs = goalCarbs
        _goalFats = goalFats
        _goals = goals
        self.goalIndex = goalIndex
    }
    
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @State private var showAlert = false // State variable to control alert presentation
    
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
                
                TextField("Fats", text: $goalFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                // Save Changes Button
                Button(action: {
                    // Save changes
                    // For example:
                    saveChanges()
                    
                    // Dismiss the view and go back to inventory
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
                    // Save changes
                    // For example:
                    deleteItem()
                    
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
            }
            .foregroundColor(.white.opacity(0.70))
            .padding(.bottom, 50)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Changes Saved"), message: Text("Your changes have been saved."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveChanges() {
        // Update the food item in the foods array with the edited values
        let editedGoal = Goal(name: goalName, calories: goalCalories, protein: goalProtein, carbs: goalCarbs, fats: goalFats)
        goals[goalIndex] = editedGoal
        
        // Print a message to indicate that changes are saved
        print("Changes saved!")
        
        // Display an alert
        showAlert = true
    }
    
    func deleteItem() {
        // Remove the current food item from the list using the index
        goals.remove(at: goalIndex)

        // Implement logic to delete the item
        // For example:
        print("Goal deleted!") // for Xcode console

        // Display an alert or perform any other actions as needed
        showAlert = true
    }
}


struct AddGoalSheet: View {
    @Binding var goalName: String
    @Binding var goalCalories: String
    @Binding var goalProtein: String
    @Binding var goalCarbs: String
    @Binding var goalFats: String
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
                
                TextField("Fats", text: $goalFats)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.20))
                    .cornerRadius(15)
                    .padding(.horizontal, 22)
                
                Button(action: {
                    let newGoal = Goal(name: goalName, calories: goalCalories, protein: goalProtein, carbs: goalCarbs, fats: goalFats)
                    goals.append(newGoal)
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
