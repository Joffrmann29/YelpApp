//
//  PTLocation.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation

class PTLocation: Codable {
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var state: String?
    var zip_code: String?
    
    init(address1: String, address2: String, address3: String, city: String, state: String, zip_code: String) {
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.city = city
        self.state = state
        self.zip_code = zip_code
    }
}
