//
//  PTSummary.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation

class PTSummary {
    var numPTsInArea = 0
    var totalPTsWithRatings = 0
    var avgRatingForPTsInArea: Double = 0.0
    var totalReviews = 0
    
    init(numPTsInArea: Int, totalPTsWithRatings: Int, avgRatingForPTsInArea: Double, totalReviews: Int) {
        self.numPTsInArea = numPTsInArea
        self.totalPTsWithRatings = totalPTsWithRatings
        self.avgRatingForPTsInArea = avgRatingForPTsInArea
        self.totalReviews = totalReviews
    }
}
