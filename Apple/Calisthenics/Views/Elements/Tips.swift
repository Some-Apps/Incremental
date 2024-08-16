import TipKit
import SwiftUI

struct MyPopoverTip: Tip {

    var title: Text {
        Text("Sorting now available")
    }

    var message: Text? {
        Text("Sort the items in the list by dragging them to the desired position.")
    }
    
    var actions: [Action] {
           [
            Action(id: "next", title: "Next", perform: nextTip),
           ]
       }
    
    func nextTip() {
        MyPopoverTip2.showTip = true
        self.invalidate(reason: .actionPerformed)
    }
}

struct MyPopoverTip2: Tip {
    
    @Parameter static var showTip: Bool = false

    var title: Text {
        Text("now available")
    }

    var message: Text? {
        Text("Sort the items in the list by dragging them to the desired position.")
    }
    
    var rules: [Rule] {
        #Rule(Self.$showTip) { $0 == true }
    }
}
