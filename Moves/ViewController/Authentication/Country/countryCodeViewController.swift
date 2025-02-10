//
//  countryCodeViewController.swift
//
//
//  Created by Junaid  Kamoka on 11/11/2020.
//  Copyright © 2020 Junaid Kamoka. All rights reserved.
//

import UIKit

class countryCodeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var tblCountry: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var constarintViewContainerTop: NSLayoutConstraint!
    
    var arrCountry = [[String:Any]]()
    var arrSearch = [[String:Any]]()
    var isSearching = false
    var isCodeShow = true
    
    var countryDictionary = [String:[[String:String]]]()
    var countrySectionTitles = [String]()
    
    //MARK:- View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tblCountry.layoutMargins = UIEdgeInsets.zero
        self.tblCountry.separatorInset = UIEdgeInsets.zero
        
        tblCountry.delegate = self
        tblCountry.dataSource = self
        
        newGetCountryCodes()
        
    }
    
    
    func newGetCountryCodes(){
        if let path = Bundle.main.path(forResource: "countryCodeWithFlags", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String:String]] {
                    
                    for jsonObj in jsonResult{
                        print("jsonObj: ",jsonObj)
                        
                        let cKey = String((jsonObj["name"]?.prefix(1))!)
                        let code = String(jsonObj["dial_code"]!)
                        print("cKey: ",cKey)

                        if code.isEmpty == false{
                            if var cValues = countryDictionary[cKey]{
                                cValues.append(jsonObj)
                                countryDictionary[cKey] = cValues
                            }else{
                                countryDictionary[cKey] = [jsonObj]
                            }

                        }
                        
                    }
                    
                    countrySectionTitles = [String](countryDictionary.keys)
                    countrySectionTitles = countrySectionTitles.sorted(by: { $0 < $1 })
                    //                    self.arrCountry = jsonResult
                    self.tblCountry.reloadData()
                }
            } catch {
                // handle error
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(self.tfSearch.text!)
        
        if Utility.shared.isEmpty(self.tfSearch.text!){
            self.isSearching = false
            self.arrSearch.removeAll()
        }else{
            self.isSearching = true
            self.arrSearch.removeAll()
            for obj in self.arrCountry{
                let strName = obj["name"] as! String
                if strName.range(of: self.tfSearch.text!, options: .caseInsensitive) != nil{
                    self.arrSearch.append(obj)
                }
            }
        }
        
        self.tblCountry.reloadData()
    }
    //MARK:- Setup View
    func setupView() {
        self.tblCountry.rowHeight = 44
        self.tfSearch.becomeFirstResponder()
        //        self.setContainer()
    }
    
    
    //MARK:- Button Action
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countrySectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView.backgroundColor = .white
        
        return countrySectionTitles[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        tableView.tintColor = #colorLiteral(red: 0.490213871, green: 0.5138357282, blue: 0.5441090465, alpha: 1)
        return countrySectionTitles
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

            let view = UIView()
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let lbl = UILabel(frame: CGRect(x: 10,y: 2,width: self.view.frame.size.width,height: 40))
            lbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            lbl.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            lbl.text = countrySectionTitles[section]
        lbl.font = .boldSystemFont(ofSize: 18)
            view.addSubview(lbl)
            
            return view

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let cKey = countrySectionTitles[section]
        if let cValues = countryDictionary[cKey] {
            return cValues.count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCodeTVC", for: indexPath) as! countryCodeTableViewCell
        
        
        
        let cKey = countrySectionTitles[indexPath.section]
        if let cValues = countryDictionary[cKey] {
            
            let code = cValues[indexPath.row]["dial_code"]
            
            if code?.isEmpty == false{
                cell.lblCountry?.text = cValues[indexPath.row]["name"]
                cell.codeCountry.text = code!
            }
            
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cKey = countrySectionTitles[indexPath.section]
        if let cValues = countryDictionary[cKey] {
            
            let valueSet = cValues[indexPath.row]
            print("valueSet: ",valueSet)

            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countryDataNoti"), object: nil, userInfo: valueSet)

            self.dismiss(animated: true, completion: nil)
        }

    }
   
}
extension String {
    func imageUnicode() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
