//
//  DobViewController.swift
//  Movess
//
//  Created by Mac on 16/10/2022.
//

import UIKit

class DobViewController: UIViewController {
    //MARK: - OUTLET
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var btnNext: UIButton!
    
    let minimum_age: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    var dob = ""
    var phone: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dobSetup()
    }
    
    //MARK: - FUNCTION
    
    func dobSetup(){
        dobDatePicker.maximumDate = minimum_age
        dobDatePicker.datePickerMode = .date
        dobDatePicker.addTarget(self, action: #selector(dobDateChanged(_:)), for: .valueChanged)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dob = dateFormatter.string(from: minimum_age)
    }
    
    
    //MARK: - BUTTON ACTION
    
    @objc func dobDateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        print(dateFormatter.string(from: sender.date))
        dob = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnNext(_ sender: Any) {
        let userName = UserNameController(nibName: "UserNameController", bundle: nil)
        userName.birthday = dob
        userName.phone = phone
        self.navigationController?.pushViewController(userName, animated: true)
    }
    

    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
