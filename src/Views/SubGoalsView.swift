import SwiftUI

struct SubGoalsView: View {
    @Binding var subGoals: [SubGoal]
    let colorScheme: ColorScheme
    @State private var newGoalText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Sub-Goals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(completedGoalsCount)/\(subGoals.count)")
                    .font(.caption2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(progressBackgroundColor)
                    .cornerRadius(4)
            }
            
            // Goals list in a scrollable container
            VStack(alignment: .leading, spacing: 4) {
                if subGoals.isEmpty {
                    Text("No sub-goals yet. Add one below!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.vertical, 4)
                } else {
                    // Limit height and make scrollable if needed
                    ForEach(subGoals) { goal in
                        SubGoalRowView(
                            goal: goal,
                            colorScheme: colorScheme,
                            onToggle: { toggleGoal(goal) },
                            onDelete: { deleteGoal(goal) }
                        )
                    }
                }
            }
            .frame(maxHeight: 120) // Limit height to prevent popover overflow
            
            // Add new goal input
            HStack(spacing: 8) {
                TextField("Add sub-goal...", text: $newGoalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        addGoal()
                    }
                
                Button(action: addGoal) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(colorScheme == .dark ? .blue.opacity(0.8) : .accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newGoalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private var completedGoalsCount: Int {
        subGoals.filter { $0.isCompleted }.count
    }
    
    private var progressBackgroundColor: Color {
        if completedGoalsCount == subGoals.count && subGoals.count > 0 {
            return colorScheme == .dark ? .green.opacity(0.3) : .green.opacity(0.2)
        } else {
            return colorScheme == .dark ? .white.opacity(0.2) : .secondary.opacity(0.1)
        }
    }
    
    private func addGoal() {
        let trimmedText = newGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        subGoals.append(SubGoal(text: trimmedText))
        newGoalText = ""
    }
    
    private func toggleGoal(_ goal: SubGoal) {
        if let index = subGoals.firstIndex(where: { $0.id == goal.id }) {
            subGoals[index].isCompleted.toggle()
        }
    }
    
    private func deleteGoal(_ goal: SubGoal) {
        subGoals.removeAll { $0.id == goal.id }
    }
}

struct SubGoalRowView: View {
    let goal: SubGoal
    let colorScheme: ColorScheme
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: goal.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(goal.isCompleted ? 
                        (colorScheme == .dark ? .green.opacity(0.8) : .accentColor) : 
                        .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(goal.text)
                .font(.system(size: 13))
                .strikethrough(goal.isCompleted, color: .secondary)
                .foregroundColor(goal.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(colorScheme == .dark ? .red.opacity(0.7) : .secondary)
                    .opacity(0.6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(rowBackgroundColor)
                .opacity(0.5)
        )
    }
    
    private var rowBackgroundColor: Color {
        if goal.isCompleted {
            return colorScheme == .dark ? .green.opacity(0.1) : .green.opacity(0.05)
        } else {
            return colorScheme == .dark ? .white.opacity(0.05) : .gray.opacity(0.05)
        }
    }
}