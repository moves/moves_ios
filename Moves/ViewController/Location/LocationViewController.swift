//
//  LocationPageViewController.swift
// //
//
//  Created by iMac on 12/06/2024.
//

import UIKit
import CoreLocation
class LocationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate  {
   
    var callback: ((_ placeId: String, _ string_Location: String, _ addressPlaces: AddressPlacesModel, _ status: String,_ lat:String, _ lng:String) -> Void)?
    var addressPlaces: [AddressPlacesModel] = []
    
    private let locationManager = CLLocationManager()
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var searchLocation: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchLocation.delegate = self
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        
        locationManager.delegate = self
               locationManager.requestWhenInUseAuthorization()
               locationManager.startUpdatingLocation()
        
        fetchNearbyPlaces()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view || touch.view == self.locationTableView{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchPlaces(query: searchText)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchNearbyPlaces()
        }
    }
 
    private func getPlaceId(for location: CLLocationCoordinate2D) {
        GeocodingService.shared.getPlaceId(for: location) { result in
            switch result {
            case .success(let placeId):
                GeocodingService.shared.getPlaceDetails(for: placeId) { result in
                    switch result {
                    case .success(let placeTitle):
                        print("Place Title: \(placeTitle)")

                        let emptyAddressPlace = AddressPlacesModel(title: "", address: "", placeId: placeId, latLng: location, lat: location.latitude, lng: location.longitude,city:"", country:"", state:"", zipCode:"0")
                        
                        let place = placeTitle.0 + " " + placeTitle.1
                        self.callback?(placeId, place, emptyAddressPlace, "placeid", location.latitude.toString(), location.longitude.toString())
                        
                    case .failure(let error):
                        print("Failed to get place title: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to get place ID: \(error)")
            }
        }
    }

    func fetchNearbyPlaces() {
        let latitude = UserDefaultsManager.shared.latitude
        let longitude = UserDefaultsManager.shared.longitude
        
        let query = "\(latitude),\(longitude)"
        
        GeocodingService.shared.searchPlaces(query: query) { [weak self] places, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching nearby places: \(error.localizedDescription)")
                return
            }
            
            if let places = places {
                print("Received nearby places: \(places)")
                self.addressPlaces = places
                DispatchQueue.main.async {
                    self.locationTableView.reloadData()
                }
            }
        }
    }

    
    func searchPlaces(query: String) {
        GeocodingService.shared.searchPlaces(query: query) { [weak self] places, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error searching places: \(error.localizedDescription)")
                // Handle error appropriately, e.g., show an alert to the user
                return
            }
            
            if let places = places {
                print("Received search places: \(places)")
                self.addressPlaces = places
                DispatchQueue.main.async {
                    self.locationTableView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
         if let location = locationManager.location?.coordinate {
             getPlaceId(for: location)
         }
        self.dismiss(animated: true)

     }
    
    
    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath)as! LocationTableViewCell
        let place = addressPlaces[indexPath.row]
        cell.lblLocationName.text = place.title
        cell.lblLocation.text = place.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = addressPlaces[indexPath.row]
        self.callback?("", "", place,"address","","")
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }

    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        print("Current location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
