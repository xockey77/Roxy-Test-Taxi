//
//  RideDetailViewController.swift
//  Roxy
//
//  Created by username on 10.01.2023.
//

import UIKit


class OrderDetailViewController: UITableViewController {
    
    enum Section: String, CaseIterable {
        case orderTime      = "Время заказа"
        case price          = "Стоимость поездки"
        case startAddress   = "Начальный адрес"
        case endAddress     = "Конечный адрес"
        case driver         = "Водитель"
        case vehicleModel   = "Машина"
    }
    
    let order: DBOrder
    
    let imageProvider: ImageProviderProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "RU")
        
        return formatter
    }()
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    init(style: UITableView.Style, order: DBOrder, imageProvider: ImageProviderProtocol?) {
        self.order = order
        self.imageProvider = imageProvider
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        
        if let date = order.orderTime {
            title = "Поездка от \(dateFormatter.string(from: date))"
        } else {
            title = "Поездка"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")
        var text: String?
        
        let section = Section.allCases[indexPath.section]
            
        switch section {
        case .price:
            priceFormatter.currencyCode = order.priceCurrency
            priceFormatter.currencySymbol = priceFormatter.currencyCode == "RUB" ? "₽" : nil
            let price = Float(order.priceAmount) / 100
            text = priceFormatter.string(from: NSNumber(value: price))
        case .startAddress:
            text = order.startAddressAddress
            cell.detailTextLabel?.text = order.startAddressCity
        case .endAddress:
            text = order.endAddressAddress
            cell.detailTextLabel?.text = order.endAddressCity
        case .driver:
            text = order.vehicleDriverName
        case .vehicleModel:
            if let carName = order.vehicleModelName,
               let regNumber = order.vehicleRegNumber {
                text = "\(carName) \(regNumber.uppercased())"
            }
        case .orderTime:
            if let date = order.orderTime {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .medium
                text = dateFormatter.string(from: date)
            }
        }
        cell.textLabel?.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Section.allCases[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard Section.allCases[section] == .vehicleModel else {
            return nil
        }
        
        guard let imagesURL = URL(string: Endpoint.imagesURL),
              let photo = order.vehiclePhoto else {
            return nil
        }

        let url = imagesURL.appendingPathComponent(photo)
        
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        imageProvider?.getImage(for: url) { image in
            if let image = image {
                DispatchQueue.main.async {
                    view.image = image
                }
            }
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if Section.allCases[section] == .vehicleModel {
            let screenWidth = UIScreen.main.bounds.width
            return screenWidth * 0.75
        }
        return 0.0
    }
    
}

