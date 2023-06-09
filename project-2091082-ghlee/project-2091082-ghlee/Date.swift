//
//  Date.swift
//  project-2091082-ghlee
//
//  Created by 이가현 on 2023/06/09.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        if let plusOneMonth = calendar.date(byAdding: .month, value: 1, to: self),
           let endOfMonth = calendar.date(byAdding: .day, value: -1, to: plusOneMonth) {
            return endOfMonth
        }
        return self
    }
    
}
