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
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(exercises, id: \.self) { exercise in
                        Text(exercise.title!)
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
