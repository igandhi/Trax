//
//  Brand.swift
//  SwiftyExpandingCells
//
//  Created by Fischer, Justin on 11/19/15.
//  Copyright © 2015 Fischer, Justin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Brand {
    var iconText: String
    var name: String
    var numberOfIncidents: String
    
    init(iconText: String, name: String, numberOfIncidents: String) {
        self.iconText = iconText
        self.name = name
        self.numberOfIncidents = numberOfIncidents
    }
}

class BrandManager {
    static var sharedInstance = BrandManager()
    var brands = [Brand]()
    
    init() {
    }
}