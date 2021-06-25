//
//  AsynchronousOperation.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation

/// Asynchronous operation base class

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
