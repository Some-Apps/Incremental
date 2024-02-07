import Charts
import SwiftUI

struct ExerciseView: View {
    @AppStorage("randomExercise") var randomExercise: String = ""
    @State private var isTextEditorSheetPresented = false

    @Environment(\.dismiss) var dismiss
    
    @State private var notes = ""
    
    let moc = PersistenceController.shared.container.viewContext
    
    let exercise: Exercise
    
    var sortedLogs: [Log] {
        let logsArray = exercise.logs?.allObjects as? [Log] ?? []
        return logsArray.sorted { $0.timestamp! < $1.timestamp! }
    }
    
    @State private var isActive = false
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._notes = State(initialValue: exercise.notes!)
    }
    
    var body: some View {
        VStack {
            Text(exercise.title!)
            Form {
                Section {
                    Chart(sortedLogs, id: \.self) { log in
                        LineMark(x: .value("Date", log.timestamp!), y: .value("Reps", log.reps))
                            .interpolationMethod(.linear)
                    }
                    .frame(height: 200)
                }
                Section {
                    Toggle("Active", isOn: $isActive)
                        .onAppear {
                            isActive = exercise.isActive
                        }
                }
                Section("Notes") {
                    HStack {
                        Text(notes)
                        Spacer()
                        VStack {
                            Button(action: {
                                isTextEditorSheetPresented.toggle()
                            }) {
                                Image(systemName: "pencil")
                            }
                            .padding(.top)
                            .sheet(isPresented: $isTextEditorSheetPresented) {
                                NotesEditorView(notes: $notes)
                            }
                            Spacer()
                        }
                        
                    }
                    
                    

                }
                
                Section {
                    Button("Do Exercise") {
                        randomExercise = exercise.id!.uuidString
                        dismiss()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    exercise.notes = notes
                    exercise.isActive = isActive
                    try? moc.save()
                    dismiss()
                }
                .disabled(isActive == exercise.isActive && notes == exercise.notes)
            }
        }
    }
}

struct NotesEditorView: View {
    enum FocusedField {
            case active, inactive
        }
    
    @Environment(\.dismiss) var dismiss
    @Binding var notes: String
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                    .focused($focusedField, equals: .active)
                    .onAppear {
                        focusedField = .active
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
