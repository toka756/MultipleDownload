//
//  AsynchronousOperation.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation

/// Asynchronous operation base class
///
/// This is abstract to class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `Operation` subclass. You can subclass this and
/// implement asynchronous operations. All you must do is:
///
/// - override `main()` with the tasks that initiate the asynchronous task;
///
/// - call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
/// necessary and then ensuring that `completeOperation()` is called; or
/// override `cancel` method, calling `super.cancel()` and then cleaning-up
/// and ensuring `completeOperation()` is called.

public class AsynchronousOperation : Operation {
    override public var isAsynchronous: Bool {
        return true
    }

    private let stateLock = NSLock()
    private var _executing: Bool = false
    override private(set) public var isExecuting: Bool {
        get {
            return stateLock.withCriticalScope {
                _executing
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            stateLock.withCriticalScope {
                _executing = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    override private(set) public var isFinished: Bool {
        get {
            return stateLock.withCriticalScope {
                _finished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateLock.withCriticalScope {
                _finished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting
    public func completeOperation() {
        if isExecuting {
            isExecuting = false
        }
        if !isFinished {
            isFinished = true
        }
    }

    override public func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        main()
    }
}

extension NSLock {
    /// Perform closure within lock.
    ///
    /// An extension to `NSLock` to simplify executing critical code.
    ///
    /// - parameter block: The closure to be performed.
    func withCriticalScope<T>(block:() -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
