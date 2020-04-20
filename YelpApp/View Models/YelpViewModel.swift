//
//  YelpViewModel.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation

class YelpViewModel {
    var results: [PTResult]?
    var summary: PTSummary?
    
    init(results: [PTResult], summary: PTSummary) {
        self.results = results
        self.summary = summary
    }
}
