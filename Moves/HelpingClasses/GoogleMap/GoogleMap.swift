//
//  GoogleMap.swift
// //
//
//  Created by Wasiq Tayyab on 07/07/2024.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class GeocodingService {
    
    static let shared = GeocodingService()
    
    public let googleMapsAPIKey = "AIzaSyAtAGvcUDb0vNc8msxJRGOk34sEx-zyWPo"
    
    func getPlaceId(for location: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        let latlng = "\(location.latitude),\(location.longitude)"
        let geocodingApiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latlng)&key=\(googleMapsAPIKey)"
        print("geocodingApiUrl",geocodingApiUrl)
        guard let url = URL(string: geocodingApiUrl) else {
            completion(.failure(GeocodingError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(GeocodingError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let response = json {
                    if let results = response["results"] as? [[String: Any]], !results.isEmpty {
                        if let placeId = results[0]["place_id"] as? String {
                            completion(.success(placeId))
                            return
                        }
                    }
                }
                
                completion(.failure(GeocodingError.noPlaceId))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getPlaceDetails(for placeId: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        let placeDetailsApiUrl = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(googleMapsAPIKey)"
        
        guard let url = URL(string: placeDetailsApiUrl) else {
            completion(.failure(GeocodingError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(GeocodingError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let response = json, let result = response["result"] as? [String: Any] {
                    if let placeTitle = result["name"] as? String,
                       let address = result["formatted_address"] as? String {
                        completion(.success((placeTitle, address)))
                        return
                    }
                }
                
                completion(.failure(GeocodingError.noPlaceId))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func searchPlaces(query: String, completion: @escaping ([AddressPlacesModel]?, Error?) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: Unable to encode query")
            completion(nil, GeocodingError.invalidURL)
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedQuery)&key=\(googleMapsAPIKey)"
        print("urlString:", urlString)
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            completion(nil, GeocodingError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Data task error - \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                completion(nil, GeocodingError.noData)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let predictions = json["predictions"] as? [[String: Any]] else {
                    print("Error: Invalid JSON response")
                    completion(nil, GeocodingError.invalidResponse)
                    return
                }
                
                var tempList = [AddressPlacesModel]()
                let dispatchGroup = DispatchGroup()
                
                for prediction in predictions {
                    guard let placeId = prediction["place_id"] as? String,
                          let description = prediction["description"] as? String else {
                        print("Error: Missing data in prediction")
                        continue
                    }
                    
                    dispatchGroup.enter()
                    
                    self.fetchPlaceDetails(placeId: placeId) { placeDetail, error in
                        if let placeDetail = placeDetail {
    
                            var detailedPlace = placeDetail
                            detailedPlace.title = description
                            tempList.append(detailedPlace)
                        } else {
                            print("Error fetching place details: \(String(describing: error))")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(tempList, nil)
                }
                
            } catch {
                print("Error: Failed to parse JSON - \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchPlaceDetails(placeId: String, completion: @escaping (AddressPlacesModel?, Error?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(googleMapsAPIKey)"
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            completion(nil, GeocodingError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Data task error - \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                completion(nil, GeocodingError.noData)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let result = json["result"] as? [String: Any],
                      let geometry = result["geometry"] as? [String: Any],
                      let location = geometry["location"] as? [String: Any],
                      let lat = location["lat"] as? Double,
                      let lng = location["lng"] as? Double,
                      let address_components = result["address_components"] as? [[String:Any]],
                      let address = result["formatted_address"] as? String else {
                    print("Error: Invalid JSON response")
                    completion(nil, GeocodingError.invalidResponse)
                    return
                }
                
                print("url=====\(url)======json===========\(json)")
                
                var country = ""
                var state = ""
                var city = ""
                var postalCode = ""
                
                for obj in address_components{
                    if let typ = obj["types"] as? [String]{
                        if typ.contains("country"){
                            country = obj["long_name"] as? String ?? ""
                        }
                        if typ.contains("administrative_area_level_1"){
                            state = obj["long_name"] as? String ?? ""
                        }
                        if typ.contains("administrative_area_level_2"){
                            city = obj["long_name"] as? String ?? ""
                        }
                        if typ.contains("postal_code"){
                            postalCode = obj["long_name"] as? String ?? "0"
                        }
                    }
                    
                }
                
                let addressPlace = AddressPlacesModel(
                    title: address,
                    address: address,
                    placeId: placeId,
                    latLng: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    lat: lat,
                    lng: lng,
                    city: city,
                    country: country,
                    state: state,
                    zipCode: postalCode
                    
                )
                
                completion(addressPlace, nil)
            } catch {
                print("Error: Failed to parse JSON - \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }

    func getDirectionApi(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Result<(coordinates: [CLLocationCoordinate2D], distanceByCar: String, distanceByWalk: String, durationByCar: String, durationByWalk: String), Error>) -> Void) {
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        
        let directionsApiUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=\(googleMapsAPIKey)"
        let walkingDirectionsApiUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&mode=walking&key=\(googleMapsAPIKey)"
    
        guard let drivingUrl = URL(string: directionsApiUrl), let walkingUrl = URL(string: walkingDirectionsApiUrl) else {
            completion(.failure(GeocodingError.invalidURL))
            return
        }
        
        var drivingCoordinates = [CLLocationCoordinate2D]()
        var drivingDistance = "N/A"
        var drivingDuration = "N/A"
        
        var walkingCoordinates = [CLLocationCoordinate2D]()
        var walkingDistance = "N/A"
        var walkingDuration = "N/A"
        
        let group = DispatchGroup()
        var drivingError: Error?
        var walkingError: Error?
        
        // Fetch driving directions
        group.enter()
        URLSession.shared.dataTask(with: drivingUrl) { data, response, error in
            defer { group.leave() }
            if let error = error {
                drivingError = error
                return
            }
            
            guard let data = data else {
                drivingError = GeocodingError.noData
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let legs = route["legs"] as? [[String: Any]],
                   let leg = legs.first {
                    
                    if let steps = leg["steps"] as? [[String: Any]] {
                        for step in steps {
                            if let polyline = step["polyline"] as? [String: Any],
                               let points = polyline["points"] as? String,
                               let path = GMSPath(fromEncodedPath: points) {
                                for index in 0..<path.count() {
                                    drivingCoordinates.append(path.coordinate(at: index))
                                }
                            }
                        }
                    }
                    
                    if let distance = leg["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                        drivingDistance = self.convertToMiles(distanceText: distanceText)
                    }
                    
                    if let duration = leg["duration"] as? [String: Any], let durationText = duration["text"] as? String {
                        drivingDuration = durationText
                    }
                }
            } catch {
                drivingError = error
            }
        }.resume()
        
        // Fetch walking directions
        group.enter()
        URLSession.shared.dataTask(with: walkingUrl) { data, response, error in
            defer { group.leave() }
            if let error = error {
                walkingError = error
                return
            }
            
            guard let data = data else {
                walkingError = GeocodingError.noData
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let legs = route["legs"] as? [[String: Any]],
                   let leg = legs.first {
                    
                    if let steps = leg["steps"] as? [[String: Any]] {
                        for step in steps {
                            if let polyline = step["polyline"] as? [String: Any],
                               let points = polyline["points"] as? String,
                               let path = GMSPath(fromEncodedPath: points) {
                                for index in 0..<path.count() {
                                    walkingCoordinates.append(path.coordinate(at: index))
                                }
                            }
                        }
                    }
                    
                    if let distance = leg["distance"] as? [String: Any], let distanceText = distance["text"] as? String {
                        walkingDistance = self.convertToMiles(distanceText: distanceText)
                    }
                    
                    if let duration = leg["duration"] as? [String: Any], let durationText = duration["text"] as? String {
                        walkingDuration = durationText
                    }
                }
            } catch {
                walkingError = error
            }
        }.resume()
        
        // Wait for both tasks to complete
        group.notify(queue: .main) {
            if let drivingError = drivingError {
                completion(.failure(drivingError))
            } else if let walkingError = walkingError {
                completion(.failure(walkingError))
            } else {
                completion(.success((coordinates: drivingCoordinates, distanceByCar: drivingDistance, distanceByWalk: walkingDistance, durationByCar: drivingDuration, durationByWalk: walkingDuration)))
            }
        }
    }


    private func convertToMiles(distanceText: String) -> String {
        let distanceComponents = distanceText.split(separator: " ")
        guard distanceComponents.count == 2, let distanceValue = Double(distanceComponents[0]), distanceComponents[1] == "km" else {
            return distanceText
        }
        
        let distanceInMiles = distanceValue * 0.621371
        return String(format: "%.2f miles", distanceInMiles)
    }
    
    func searchPlaces(query: String, latitude: Double, longitude: Double, completion: @escaping (Result<[AddressPlacesModel], Error>) -> Void) {
        let apiKey = googleMapsAPIKey
        let urlString = "https://places.googleapis.com/v1/places:searchText"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let requestBody: [String: Any] = [
            "textQuery": query,
            "pageSize":20,
            "locationBias":[
                "circle":[
                    "radius":10000,
                    "center":[
                        "latitude":latitude,
                        "longitude":longitude
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Failed to serialize JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue("places.id,places.displayName,places.formattedAddress,places.location,places.addressComponents,places.adrFormatAddress,places.shortFormattedAddress", forHTTPHeaderField: "X-Goog-FieldMask")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let places = json["places"] as? [[String: Any]] else {
                    completion(.failure(GeocodingError.invalidResponse))
                    return
                }
                print("json======\(json)")
                var placess = [AddressPlacesModel]()
                
                for place in places {
                    
                    var country = ""
                    var state = ""
                    var city = ""
                    var postalCode = ""
                    var line1 = ""
                    
                    guard let location = place["location"] as? [String: Any],
                    let placeId = place["id"] as? String,
                    let lat = location["latitude"] as? Double,
                    let lng = location["longitude"] as? Double,
                    let addressComponents = place["addressComponents"] as? [[String:Any]],
                    let displayName = place["displayName"] as? [String: Any],
                    let shortFormattedAddress = place["shortFormattedAddress"] as? String,
                    let formattedAddress = place["formattedAddress"] as? String,
                    let title = displayName["text"] as? String else {
                        break
                    }
                    
                    for obj in addressComponents {
                        if let typ = obj["types"] as? [String]{
                            if typ.contains("country"){
                                country = obj["shortText"] as? String ?? ""
                            }
                            if typ.contains("administrative_area_level_1"){
                                state = obj["shortText"] as? String ?? ""
                            }
                            if typ.contains("administrative_area_level_2"){
                                city = obj["shortText"] as? String ?? ""
                            }
                            if typ.contains("postal_code"){
                                postalCode = obj["shortText"] as? String ?? ""
                            }
                        }
                    }
                    
                    var sliceAddresses = formattedAddress.components(separatedBy: ",")
                    if sliceAddresses.count > 0 {
                        line1 = sliceAddresses.first ?? ""
                    }

                    let addressPlace = AddressPlacesModel(
                        title: title,
                        address: shortFormattedAddress,
                        placeId: placeId,
                        latLng: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                        lat: lat,
                        lng: lng,
                        city: city,
                        country: country,
                        state: state,
                        zipCode: postalCode,
                        line1: line1
                    )
                    placess.append(addressPlace)
                }
                
                completion(.success(placess))
                
                
            } catch {
                print("Failed to parse JSON response: \(error)")
            }
        }
        
        task.resume()
    }
}

enum GeocodingError: Error {
    case invalidURL
    case noData
    case noPlaceId
    case invalidResponse
    case invalidSearchQuery
}

struct AddressPlacesModel {
    var title: String
    var address: String
    var placeId: String
    var latLng: CLLocationCoordinate2D
    var lat: Double
    var lng: Double
    var city: String
    var country: String
    var state:String
    var zipCode: String
    var line1: String?
}
