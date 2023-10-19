import XCTest
import Bow
func f1(_ x : Int) -> Int {
    return 2 * x
}

func f2(_ x : Int) -> String {
    return "\(x)"
}


@testable import swift_cqrs_es

final class swift_cqrs_esTests: XCTestCase {
    func testExample() throws {
        let composed = compose(f2, f1)
        print("{}",composed(3))
        
         XCTAssertEqual("6",composed(3))
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}
