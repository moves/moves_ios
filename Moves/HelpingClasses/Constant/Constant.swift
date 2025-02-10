//
//  Constant.swift
// //
//
//  Created by Wasiq Tayyab on 05/05/2024.
//

import Foundation
import UIKit
import FirebaseAuth

var isRepesponseShow = false
var profileImage = ""
var isDebug = false
let LISTEN_FOR_VIDEO_PROCESSING_PROGRESS = "LISTEN_FOR_VIDEO_PROCESSING_PROGRESS"
var appleCredential: OAuthCredential?
var googleCredential: AuthCredential?
var facebookCredential : AuthCredential?
var transitionDurationStepper = 0.25
var firebase_video_url:URL?


var showDateFormater = "hh:mm a"  //Show formter in textfield
var showTimeFormater =  "MM/dd/yyyy"


extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleDisplayName"] as? String {
            return version
        } else {
            return ""
        }
    }
}

extension String {
    func createRangeinaLink(of findword1 : String) -> NSRange {
        let range = (self as NSString).range(of: findword1, options: .caseInsensitive)
        return range
    }
}

//extension UILabel {
//    func setTextWithImages(leftImage: UIImage?, rightImage: UIImage?, text: String, viewWidth: CGFloat) {
//        let imageSize = CGSize(width: 15, height: 15)
//        let textBaselineOffset: CGFloat = 2.0
//
//        let attributedString = NSMutableAttributedString()
//        let space = NSAttributedString(string: " ")
//
//        // Add left image if available
//        if let leftImage = leftImage {
//            let leftAttachment = NSTextAttachment()
//            leftAttachment.image = resizeImage(image: leftImage, targetSize: imageSize)
//            let leftImageAttrString = NSAttributedString(attachment: leftAttachment)
//            attributedString.append(leftImageAttrString)
//            attributedString.append(space)
//        }
//
//        // Add text
//        let textAttrString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.baselineOffset: textBaselineOffset])
//        attributedString.append(textAttrString)
//
//        // Add space before the right image
//        attributedString.append(space)
//
//        // Add right image if available
//        if let rightImage = rightImage {
//            let rightAttachment = NSTextAttachment()
//            rightAttachment.image = resizeImage(image: rightImage, targetSize: imageSize)
//            let rightImageAttrString = NSAttributedString(attachment: rightAttachment)
//            attributedString.append(rightImageAttrString)
//        }
//
//        self.numberOfLines = 1
//        self.textAlignment = .center
//        self.lineBreakMode = .byTruncatingTail
//
//        let totalImageWidth = (leftImage != nil ? imageSize.width : 0) + (rightImage != nil ? imageSize.width : 0) + space.size().width * 2
//        let availableWidth = viewWidth - totalImageWidth - 15  // Adjusting to ensure space for images
//
//        // Calculate the text width
//        let textWidth = textAttrString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height), options: .usesLineFragmentOrigin, context: nil).width
//
//        if textWidth > availableWidth {
//            var truncatedText = text
//            var mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
//
//            // Truncate the text until it fits the available width
//            while textWidth > availableWidth, !truncatedText.isEmpty {
//                let endIndex = truncatedText.index(truncatedText.endIndex, offsetBy: -1)
//                truncatedText = String(truncatedText[..<endIndex])
//                let truncatedAttrString = NSMutableAttributedString(string: truncatedText, attributes: [NSAttributedString.Key.baselineOffset: textBaselineOffset])
//
//                let textRange = NSRange(location: attributedString.length - textAttrString.length, length: textAttrString.length)
//
//                if textRange.location + textRange.length <= mutableAttributedString.length {
//                    mutableAttributedString.replaceCharacters(in: textRange, with: truncatedAttrString)
//                }
//
//                let newTextWidth = mutableAttributedString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height), options: .usesLineFragmentOrigin, context: nil).width
//
//                if newTextWidth <= availableWidth {
//                    break
//                }
//            }
//
//            self.attributedText = mutableAttributedString
//        } else {
//            self.attributedText = attributedString
//        }
//    }
//
//    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
//        let size = image.size
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//        let newSize: CGSize
//
//        if widthRatio > heightRatio {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
//        }
//
//        let rect = CGRect(origin: .zero, size: newSize)
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        image.draw(in: rect)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage
//    }
//}

extension UILabel {
    func setTextWithImages(leftImage: UIImage?, rightImage: UIImage?, text: String, viewWidth: CGFloat, rightImageView: UIImageView) {
        let imageSize = CGSize(width: 15, height: 15)
        let rightImageSize = CGSize(width: 16, height: 10)
        let attributedString = NSMutableAttributedString()
        let space = NSAttributedString(string: " ")

        // Add left image if available
        if let leftImage = leftImage {
            let leftAttachment = NSTextAttachment()
            leftAttachment.image = resizeImage(image: leftImage, targetSize: imageSize)
            // Ensure the image size remains constant
            leftAttachment.bounds = CGRect(x: 0, y: (self.font.capHeight - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
            let leftImageAttrString = NSAttributedString(attachment: leftAttachment)
            attributedString.append(leftImageAttrString)
            
            // Add extra spacing after the left image
            let spacer = NSAttributedString(string: String(repeating: " ", count: Int(1.5)))
            attributedString.append(spacer)
        }
        
        // Add text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: self.font!
        ]
        let textAttrString = NSAttributedString(string: text, attributes: textAttributes)
        attributedString.append(textAttrString)
        
        // Add space before the right image
        attributedString.append(space)
        
        // Add right image if available
        if let rightImage = rightImage {
            let rightAttachment = NSTextAttachment()
            rightAttachment.image = resizeImage(image: rightImage, targetSize: rightImageSize)
            rightAttachment.bounds = CGRect(x: 0, y: (self.font.capHeight - rightImageSize.height) / 2, width: rightImageSize.width, height: rightImageSize.height)
            let rightImageAttrString = NSAttributedString(attachment: rightAttachment)
            attributedString.append(rightImageAttrString)
        }
        
        self.numberOfLines = 1
        self.textAlignment = .center
        self.lineBreakMode = .byTruncatingTail
        
        // Calculate total width including images and spaces
        let imageWidth = (leftImage != nil ? imageSize.width : 0) + (rightImage != nil ? imageSize.width : 0)
        let spaceWidth = space.size().width * (leftImage != nil && rightImage != nil ? 2 : 1)
        let totalImageWidth = imageWidth + spaceWidth
        let availableWidth = viewWidth - totalImageWidth - 15
        
        // Calculate the width of the text
        let textWidth = textAttrString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height), options: .usesLineFragmentOrigin, context: nil).width
        
        if textWidth > availableWidth {
            // Text is too long, hide the right image
            rightImageView.isHidden = false
        } else {
            // Text fits, show the right image if available
            rightImageView.isHidden = true
        }
        // Set the attributed text to the label
        self.attributedText = attributedString
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}






extension Int {
    func toString() -> String {
        return String(self)
    }
    func toDouble() -> Double {
        return Double(self)
    }
}

extension Double {
    func toString() -> String {
        return String(self)
    }
    func toInt() -> Int? {
        return Int(self)
    }
}


extension String {
    func toInt() -> Int? {
        return Int(self)
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
}

extension String {
    func isEmail() -> Bool {
        let strEmailMatchstring = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let regExPredicate = NSPredicate(format: "SELF MATCHES %@", strEmailMatchstring)
        return !self.isEmpty && regExPredicate.evaluate(with: self)
    }
}

func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    print("Download Started")
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        print("Download Finished")
        if let image = UIImage(data: data) {
            completion(image)
        } else {
            completion(nil)
        }
    }.resume()
}


enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case phone
    case pad
}
struct ScreenSize {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenMaxLength = max(ScreenSize.screenWidth, ScreenSize.screenHeight)
    static let screenMinLength = min(ScreenSize.screenWidth, ScreenSize.screenHeight)
}

struct DeviceType {
    static let iPhoneWithHomeButton  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength <= 736.0
    static let iPhone4OrLess  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength < 568.0
    static let iPhoneSE = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 568.0
    static let iPhone8 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 667.0
    static let iPhone8Plus = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 736.0
    static let iPhoneXr = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 896.0
    static let iPhoneXs = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 812.0
    static let iPhoneXsMax = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 896.0
    static let iPad = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 1024.0
}

