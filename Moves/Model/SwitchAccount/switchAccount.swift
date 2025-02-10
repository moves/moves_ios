//
//  switchAccount.swift
//  Infotex
//
//  Created by Mac on 15/09/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation
import UIKit


class switchAccountObject{
    
    var myUser: [switchAccount]? {didSet {}}
    var arrSwitchAccount =  [switchAccount]()
    static let shared = switchAccountObject() //  singleton object
    
    
    func Objresponse(userID:String,username:String,authToken:String,profileUser:String,first_name:String,last_name:String,businessProfile:Int,email:String){
        let user = switchAccount()
        user.Id          =  userID
        user.auth_token  =  authToken
        user.profile_pic =  profileUser
        user.username    =  username
        user.first_name  =  first_name
        user.last_name   =  last_name
        user.businessProfile = businessProfile
        user.email      = email
        
        self.myUser = switchAccount.readswitchAccountFromArchive()
        if myUser?.count == 0 || self.myUser == nil{
            self.myUser = [user]
            if switchAccount.saveswitchAccountToArchive(switchAccount: self.myUser!) {
                print("Switch Account Saved One Object in Directory")
            }
        }else{
            self.myUser?.append(user)
            if switchAccount.saveswitchAccountToArchive(switchAccount: self.myUser!) {
                print("Switch Account Saved multiple Object in Directory")
            }
        }
        print("switch user count",self.myUser?.count)
    }
}

class switchAccount:NSObject, NSCoding {
    
    var Id:String?
    var auth_token :String?
    var profile_pic :String?
    var username:String?
    var first_name:String?
    var last_name :String?
    var businessProfile :Int?
    var email :String?

    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
     
        self.Id = aDecoder.decodeObject(forKey: "id") as? String
        self.auth_token = aDecoder.decodeObject(forKey: "auth_token") as? String
        self.username = aDecoder.decodeObject(forKey: "username") as? String
        self.first_name = aDecoder.decodeObject(forKey: "first_name") as? String
        self.last_name = aDecoder.decodeObject(forKey: "last_name") as? String
        self.profile_pic = aDecoder.decodeObject(forKey: "profile_pic") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.businessProfile = aDecoder.decodeObject(forKey: "businessProfile") as? Int
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.Id, forKey: "id")
        aCoder.encode(self.auth_token, forKey: "auth_token")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.first_name, forKey: "first_name")
        aCoder.encode(self.last_name, forKey: "last_name")
        aCoder.encode(self.profile_pic, forKey: "profile_pic")
        aCoder.encode(self.businessProfile, forKey: "businessProfile")
        aCoder.encode(self.email, forKey: "email")
        
    
    }

    //MARK: Archive Methods
    class func archiveFilePath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("MultipleAccount.archive").path
    }
    
    class func readswitchAccountFromArchive() -> [switchAccount]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath()) as? [switchAccount]
    }
    
    class func saveswitchAccountToArchive(switchAccount: [switchAccount?]) -> Bool {
        return NSKeyedArchiver.archiveRootObject(switchAccount, toFile: archiveFilePath())
    }
    
}
