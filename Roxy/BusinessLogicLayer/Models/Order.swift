//
//  Order.swift
//  Roxy
//
//  Created by username on 18.01.2023.
//

import Foundation


struct Order: Codable {
    
    let id: Int
    let startAddress: Address
    let endAddress: Address
    let price: Price
    let orderTime: String
    let vehicle: Vehicle
}

extension Order {
    
    var swiftOrderTime: Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: orderTime) else {
            return Date()
        }
        
        return date
    }
}
