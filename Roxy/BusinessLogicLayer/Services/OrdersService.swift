//
//  OrdersService.swift
//  Roxy
//
//  Created by username on 18.01.2023.
//

import Foundation


private let ordersServiceName = "OrdersService"

extension ServiceRegistryImplementation {
    
    var ordersService: OrdersService {
            guard let service = serviceWith(name: ordersServiceName) as? OrdersService
                else { fatalError("Ошибка: SOA сервис OrdersService не зарегистрирован через ServiceRegistry") }
            return service
    }
}

protocol OrdersService: Service {
    
    func fetchOrders(completion: @escaping (Result<[Order], Error>) -> Void)
}

extension OrdersService {
    
    var serviceName: String {
        return ordersServiceName
    }
    
    func fetchOrders(completion: @escaping (Result<[Order], Error>) -> Void) {

        guard let ordersURL = URL(string: Endpoint.ordersURL) else {
            return
        }
        
        let ordersUrl = ordersURL.appendingPathComponent("orders.json")
        
        let request = URLRequest(url: ordersUrl,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(integerLiteral: 5))
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                if let data = data {
                    do {
                        NSLog("response: \(response)")
                        if let string = String(data: data, encoding: .utf8) {
                            print(string)
                        }
                        let orders = try JSONDecoder().decode([Order].self, from: data)
                        completion(.success(orders))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError()))
                }
            } else {
                completion(.failure(NSError()))
            }
        }.resume()
    }
}

class OrdersServiceImplementation: OrdersService {
    
    static func register() {
        ServiceRegistry.add(service: LazyService(serviceName: ordersServiceName, serviceGetter: {
            OrdersServiceImplementation()
        }))
    }
}
