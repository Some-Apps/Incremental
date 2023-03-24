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
    
    @State private var showingAdd = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: columns) {
                ForEach(exercises, id: \.self) { exercise in
                    NavigationLink(destination: EmptyView()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .aspectRatio(1.5, contentMode: .fit)
                                .foregroundColor(exercise.goal == "Improve" ? .blue : .green)
                            Text(exercise.title ?? "Unknown")
                                .foregroundColor(.primary)
                                .padding()
                        }
                    }
                    .padding()
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            moc.delete(exercise)
                            do {
                                try moc.save()
                            } catch {
                                // handle the core data error
                            }
                        }
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

struct RepertoireView_Previews: PreviewProvider {
    static var previews: some View {
        RepertoireView()
    }
}
