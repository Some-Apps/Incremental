//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct RepertoireView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var exercises: FetchedResults<Exercise>
    @Environment(\.editMode) private var editMode
    @AppStorage("randomExercise") var randomExercise = ""
    
    @State private var showingAdd = false
    
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(exercises, id: \.self) { exercise in
                    NavigationLink(destination: EditExerciseView(exercise: exercise)) {
                        Text(exercise.title ?? "Unkown")
                            .foregroundColor(exercise.id?.uuidString == randomExercise ? .secondary : .primary)
                            .bold(exercise.goal == "Maintain" ? true : false)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            
        }
        .sheet(isPresented: $showingAdd) {
            AddExerciseView()
        }
    }

}

//struct RepertoireView_Previews: PreviewProvider {
//    static var previews: some View {
//        RepertoireView()
//    }
//}
