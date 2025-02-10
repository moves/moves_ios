//
//  FirebaseAuthService.swift
// //
//
//  Created by Wasiq Tayyab on 11/06/2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseAuthService {
    
    static let shared = FirebaseAuthService()
    
    private init() { }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(authResult, error)
        }
    }
    
    func signOut(completion: @escaping (Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch let signOutError as NSError {
            completion(false, signOutError)
        }
    }
    
    func createUser(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            completion(authResult, error)
        }
    }
    
    func resetPassword(forEmail email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (String?, Error?) -> Void) {
        Auth.auth().languageCode = Locale.current.languageCode // Set the language code if you want to customize SMS messages
        Auth.auth().settings!.isAppVerificationDisabledForTesting = false // For testing purposes only
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            completion(verificationID, error)
        }
    }
    
    func createPhoneAuthCredential(verificationID: String, verificationCode: String) -> PhoneAuthCredential {
        return PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
    }
    
    func signIn(withPhoneAuthCredential credential: PhoneAuthCredential, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            completion(authResult, error)
        }
    }
    
    func sendEmailVerification(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."]))
            return
        }
        
        user.sendEmailVerification { error in
            completion(error)
        }
    }
    
    // Update Password
    func updatePassword(newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."]))
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            completion(error)
        }
    }
    
    // Update Email
    func updateEmail(newEmail: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."]))
            return
        }
        
        user.updateEmail(to: newEmail) { error in
            completion(error)
        }
    }
    
    func updatePhoneNumber(credential: PhoneAuthCredential, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."]))
            return
        }
        
        user.updatePhoneNumber(credential) { error in
            completion(error)
        }
    }
    
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
            completion(error)
            return
        }
        
        user.delete { error in
            completion(error)
        }
    }
}
