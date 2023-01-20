//
//  AppDelegate.swift
//  Roxy
//
//  Created by username on 29.12.2022.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let serviceRegistry: ServiceRegistryImplementation = {
        
        OrdersServiceImplementation.register()
        OrdersCacheServiceImplementation.register()
        
        return ServiceRegistry
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let coreDataStack = CoreDataStack(modelName: "OrdersCacheModel")
        let cacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cache = ImageCache(cacheDirectory: cacheDirectory,
                               entryLifetime: 60 * 10)
        cache.deleteOldCachedImages()
        let imageProvider = ImageProvider(cache: cache)
        let ordersListViewController = OrdersListViewController(style: .grouped,
                                                                coreDataStack: coreDataStack,
                                                                imageProvider: imageProvider)
        let navigationController = UINavigationController()
        navigationController.pushViewController(ordersListViewController, animated: false)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
}

