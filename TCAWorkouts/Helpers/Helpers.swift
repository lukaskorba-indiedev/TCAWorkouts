import SwiftUI

extension Workout {
    func bind() -> Binding<Workout?> {
        .init(
            get: { self },
            set: { _ in }
        )
    }
}

extension Binding {
    func isPresent<OptionalValue>() -> Binding<Bool>
    where Value == OptionalValue? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }
    
    func didSet(_ callback: @escaping (Value) -> Void) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                callback($0)
            })
    }
}

extension NavigationLink {
    init<OptionalValue>(
        wrapper: OptionalValue?,
        on: @escaping () -> Void,
        off: @escaping () -> Void,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.init(
            isActive: Binding(
                get: { wrapper != nil },
                set: { isPresented in
                    if isPresented {
                        on()
                    } else {
                        off()
                    }
                }),
            destination: destination,
            label: label)
    }
    
//    init<Wrapped>(
//        wrapper: Binding<Wrapped>,
//        @ViewBuilder destination: @escaping () -> Destination,
//        @ViewBuilder label: @escaping () -> Label
//    ) {
//        self.init(
//            isActive: Binding(
//                get: { wrapper.wrappedValue ==  },
//                set: { isPresented in
//                    if isPresented {
//                        
//                    }
//                }),
//            destination: destination,
//            label: label)
//    }
}


import Foundation

struct MemoryAddress<T>: CustomStringConvertible {

    let intValue: Int

    var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }

    // for structures
    init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
    }
}

extension MemoryAddress where T: AnyObject {

    // for classes
    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
        // or      Int(bitPattern: Unmanaged<T>.passUnretained(classInstance).toOpaque())
    }
}
