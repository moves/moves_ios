//
//  LocationSettingViewController.swift
// //
//
//  Created by Wasiq Tayyab on 15/08/2024.
//

import UIKit
import CoreLocation

import UIKit
import CoreLocation

class LocationSettingViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and request authorization
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == view {
                dismiss(animated: false, completion: nil)
            }
        }
    }

    @IBAction func settingButtonPressed(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    // CLLocationManagerDelegate method to handle authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // If authorization is granted, dismiss the view controller
            dismiss(animated: true, completion: nil)
        }
    }
}
