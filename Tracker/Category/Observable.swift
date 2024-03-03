//
//  Observable.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

@propertyWrapper
final class Observable<Value> {
    private (set) var onChange: ((Value) -> Void)? = nil
    
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> {
        return self
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(action: @escaping (Value) -> Void) {
        self.onChange = action
    }
}
