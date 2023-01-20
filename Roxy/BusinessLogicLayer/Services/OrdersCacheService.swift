//
//  OrdersCacheService.swift
//  Roxy
//
//  Created by username on 11.01.2023.
//

import Foundation
import CoreData


private let ordersCacheServiceName = "OrdersCacheService"

extension ServiceRegistryImplementation {
    
    var ordersCacheService: OrdersCacheService {
            guard let service = serviceWith(name: ordersCacheServiceName) as? OrdersCacheService
                else { fatalError("Ошибка: SOA сервис OrdersCacheService не зарегистрирован через ServiceRegistry") }
            return service
    }
}

protocol OrdersCacheService: Service {
    
    func saveOrders(orders: [Order],
                    to context: NSManagedObjectContext,
                    fetchedResultsController: NSFetchedResultsController<DBOrder>)
    
    func loadCachedOrders(by fetchedResultsController: NSFetchedResultsController<DBOrder>)
    
    func deleteAllOrders(in context: NSManagedObjectContext)
}

extension OrdersCacheService {
    
    var serviceName: String {
        return ordersCacheServiceName
    }
    
    func saveOrders(orders: [Order],
                    to context: NSManagedObjectContext,
                    fetchedResultsController: NSFetchedResultsController<DBOrder>) {
        
        for order in orders {
            NSLog("Добавляю новый заказ в CoreData")
            let orderToSave = DBOrder(context: context)
            orderToSave.id = Int64(order.id)
            orderToSave.orderTime = order.swiftOrderTime
            orderToSave.startAddressCity = order.startAddress.city
            orderToSave.startAddressAddress = order.startAddress.address
            orderToSave.endAddressCity = order.endAddress.city
            orderToSave.endAddressAddress = order.endAddress.address
            orderToSave.priceAmount = Int64(order.price.amount)
            orderToSave.priceCurrency = order.price.currency
            orderToSave.vehicleRegNumber = order.vehicle.regNumber
            orderToSave.vehicleModelName = order.vehicle.modelName
            orderToSave.vehicleDriverName = order.vehicle.driverName
            orderToSave.vehiclePhoto = order.vehicle.photo
        }
    }
    
    func loadCachedOrders(by fetchedResultsController: NSFetchedResultsController<DBOrder>) {
        
        do {
            try fetchedResultsController.performFetch()
            if let count = fetchedResultsController.fetchedObjects?.count {
                NSLog("Количество заказов из CoreData: \(count)")
            }
        } catch {
            NSLog("Ошибка загрузки заказов из CoreData: \(error.localizedDescription)")
        }
    }
    
    func deleteAllOrders(in context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "DBOrder")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else {
            return
        }

        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
    }
}

class OrdersCacheServiceImplementation: OrdersCacheService {
    
    static func register() {
        ServiceRegistry.add(service: LazyService(serviceName: ordersCacheServiceName, serviceGetter: {
            OrdersCacheServiceImplementation()
        }))
    }
}
