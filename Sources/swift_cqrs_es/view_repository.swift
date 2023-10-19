import Foundation
import Bow
import BowEffects
// PersistenceError is an example error type. Define your own error type as needed.
enum PersistenceError: Error {
    case someError
    // Define more error cases as required
}

// ViewRepository protocol in Swift
protocol ViewRepository {
    associatedtype ViewType: View
    associatedtype AggregateType: Aggregate

    func load(viewId: String) -> IO<Error,ViewType>
    func loadWithContext(viewId: String) -> IO<Error,(ViewType, ViewContext)>
    func updateView(view: ViewType, context: ViewContext) 
}




// ViewContext struct in Swift
struct ViewContext {
    var viewInstanceId: String
    var version: Int64

    init(viewInstanceId: String, version: Int64) {
        self.viewInstanceId = viewInstanceId
        self.version = version
    }
}
