//
//  RideTableViewCell.swift
//  Roxy
//
//  Created by username on 08.01.2023.
//

import UIKit


class OrderTableViewCell: UITableViewCell {
    
    static let cellName: String = "RideCell"
    
    var image: UIImage? = nil {
        didSet {
            if let image = image {
                carImageView.contentMode = .scaleAspectFill
                carImageView.image = image
            } else {
                carImageView.contentMode = .scaleAspectFit
                carImageView.image = UIImage(systemName: "car")
            }
            setNeedsLayout()
        }
    }
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return stack
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 4
        
        return stack
    }()
    
    private let carImageView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "car")
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    private let startAddressLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .systemGray
        
        return label
    }()
    
    private let destinationAddressLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .systemGray
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
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
    

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            carImageView.heightAnchor.constraint(equalToConstant: 64),
            carImageView.widthAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.fillSuperview()
        stack.addArrangedSubview(carImageView)
        stack.addArrangedSubview(labelsStack)
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(startAddressLabel)
        labelsStack.addArrangedSubview(destinationAddressLabel)
        labelsStack.addArrangedSubview(priceLabel)
        activateConstraints()
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        startAddressLabel.text = nil
        destinationAddressLabel.text = nil
        priceLabel.text = nil
        image = nil
    }
    
    func configure(for order: DBOrder) {
        
        var titleText: String = ""
        
        startAddressLabel.text = order.startAddressAddress
        destinationAddressLabel.text = order.endAddressAddress
        
        priceFormatter.currencyCode = order.priceCurrency
        priceFormatter.currencySymbol = priceFormatter.currencyCode == "RUB" ? "₽" : nil
        let price = Float(order.priceAmount) / 100
        priceLabel.text = priceFormatter.string(from: NSNumber(value: price))
        
        guard let date = order.orderTime,
              let startAddressCity = order.startAddressCity,
              let endAddressCity = order.endAddressCity else {
            return
        }
        
        titleText = dateFormatter.string(from: date)
        
        if startAddressCity == endAddressCity {
            titleText += ", \(startAddressCity)"
        } else {
            titleText += ", \(startAddressCity) → \(endAddressCity)"
        }
        titleLabel.text = titleText
    }
}

extension UIView {
    
    func fillSuperview() {
        
        guard let superview = self.superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
       
        NSLayoutConstraint.activate(constraints)
    }
}
