# Swift CQRS-ES (Command Query Responsibility Segregation - Event Sourcing)

Swift CQRS-ES is a tiny-lightweight framework for implementing the Command Query Responsibility Segregation (CQRS) and Event Sourcing (ES) architectural patterns in Swift. This framework provides a foundation for building scalable, maintainable, and highly decoupled systems by separating the write (command) and read (query) sides of your application and storing all changes as a series of immutable events.

Use CQRS-ES instead of redux, this use to implement your bussiness layer
## Table of Contents

- [Introduction](#swift-cqrs-es-command-query-responsibility-segregation---event-sourcing)
- [Getting Started](#getting-started)
- [Key Concepts](#key-concepts)
- [Usage](#usage)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

### Installation

You can add Swift CQRS-ES to your Swift project using Swift Package Manager. To do this, add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/DAOCUONG/swift-cqrs-es.git", from: "1.0.0")
```

Then, add `"SwiftCQRS-ES"` as a dependency to your target and import the library in your code:

```swift
import SwiftCQRS-ES
```

### Prerequisites

- Swift 5.0 or later
- Knowledge of CQRS and Event Sourcing principles

## Key Concepts

### Command

A command represents an intention to change the state of your system. It is a simple data structure that encapsulates the necessary information to perform an action. Commands are processed by command handlers.

### Command Handler

A command handler is responsible for taking a command and making changes to the application's state based on the information contained in the command. Command handlers are the entry points for executing actions in your system.

### Event

An event represents something that has happened in the past. Events are immutable and contain data that describes the state change. Events are stored in the event store, and they are used to rebuild the application's state.

### Event Store

The event store is a repository for storing all the events in your system. It provides an append-only log of events and allows you to query and replay events to reconstruct the application's state.

### Aggregate

An aggregate is a domain object that encapsulates the state and business logic related to a specific entity. Aggregates handle incoming commands, produce events, and ensure consistency and validity of the changes they make.

### Query

A query is a request to retrieve data from your system. Queries are handled by query handlers, which are separate from command handlers to optimize for read performance.

### Query Handler

A query handler processes queries and retrieves data from the read side of your application. This separation of read and write sides allows for independent scaling and optimization of each side.

## Usage

1. **Define Commands**: Create command types that represent the actions you want to perform in your system. Commands are simple data structures.

2. **Create Command Handlers**: Implement command handlers that take in commands and perform the necessary actions, producing events as a result.

3. **Define Events**: Create event types that represent state changes in your application. Events are immutable data structures.

4. **Store Events**: Store events in an event store. This can be a database, a file, or any other storage mechanism that supports an append-only log of events.

5. **Create Aggregates**: Implement aggregates that handle commands, validate them, and produce events. Aggregates are the core of your application's business logic.

6. **Replay Events**: Use events to rebuild the application's state by replaying the events in the correct order.

7. **Create Queries**: Define query types that represent the data you want to retrieve from the read side of your application.

8. **Create Query Handlers**: Implement query handlers to process queries and retrieve data efficiently from the read side.

## Example

Here's a simple example of how to use Swift CQRS-ES to implement a bank account system:

```swift
import SwiftCQRS-ES

// Define a command
struct CreateAccountCommand: Command {
    let accountID: String
    let initialBalance: Double
}

// Create a command handler
struct CreateAccountCommandHandler: CommandHandler {
    func handle(command: CreateAccountCommand) throws {
        // Validate and create the account
        let account = Account(accountID: command.accountID)
        account.deposit(command.initialBalance)
        // Produce events
        let events = account.getUncommittedEvents()
        // Store the events in the event store
        // ...
    }
}

// Define an event
struct AccountCreatedEvent: Event {
    let accountID: String
    let initialBalance: Double
}

// Define an aggregate
struct Account: Aggregate {
    private var balance: Double = 0
    private var events: [Event] = []

    init(accountID: String) {
        apply(event: AccountCreatedEvent(accountID: accountID, initialBalance: 0))
    }

    func deposit(_ amount: Double) {
        apply(event: DepositMadeEvent(amount: amount))
    }

    private func apply(event: Event) {
        // Apply the event to the aggregate's state
        // ...
        // Add the event to the uncommitted events
        events.append(event)
    }

    func getUncommittedEvents() -> [Event] {
        return events
    }
}

// ... More event and command definitions

```

For a complete working example, please refer to the provided documentation and samples.

## Contributing

We welcome contributions from the community. If you have suggestions, bug reports, or want to contribute to the project, please open an issue or submit a pull request on the GitHub repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Thank you for using Swift CQRS-ES! We hope this framework helps you implement CQRS and Event Sourcing in your Swift applications with ease. If you have any questions or need further assistance, please feel free to reach out to us through the project's GitHub repository.
