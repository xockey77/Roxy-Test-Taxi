//
//  ListViewController.swift
//  Roxy
//
//  Created by username on 29.12.2022.
//

import Foundation
import UIKit
import CoreData


class OrdersListViewController: UITableViewController {
    
    var coreDataStack: CoreDataStackProtocol
    var imageProvider: ImageProviderProtocol?
    
    private let ordersCacheService = ServiceRegistry.ordersCacheService
    
    private let ordersService = ServiceRegistry.ordersService
    
    private lazy var fetchedResultsController: NSFetchedResultsController<DBOrder> = {
        
        let fetchRequest: NSFetchRequest<DBOrder> = NSFetchRequest<DBOrder>(entityName: "DBOrder")
        let sort = NSSortDescriptor(key: #keyPath(DBOrder.orderTime),
                                    ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let context = coreDataStack.managedContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private lazy var loadIndicator: UIBarButtonItem = {
        
        let button = UIBarButtonItem(customView: spinner)
        
        return button
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }()
    
    var orders: [Order] = []
    
    init(style: UITableView.Style, coreDataStack: CoreDataStackProtocol, imageProvider: ImageProviderProtocol?) {
        self.coreDataStack = coreDataStack
        self.imageProvider = imageProvider
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Поездки"
        self.navigationItem.setRightBarButton(self.loadIndicator, animated: true)
        tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: OrderTableViewCell.cellName)
        ordersCacheService.loadCachedOrders(by: fetchedResultsController)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        reload()
    }
    
    func displayAlert(with error: Error) {
        
        let alert = UIAlertController(title: "Ошибка",
                                      message: "\(error.localizedDescription)\nЧто-то пошло не так при загрузке поездок с сервера...",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.spinner.startAnimating()
            self?.reload()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        self.present(alert, animated: true)
    }
    
    func updateUI(with orders: [Order]) {
        self.orders = orders
        NSLog("Количество заказов с сервера: \(self.orders.count)")
        
        let context = self.coreDataStack.managedContext
        self.ordersCacheService.deleteAllOrders(in: context)
        self.ordersCacheService.saveOrders(orders: self.orders,
                                           to: context,
                                           fetchedResultsController: self.fetchedResultsController)
        self.coreDataStack.saveContext()
        NSLog("Сохранил заказы в CoreData")
        self.spinner.stopAnimating()
        self.refreshControl?.endRefreshing()
    }
    
    @objc
    func reload() {
        
        ordersService.fetchOrders { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                
                case .success(let orders):
                    self.updateUI(with: orders)
                    
                case .failure(let error):
                    self.spinner.stopAnimating()
                    self.refreshControl?.endRefreshing()
                    self.displayAlert(with: error)
                }
            }
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderTableViewCell.cellName,
                                                       for: indexPath) as? OrderTableViewCell else {
            return UITableViewCell()
        }
        
        let order = fetchedResultsController.object(at: indexPath)
        cell.configure(for: order)
        
        guard let imagesURL = URL(string: Endpoint.imagesURL),
              let photo = order.vehiclePhoto else {
            return cell
        }

        let url = imagesURL.appendingPathComponent(photo)

        imageProvider?.getImage(for: url) { [weak self] image in
            DispatchQueue.main.async {
                if let currentIndexPath = self?.tableView.indexPath(for: cell),
                   currentIndexPath != indexPath {
                    return
                }
                cell.image = image
                cell.setNeedsLayout()
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let order = fetchedResultsController.object(at: indexPath)
        let orderDetailViewController = OrderDetailViewController(style: .grouped,
                                                                  order: order,
                                                                  imageProvider: imageProvider)
        navigationController?.pushViewController(orderDetailViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let order = fetchedResultsController.object(at: indexPath)
            let context = self.coreDataStack.managedContext
            context.delete(order)
            self.coreDataStack.saveContext()
        }
    }
}
