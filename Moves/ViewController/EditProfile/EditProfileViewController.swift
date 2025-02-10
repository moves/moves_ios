//
//  EditProfileViewController.swift
// //
//
//  Created by Eclipse on 11/06/2024.
//

import UIKit
import SDWebImage
import QCropper
import AVFoundation
import FirebaseStorage
import SVProgressHUD
class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var profileResponse : ProfileResponse?
    var originalImage: UIImage?
    var cropperState: CropperState?
    let viewModel = EditProfileViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    var profilePicData = ""
    var videoURL : URL!
    var imagePicker = UIImagePickerController()
    var exportSession: AVAssetExportSession!
    
    var isImage = false
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var tfBio: CustomTextField!
    @IBOutlet weak var tfAddLink: CustomTextField!
    @IBOutlet weak var tfUsername: CustomTextField!
    @IBOutlet weak var tfName: CustomTextField!
    @IBOutlet weak var imgPhoto: CustomImageView!
    @IBOutlet weak var tfLastName: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                view.endEditing(true)
            }
        }
    }
 
    private func setup() {
        let user = profileResponse?.msg?.user
        tfBio.text = user?.bio
        tfAddLink.text = user?.website
        tfUsername.text = user?.username
        tfName.text = (user?.firstName ?? "")
        tfLastName.text = user?.lastName ?? ""
        self.imgPhoto.sd_setImage(with: URL(string: user?.profilePic ?? ""), placeholderImage: UIImage(named: "Add photo"))
        if user?.profilePic == ""{
            self.imgPhoto.cornarRadius = 0
        }else {
            self.imgPhoto.cornarRadius = 50
        }
       
    }
    
    // MARK: - ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[.originalImage] as? UIImage) else { return }
        
        originalImage = image
        let cropper = CropperViewController(originalImage: image)
        
        cropper.delegate = self
        
        picker.dismiss(animated: true) {
            self.present(cropper, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Photo Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = ["public.image"]
            self.imagePicker.allowsEditing = false
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        
        let lastName = tfLastName.text!
        let name = tfName.text!
        let username = tfUsername.text!
        let website = tfAddLink.text!
        let bio = tfBio.text!
        
        if name.isEmpty {
            Utility.showMessage(message: "Enter your First Name", on: self.view)
            return
        }
        
        if lastName.isEmpty {
            Utility.showMessage(message: "Enter your Last Name", on: self.view)
            return
        }
        
        if username.count < 3 {
            Utility.showMessage(message: "username must be greater than 3", on: self.view)
            return
        }
        
        if website.count > 0 {
            var formattedWebsite = website
            
            if !formattedWebsite.isEmpty {
                if !formattedWebsite.lowercased().hasPrefix("http://") && !formattedWebsite.lowercased().hasPrefix("https://") {
                    formattedWebsite = "http://" + formattedWebsite
                }
                
                if !isValidURL(formattedWebsite) {
                    Utility.showMessage(message: "Enter a valid website URL", on: self.view)
                    
                    return
                }
            }
        }
        
        self.isImage = true
        
        self.loader.isHidden = false
        let editProfile = EditProfileRequest(firstName: name, lastName: lastName, gender: nil, website: website, bio: bio, phone: nil, email: nil, username: username, profileImage: nil)
        viewModel.editProfile(parameters: editProfile)
        print("editProfile",editProfile)
        self.observeEvent1()
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isValidURL(_ urlString: String) -> Bool {
        let regex = "((?:http|https)://)?(?:www\\.)?[a-zA-Z0-9./]+\\.[a-zA-Z]{2,6}(?:/[a-zA-Z0-9#]+/?)*"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return urlTest.evaluate(with: urlString)
    }
    
}

extension EditProfileViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)
        
        guard let state = state,
              let image = cropper.originalImage.cropped(withCropperState: state) else {
            return
        }

        cropperState = state
        imgPhoto.contentMode = .scaleAspectFill
        self.imgPhoto.image = image
        self.imgPhoto.layer.cornerRadius = 50.0
        
        let authtoken = UserDefaultsManager.shared.authToken

        uploadImageToFirebase(image: image, authtoken: authtoken) { result in
            switch result {
            case .success(let downloadURL):
                print("Upload successful. Download URL: \(downloadURL.absoluteString)")
                let editProfile = EditProfileRequest(
                    firstName: nil,
                    lastName: nil,
                    gender: nil,
                    website: nil,
                    bio: nil,
                    phone: nil,
                    email: nil,
                    username: nil,
                    profileImage: downloadURL.absoluteString
                )

                self.viewModel.editProfile(parameters: editProfile)
                self.observeEvent1()
            case .failure(let error):
                print("Upload failed: \(error.localizedDescription)")
            }
        }
  
    }
    
    func uploadImageToFirebase(image: UIImage, authtoken: String, completion: @escaping (Result<URL, Error>) -> Void) {
        SVProgressHUD.show(withStatus: "Uploading image...")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            SVProgressHUD.dismiss()
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let fileName = "profileImage.jpeg"
        let imageRef = storageRef.child("vendor/\(authtoken)/\(fileName)")
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                SVProgressHUD.dismiss()
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    SVProgressHUD.dismiss()
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    SVProgressHUD.dismiss()
                    return
                }
                
                completion(.success(downloadURL))
                SVProgressHUD.dismiss()
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress!.fractionCompleted)
            SVProgressHUD.showProgress(Float(progress), status: "Uploading image...")
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                SVProgressHUD.showError(withStatus: "Upload failed: \(error.localizedDescription)")
            }
        }
    }

  
    func observeEvent1() {
        self.loader.isHidden = true
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error ?? "")
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network(_):
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding(_):
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .newEditProfile(editProfile: let editProfile):
                if editProfile.code == 200 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("changeNumber"), object: nil, userInfo: nil)
                        NotificationCenter.default.post(name: NSNotification.Name("changeProfile"), object: nil, userInfo: nil)
                    
                        if self.isImage {
                            Utility.showMessage(message: "Profile Updated.", on: self.view)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        Utility.showMessage(message: editProfile.message ?? "", on: self.view)
                    }
                }
            }
        }
    }
}

