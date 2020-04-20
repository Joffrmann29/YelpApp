//
//  ViewController.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, LocationManagerDelegate {
    var currentLocation = ""
    var ptResults: [PTResult]?
    let yelpLocationManager = LocationManager.shared
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numPTsInAreaLabel: UILabel!
    @IBOutlet weak var totalPTsWithRatingsLabel: UILabel!
    @IBOutlet weak var avgRatingForPTsLabel: UILabel!
    @IBOutlet weak var totalNumOfReviewsLabel: UILabel!
    @IBOutlet weak var locationField: UITextField! {
        didSet {
            locationField.layer.borderColor = UIColor.lightGray.cgColor
            locationField.layer.borderWidth = 2
            locationField.layer.cornerRadius = 5
            locationField.clipsToBounds = true
            locationField.attributedPlaceholder = NSAttributedString(string: "Enter location",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    @IBOutlet weak var displayResultsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yelpLocationManager.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.hideKeyboard))
        self.view.addGestureRecognizer(gesture)
        self.displayResultsButton.isEnabled = false
        self.tableView.backgroundColor = .white
        self.locationField.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func hideKeyboard() {
        self.locationField.resignFirstResponder()
        if let count = self.locationField.text?.count {
            self.displayResultsButton.isEnabled = count > 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let count = textField.text?.count {
            self.displayResultsButton.isEnabled = textField.tag == 0 && count > 0
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.ptResults?.count {
            return count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ptCell", for: indexPath) as? PTCell else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ptCell", for: indexPath)
            return cell
        }
        
        let ptResult = self.ptResults?[indexPath.row]
        
        let ptLocation = self.ptResults?[indexPath.row].location
        
        cell.nameBusinessNameLabel.text = ptResult?.name
        cell.addressLabel.adjustsFontSizeToFitWidth = true
        
        if let rating = ptResult?.rating, let review_count = ptResult?.review_count {
            cell.ratingLabel.text = String(format: "Rating: %.2f", rating)
            cell.numReviewsLabel.text = String(format: "Num of reviews: %i", review_count)
        }
        
        if let address1 = ptLocation?.address1, let city = ptLocation?.city, let state = ptLocation?.state, let zip = ptLocation?.zip_code {
            cell.addressLabel.text = String(format: "%@, %@, %@ %@", address1, city, state, zip)
        }
        
        return cell
    }
    
    func displayResults() {
        self.ptResults?.removeAll()
        self.numPTsInAreaLabel.text = ""
        self.totalPTsWithRatingsLabel.text = ""
        self.avgRatingForPTsLabel.text = ""
        self.totalNumOfReviewsLabel.text = ""
        guard let locationText = self.locationField.text else {
            return
        }
        MBProgressHUD.showIndicator(view: self.view, title: "Loading", description: "Retrieving Results...")
        guard let plist = YelpService.shared.getPList(), let baseURL = plist["Yelp Base URL"]else {
            return
        }
        YelpService.shared.retrieveYelpPTListings(urlStr: baseURL, location: locationText) { (viewModel) in
            self.ptResults = viewModel?.results
            DispatchQueue.main.async {
                guard let numPTsText = self.numPTsInAreaLabel.text, let totalPtsText = self.totalPTsWithRatingsLabel.text, let avgRatingText = self.avgRatingForPTsLabel.text, let totalReviewsText = self.totalNumOfReviewsLabel.text else {
                    return
                }
                if let numPTsInArea = viewModel?.summary?.numPTsInArea, let totalPTsWithRatings = viewModel?.summary?.totalPTsWithRatings, let avgRating = viewModel?.summary?.avgRatingForPTsInArea, let totalReviews = viewModel?.summary?.totalReviews {
                    self.numPTsInAreaLabel.text = numPTsText + String(format: "Number of PTs in the Area: %i", numPTsInArea)
                    self.totalPTsWithRatingsLabel.text = totalPtsText + String(format: "Total PTs with Ratings: %i", totalPTsWithRatings)
                    self.avgRatingForPTsLabel.text = avgRatingText + String(format: "Average Rating for PTs in this Area: %.2f", avgRating)
                    self.totalNumOfReviewsLabel.text = totalReviewsText + String(format: "Total Number of Reviews for the Given Results: %i", totalReviews)
                }
                self.tableView.reloadData()
                MBProgressHUD.hideIndicator(view: self.view)
            }
        }
    }

    @IBAction func displaySearchResults(_ sender: UIButton) {
        self.displayResults()
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        self.locationField.text = self.currentLocation
        self.displayResults()
    }
    
    // LocationManagerDelegate
    func getUpdatedCurrentLocation(location: CLLocation) {
        print(location)
        CLGeocoder().reverseGeocodeLocation(yelpLocationManager.locationManager?.location ?? CLLocation(), completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
               return
            }
        
            if let placemarkCount = placemarks?.count {
                if placemarkCount > 0 {
                    let pm = (placemarks?[0] ?? CLPlacemark()) as CLPlacemark
                    guard let address = pm.thoroughfare, let city = pm.locality, let state = pm.administrativeArea, let zip = pm.postalCode else {
                        return
                    }
                    if let subThoroughFare = pm.subThoroughfare {
                        self.currentLocation = String(format: "%@ %@, %@ %@, %@", subThoroughFare, address, city, state, zip)
                    }
                    else {
                        self.currentLocation = String(format: "%@, %@ %@, %@", address, city, state, zip)
                    }
                } else {
                    print("Problem with the data received from geocoder")
                }
            }
           })
    }
}

