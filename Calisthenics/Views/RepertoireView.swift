//
//  RepertoireView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct RepertoireView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: []) var exercises: FetchedResults<Exercise>
    @Environment(\.editMode) private var editMode
    
    @State private var showingAdd = false
    
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(exercises, id: \.self) { exercise in
                    NavigationLink(destination: EmptyView()) {
                        Text(exercise.title ?? "Unknown")
                    }
                }
                .onDelete(perform: deleteTasks)

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
    
    private func deleteTasks(offsets: IndexSet) {
            withAnimation {
                offsets.map { exercises[$0] }.forEach(moc.delete)
                try? moc.save()
            }
        }
}

struct RepertoireView_Previews: PreviewProvider {
    static var previews: some View {
        RepertoireView()
    }
}
