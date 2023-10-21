import swift_cqrs_es
import Bow
import XCTest
import BowEffects
let k_max_retry_time = 3

enum LoginFailedReason:Codable,Equatable {
    case wrong_username_password(UInt32)
    case retry_limited
    case wrong_state
    case already_logined
    case wrong_confirm_code(UInt32)

    static func == (lhs: LoginFailedReason, rhs: LoginFailedReason) -> Bool {
        switch (lhs, rhs) {
        case let (.wrong_username_password(lhsValue), .wrong_username_password(rhsValue)):
            return lhsValue == rhsValue

        case (.retry_limited, .retry_limited):
            return true

        case (.wrong_state, .wrong_state):
            return true

        case (.already_logined, .already_logined):
            return true

        case let (.wrong_confirm_code(lhsValue), .wrong_confirm_code(rhsValue)):
            return lhsValue == rhsValue

        default:
            return false
        }
    }
}

enum LoginEvent: Codable,Equatable{
    case succeed_logined
    case failed_login(LoginFailedReason)
    case waitting_confirm_code(UInt32)
    case logged_out
     static func == (lhs: LoginEvent, rhs: LoginEvent) -> Bool {
        switch (lhs, rhs) {
        case (.succeed_logined, .succeed_logined):
            return true

        case let (.failed_login(lhsReason), .failed_login(rhsReason)):
            return lhsReason == rhsReason

        case let (.waitting_confirm_code(lhsValue), .waitting_confirm_code(rhsValue)):
            return lhsValue == rhsValue

        case (.logged_out, .logged_out):
            return true

        default:
            return false
        }
    }
}


enum LoginCommand: Codable {
    case login(_ username: String,_  password: String)
    case confirm_code(String)
    case logout
}


extension  LoginEvent:Event {
    func eventType() -> String {
        return "Login"
    }

    func eventVersion() -> String {
        "1.0"
    }   
}

enum LoginState: Codable, Equatable {
   case logged_out
   case succeed_logined
   case waitting_confirm_code
   case retry_login(UInt32)
   case retry_confirm_code(UInt32)
}


struct LoginAggregate {
    let username: String
    var state:LoginState

}

func verify_password(_ username:String,_ password:String) -> IO<Error,Bool> {
    return IO.invoke{return true}^
}

func verify_confirm_code(_ confirm_code: String) -> IO<Error,Bool> {
    return IO.invoke{return true}^
}

func handle_login_command_for_logged_out_state(_ command: LoginCommand) -> [LoginEvent] {
    switch command {
        case .login(let username, let password):
            if run_io(verify_password(username,password))  {
                return [LoginEvent.waitting_confirm_code(1)]
            }else {
                return [LoginEvent.failed_login(.wrong_username_password(1))]
            }
        case .confirm_code(let _ ):
                return [LoginEvent.failed_login(.wrong_state)]

        case .logout:
                return [LoginEvent.failed_login(.wrong_state)]

    }
} 

func handle_login_command_for_logged_in_state(_ command: LoginCommand) -> [LoginEvent] {
    switch command {
        case .login(let username, let password):
            return [LoginEvent.failed_login(.already_logined)]

        case .confirm_code(let code):
            return [LoginEvent.failed_login(.already_logined)]

        case .logout:
            return [LoginEvent.logged_out]

    }
} 

func handle_login_command_for_confirm_code_state(_ command: LoginCommand) -> [LoginEvent] {
    switch command {
        case .login(let username, let password):
            return [LoginEvent.failed_login(.wrong_state)]

        case .confirm_code(let code):
            if run_io(verify_confirm_code(code)) {
                return [LoginEvent.succeed_logined]
            }else {
                return [LoginEvent.waitting_confirm_code(1)]
            }

            return [LoginEvent.failed_login(.already_logined)]

        case .logout:
            return [LoginEvent.logged_out]

    }
} 

func handle_login_command_for_retry_login_state(_ retried_times:UInt32,_ command: LoginCommand) -> [LoginEvent] {
    switch command {
        case .login(let username, let password):
            return [LoginEvent.failed_login(.wrong_state)]

        case .confirm_code(let code):
            return [LoginEvent.failed_login(.already_logined)]

        case .logout:
            return [LoginEvent.logged_out]

    }
} 

func run_io(_ io_op: IO<Error,Bool>) -> Bool {

    let operation = IO<Error, Bool>.var()
    let job = binding (
        operation <- io_op,
        yield: operation.get

    )^
    let result = try? job.unsafeRunSync()
    return result!
}

func handle_login_command_for_retry_confirm_code_state(_ retried_times:UInt32,_ command: LoginCommand) -> [LoginEvent] {
    switch command {
        case .login(let username, let password):
            return [LoginEvent.failed_login(.wrong_state)]

        case .confirm_code(let code):

            if  run_io(verify_confirm_code(code))
            {
                return [LoginEvent.succeed_logined]
            }

            if retried_times > k_max_retry_time  {
                return [LoginEvent.failed_login(.retry_limited)]
            }

            return [LoginEvent.failed_login(.wrong_username_password(retried_times+1))]

        case .logout:
            return [LoginEvent.logged_out]

    }
} 

func process_login_command(_ state: LoginState) -> (_ command: LoginCommand) -> [LoginEvent] {
    return {(command: LoginCommand) in 
        switch state {
           case .logged_out:
                return handle_login_command_for_logged_out_state(command)
           case .succeed_logined:
                return handle_login_command_for_logged_in_state(command)
           case .waitting_confirm_code:
                return handle_login_command_for_confirm_code_state(command)
           case .retry_login(let retried_times):
                return handle_login_command_for_retry_login_state(retried_times,command)
            case .retry_confirm_code(let retried_times):
                return handle_login_command_for_retry_confirm_code_state(retried_times,command)
        }   

    }
      
}


extension LoginAggregate: Aggregate {
    typealias E = LoginEvent
    typealias C = LoginCommand
    typealias S = LoginState
    func  handle(_ state: S, _ command: C) -> ([E]) {
        return process_login_command(state)(command)

    }
    
    func apply(_ event: E, _ state: S) -> S {
        return .logged_out
    }
    
    func aggregate_type() -> String {
        return "LoginAggregate"
    }
    
    func aggregate_version() -> String {
       return "1.0"
    }
}


final class aggregate_Tests: XCTestCase {
    func testExample() throws {
      
        let login_state = LoginState.logged_out
        let aggregate = LoginAggregate(username:"dao",state: login_state)

        let events = aggregate.handle(login_state, LoginCommand.login("dao","cuong"))

        
         XCTAssertEqual(events.count,1)
         let event = events.first! 
        XCTAssertEqual(event, LoginEvent.waitting_confirm_code(1))

    }
}
