//
//  YelpService.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation

class YelpService {
    let resultCache = NSCache<NSString, PTResult>()
    static let shared = YelpService()
    
    func getPList() -> [String:String]? {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        
        let data = try! Data(contentsOf: url)
        
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {
            return nil
        }
        
        return plist
    }
    
    func getDecryptedToken() -> String? {
        guard let plist = getPList() else {
            return nil
        }
        
        guard let token = plist["Encoded Yelp Key"]?.fromBase64() else {
            return nil
        }
        
        return token
    }
    
    func getSearchTerm() -> String? {
        guard let plist = getPList() else {
            return nil
        }
        
        guard let term = plist["Term"] else {
            return nil
        }
        
        return term
    }
    
    func retrieveYelpPTListings(urlStr: String, location: String, completion: @escaping (_ viewModel: YelpViewModel?)-> Void) {
        var results = [PTResult]()
        
        guard let term = getSearchTerm() else {
            completion(nil)
            return
        }
        
        guard let finalURL = String(format: "%@?location=%@&term=%@", urlStr, location, term).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        guard let url = URL(string: finalURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        
        guard let decryptedToken = getDecryptedToken() else {
            return
        }
        
        request.setValue("Bearer \(decryptedToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                var cumulativeRating:Double = 0.0
                var numOfPTsWithRating = 0
                var avgPTRating = 0.0
                
                guard let totalReviewCount = jsonData["total"] as? Int else {
                    completion(nil)
                    return
                }
                
                guard let businesses = jsonData["businesses"] as? [[String:Any]] else {
                    completion(nil)
                    return
                }
                for business in businesses {
                    print(business)
                    guard let newJsonData = try? JSONSerialization.data(withJSONObject: business, options: []) else {
                        completion(nil)
                        return
                    }
                    let decoder = JSONDecoder()

                    do {
                        let result = try decoder.decode(PTResult.self, from: newJsonData)
                        results.append(result)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                let filteredResults = results.filter {
                    guard let _ = $0.rating else {
                        return false
                    }
                    return true
                }
                let _ = filteredResults.map {
                    guard let rating = $0.rating else {
                        return
                    }
                    numOfPTsWithRating = numOfPTsWithRating + 1
                    cumulativeRating = cumulativeRating + rating
                }
                avgPTRating = cumulativeRating/Double(numOfPTsWithRating)
                let ptSummary = PTSummary(numPTsInArea: results.count, totalPTsWithRatings: numOfPTsWithRating, avgRatingForPTsInArea: avgPTRating, totalReviews: totalReviewCount)
                let yelpVM = YelpViewModel(results: results, summary: ptSummary)
                completion(yelpVM)
            }
            else {
                completion(nil)
            }
        }
        
        task.resume()
    }
}
