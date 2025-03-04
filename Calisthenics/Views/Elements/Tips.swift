import TipKit
import SwiftUI

struct GoToRepertoireTip: Tip {
    var title: Text {
        Text("Add Exercises")
    }
    
    var message: Text? {
        Text("You can add exercises in the \"Repertoire\" tab")
    }
    
    var image: Image? {
        Image(systemName: "list.clipboard")
    }
}
 
struct AddExerciseTip: Tip {
    var title: Text {
        Text("Add Exercise")
    }
    
    var message: Text? {
        Text("You can add an exercise by tapping here")
    }
    
    var image: Image? {
        Image(systemName: "figure.core.training")
    }
}
