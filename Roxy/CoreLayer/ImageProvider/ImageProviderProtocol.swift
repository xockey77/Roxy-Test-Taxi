//
//  ImageProviderProtocol.swift
//  Roxy
//
//  Created by username on 18.01.2023.
//

import Foundation
import UIKit

protocol ImageProviderProtocol {
    
    func getImage(for url: URL, completion: @escaping ((UIImage?) -> Void))
}
