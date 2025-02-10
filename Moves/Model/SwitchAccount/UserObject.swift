//
//  UserObject.swift
//
// //
//
//  Created by Mac on 01/08/2024.
//  Copyright © 2021 Mac. All rights reserved.


import Foundation
import UIKit


class UserObject{
    
    static let shared = UserObject() //  singleton object
    var mySwitchAccount: [switchAccount]? {didSet {}}
    
    init(mySwitchAccount: [switchAccount]? = nil) {
        self.mySwitchAccount = mySwitchAccount
    }
    
    func loginUser(res:ProfileResponseMsg?){

        let user = res?.user
        let store = res?.store
        let logo = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.profilePic ?? "" : store?.logoPhotos ?? ""
        let first_name = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.firstName ?? "" : store?.name ?? ""
        let last_name  = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.lastName  ?? "" :  ""

        
        UserObject.shared.Objresponse(userID:user?.id?.toString() ?? "",username:user?.username ?? "",authToken:user?.auth_token ?? "",profileUser:logo,first_name: first_name ,last_name:last_name , isLogin: false, businessProfile: UserDefaultsManager.shared.business.toInt() ?? 0,email:user?.email ?? "")
    }
    func Objresponse(userID:String,username:String,authToken:String,profileUser:String,first_name:String,last_name:String,isLogin:Bool,businessProfile:Int,email:String){
       
        print("auth_token",authToken)
        print("businessProfile",businessProfile)
        print("profileUser",profileUser)
        print("login id ",UserDefaultsManager.shared.user_id)
        
        var isFound =  false
        self.mySwitchAccount = switchAccount.readswitchAccountFromArchive()
        if self.mySwitchAccount != nil && self.mySwitchAccount?.count != 0 {
            print(self.mySwitchAccount?.count)
            for var i in 0..<self.mySwitchAccount!.count{
                var obj = self.mySwitchAccount![i]
                print(obj.Id)
                print(UserDefaultsManager.shared.user_id)
                if  obj.Id ==  UserDefaultsManager.shared.user_id{
                    isFound = true
                    break
                }
            }
            if isFound == false{
                switchAccountObject.shared.Objresponse(userID:userID,username:username,authToken:authToken,profileUser:profileUser,first_name: first_name,last_name:last_name,businessProfile: businessProfile, email: email)
            }
        }else{
            switchAccountObject.shared.Objresponse(userID:userID,username:username,authToken:authToken,profileUser:profileUser,first_name: first_name,last_name:last_name,businessProfile: businessProfile, email: email)
        }
        
    }
    
    
    func updateProfilePic(profile:ProfileResponse,isStore:Bool = false){
        self.mySwitchAccount = switchAccount.readswitchAccountFromArchive()
        if self.mySwitchAccount != nil && self.mySwitchAccount?.count != 0 {
            for var i in 0..<self.mySwitchAccount!.count{
                var obj = self.mySwitchAccount![i]
                print(obj.Id)
                print( UserDefaultsManager.shared.user_id)
                if obj.Id ==  UserDefaultsManager.shared.user_id{
                    let user  = profile.msg?.user
                    let store = profile.msg?.store
                    let logo = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.profilePic ?? "" : store?.logoPhotos ?? ""
                    let first_name = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.firstName ?? "" : store?.name ?? ""
                    let last_name  = UserDefaultsManager.shared.business.toInt() ==  0 ? user?.lastName  ?? "" :  ""
                    
                    obj.profile_pic = logo
                    obj.first_name = first_name
                    obj.last_name = last_name
                    
                    if switchAccount.saveswitchAccountToArchive(switchAccount: self.mySwitchAccount!){
                        print("profile pic update")
                    }
                }
            }
        }
    }
}

