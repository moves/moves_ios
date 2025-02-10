//
//  DatePickerManager.swift
// //
//
//  Created by Macbook Pro on 01/09/2024.
//

import Foundation
import UIKit

class DatePickerManager{
    
    static let sharedInstance = DatePickerManager()
    
    var tf:UITextField?
    var controller:UIViewController?
    var datePicker:UIDatePicker!
    
    func showDatePicker(textField:UITextField){
        tf? = textField
        datePicker!.datePickerMode = .time
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton    = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton   = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton  = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        tf!.inputAccessoryView = toolbar
        tf!.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        let formatter1 = DateFormatter()
        formatter1.dateFormat = showDateFormater
        let selectedDate = "\(formatter1.string(from: datePicker.date))"
//
//        let currentDateTime = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat =  showDateFormater
//        let currentDate =  formatter.string(from: currentDateTime)
//        
//        print("currentDate:\(currentDate)")
//        print("selectedDate:\(selectedDate)")
//        
//        if selectedDate <  currentDate{
//            Utility.showMessage(message: "Please current greater than previous time", on: controller!.view, duration: 0.5, position: .top)
//            return
//        }
        self.tf?.text! = selectedDate
        controller?.view.endEditing(true)
        
    }
    @objc func cancelDatePicker(){
        controller?.view.endEditing(true)
    }
}
