//
//  PTResult.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation

class PTResult: Codable {
    var name: String?
    var rating: Double?
    var review_count: Int?
    var location: PTLocation?
    
    init(name: String, rating: Double, review_count: Int, location: PTLocation) {
        self.name = name
        self.rating = rating
        self.review_count = review_count
        self.location = location
    }
}
