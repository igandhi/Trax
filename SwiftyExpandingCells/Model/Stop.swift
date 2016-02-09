//
//  Stop.swift
//  SwiftyExpandingCells
//
//  Created by Karan Desai on 2/7/16.
//  Copyright © 2016 Fischer, Justin. All rights reserved.
//

import Foundation

class Stop {
    var name: String
    var id: String
    
    init(name: String,id :String) {
        self.name = name
        self.id = id
    }
}

class StopManager {
    static var sharedInstance = StopManager()
    var stops = [Stop]()
    var ids = [String]()
    var stationListData: [String] = [String]()

    init() {
    }
}