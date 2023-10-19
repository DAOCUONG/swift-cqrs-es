public protocol Aggregate  where E : Event , S: Equatable{
    associatedtype S
    associatedtype C
    associatedtype E

    func  handle(_ state: S, _ command: C) -> ([E])
    func apply(_ event: E,_  state: S) -> S
}