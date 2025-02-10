//
//  Extenstions.swift
//  D-Track
//
//  Created by Zubair Ahmed on 25/01/2022.
//


import Foundation
import UIKit
import AVFAudio
import Photos

enum AssetsColor: String {
    case barColor
    case black
    case darkGrey
    case lightGrey
    case red
    case white
    case theme
    case blue
    case lightRed
    case green
    case buttonColor
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
        return UIColor(named: name.rawValue)
    }
}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}


extension NSNotification.Name {
    static let uploadProgress = NSNotification.Name("uploadProgress")
    static let loadAudio = NSNotification.Name("loadAudio")
    static let updateLocation = NSNotification.Name("updateLocation")
    static let updatePayment = NSNotification.Name("updatePayment")
    static let updateStoreProfile = NSNotification.Name("updateStoreProfile")
    static let pickup0Updated = NSNotification.Name("pickup0Updated")
    static let switchAccount = NSNotification.Name("switchAccount")
    static let followUser = NSNotification.Name("followUser")
    static let moveToNextVideo = NSNotification.Name("moveToNextVideo")
    static let stopVideo = NSNotification.Name("stopVideo")
}

extension UIView {
    
    @objc func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    @objc func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    
    
    
    func centerXInSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superViewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superViewCenterXAnchor).isActive = true
        }
    }
    
    
    func constrainToTop(paddingTop: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = superview?.topAnchor {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
    }
    
    
    func constrainToBottom(paddingBottom: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let bottom = superview?.bottomAnchor {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
    }
    
    func constrainToLeft(paddingLeft: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let left = superview?.leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
    }
    
    
    func constrainToRight(paddingRight: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let right = superview?.rightAnchor {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
    }
    
    func constrainToRight(paddingRight: CGFloat, superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        let right = superView.rightAnchor
        self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        
    }
    
    
    func constrainToTop(paddingTop: CGFloat, superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        let top = superView.topAnchor
        self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    
    func constrainToBottom(paddingBottom: CGFloat, superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        let bottom = superView.bottomAnchor
        self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        
    }
    
    
    
    
    func constrainToLeft(paddingLeft: CGFloat, superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        let left = superView.rightAnchor
        self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        
    }
    
    
    func centerYInSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let centerY = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
    
    func constrainWidth(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    func constrainHeight(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    
}

extension Int {
    func formatUsingAbbrevation () -> String {
        let n = self
        let num = abs(Double(n))
        let sign = (n < 0) ? "-" : ""
        
        switch num {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"
            
        case 0...:
            return "\(n)"
            
        default:
            return "\(sign)\(n)"
            
        }
    }
}

extension PHAsset {
    @objc func getURL(completionHandler : @escaping ((_ responseURL : URL?, _ image: UIImage?, _ aVAsset: AVAsset?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                if let contentEditingInputUnwrapped = contentEditingInput {
                    //                    completionHandler(contentEditingInputUnwrapped.fullSizeImageURL as URL?)
                    completionHandler(contentEditingInputUnwrapped.fullSizeImageURL as URL?, contentEditingInputUnwrapped.displaySizeImage, nil)
                    
                    
                }
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    
                    let localVideoUrl: URL = urlAsset.url as URL
                    //
                    //                    let videoData = NSData(contentsOf: localVideoUrl)
                    //
                    //                    //MARK: The URL returned from the PHAssets is invalid for export, so i write the localVideoUrl to a temp direct, grab the url address of the temporary directory and use that to upload video URL to my DB. Then i clear all files and data stored in temp directory path.
                    //                    let videoPath = NSTemporaryDirectory() + "tmpMovie.MOV"
                    //                    let videoURL = NSURL(fileURLWithPath: videoPath)
                    //                    let writeResult = videoData?.write(to: videoURL as URL, atomically: true)
                    //
                    //                    if let writeResult = writeResult, writeResult {
                    //                        print("success: \(videoURL)")
                    //                    }
                    //                    else {
                    //                        print("failure")
                    //                    }
                    //
                    //                    completionHandler(videoURL as URL, nil, asset)
                    completionHandler(localVideoUrl, nil, asset)
                    
                } else {
                    completionHandler(nil, nil, nil)
                }
            })
        }
    }
}

let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

public func triggerHapticFeedback() {
    selectionFeedbackGenerator.selectionChanged()
}


extension Double {
    
    func truncate(places: Int) -> Double {
        
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
        
    }
    
}

extension UIView {
    func startRotating(duration: Double = 4) {
        let kAnimationKey = "rotation"
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float.pi * 2.0
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    
    func stopRotating() {
        let kAnimationKey = "rotation"
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}


func getTimeZoneOffset() -> String {
    let timeZone = TimeZone.current
    let secondsFromGMT = timeZone.secondsFromGMT()
    
    let hours = abs(secondsFromGMT) / 3600
    let minutes = (abs(secondsFromGMT) % 3600) / 60
    
    let sign = secondsFromGMT < 0 ? "-" : "+"
    let formattedOffset = String(format: "%@%02d:%02d", sign, hours, minutes)
    
    return formattedOffset
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}

func convertAndFormatDate(date: Date) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone.current // Assuming you want to use the current time zone
    
    // Format the date to string
    let dateString = formatter.string(from: date)
    
    // Convert the string back to Date
    return formatter.date(from: dateString)
}

func adjustDate(for dateString: String, timeZoneOffset: String, format: String = "yyyy-MM-dd HH:mm:ss") -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let date = dateFormatter.date(from: dateString) else {
        print("Failed to parse date string: \(dateString)")
        return nil
    }
    
    guard let hoursOffset = parseTimeZoneOffset(timeZoneOffset) else {
        print("Failed to parse time zone offset: \(timeZoneOffset)")
        return nil
    }
    
    let calendar = Calendar.current
    guard let adjustedDate = calendar.date(byAdding: .hour, value: hoursOffset, to: date) else {
        print("Failed to adjust date.")
        return nil
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = format
    outputFormatter.timeZone = TimeZone.current
    outputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    return outputFormatter.string(from: adjustedDate)
}

func parseTimeZoneOffset(_ offset: String) -> Int? {
    let pattern = "([+-])(\\d{2}):(\\d{2})"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let nsString = offset as NSString
    let results = regex?.matches(in: offset, options: [], range: NSRange(location: 0, length: nsString.length))
    
    guard let result = results?.first,
          let signRange = Range(result.range(at: 1), in: offset),
          let hourRange = Range(result.range(at: 2), in: offset) else {
        return nil
    }
    
    let sign = offset[signRange]
    let hoursString = offset[hourRange]
    
    let signValue = sign == "+" ? 1 : -1
    let hours = Int(hoursString) ?? 0
    
    return signValue * hours
}

func timeDifference(from dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let date = dateFormatter.date(from: dateString) else {
        print("Failed to parse date string: \(dateString)")
        return nil
    }
    
    let currentDate = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: currentDate)
    
    if let years = components.year, years > 0 {
        return "\(years) year"
    }
    
    if let months = components.month, months > 0 {
        return "\(months) mon"
    }
    
    if let days = components.day, days > 0 {
        return "\(days) day"
    }
    
    if let hours = components.hour, hours > 0 {
        return "\(hours) hour"
    }
    
    if let minutes = components.minute, minutes > 0 {
        return "\(minutes) min"
    }
    
    if let seconds = components.second {
        if seconds >= 60 {
            let minutes = seconds / 60
            return "\(minutes) min"
        }
        return "\(seconds) sec"
    }
    
    return "Just now"
}

extension String {
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    func toDateInUTC() -> Date? {
        return self.toDate(withFormat: "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone(identifier: "UTC")!)
    }
    
    func toDate(withFormat format: String, timeZone: TimeZone = TimeZone.current) -> Date? {
        String.dateFormatter.dateFormat = format
        String.dateFormatter.timeZone = timeZone
        return String.dateFormatter.date(from: self)
    }
}

func playLightImpactHaptic() {
    // Create a haptic generator
    let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    // Play the haptic feedback
    hapticGenerator.impactOccurred()
}



func formatText(_ text: String, characterLimit: Int, addString: String) -> NSAttributedString {
    var formattedText = text
    
    // Check if text exceeds character limit
    if formattedText.count > characterLimit {
        // Truncate text to fit within character limit
        let index = formattedText.index(formattedText.startIndex, offsetBy: characterLimit - 3)
        formattedText = String(formattedText[..<index]) + "..."
    }
    
    // Create attributed string for main text
    let mainAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black
    ]
    let attributedText = NSMutableAttributedString(string: formattedText, attributes: mainAttributes)
    
    // Add addString at the end
    if !formattedText.isEmpty {
        attributedText.append(NSAttributedString(string: ". ", attributes: mainAttributes))
    }
    
    // Create attributed string for addString
    let addStringAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.appColor(.darkGrey)
    ]
    let attributedAddString = NSAttributedString(string: addString, attributes: addStringAttributes)
    attributedText.append(attributedAddString)
    
    return attributedText
}

extension Date {
    
    var daysInMonth:Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toLocalTime() -> Date {
        return self
    }
    
    func convertToTimeZone(timeZone: TimeZone) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - TimeZone.current.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    func toStringInLocalTime(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func dateFromString(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Assuming dates are in GMT
        
        return dateFormatter.date(from: dateString)
    }
}


func convertDateToTimeZone(date: Date, timeZone: TimeZone) -> Date {
    let fromTimeZone = TimeZone(secondsFromGMT: 0)! // Assuming server time is GMT+0
    let toTimeZone = timeZone
    
    let fromOffset = fromTimeZone.secondsFromGMT(for: date)
    let toOffset = toTimeZone.secondsFromGMT(for: date)
    let interval = TimeInterval(toOffset - fromOffset)
    
    return Date(timeInterval: interval, since: date)
}

func timeAgoSinceDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
    
    if let year = components.year, year > 0 {
        return "\(year) year\(year > 1 ? "s" : "") ago"
    } else if let month = components.month, month > 0 {
        return "\(month) month\(month > 1 ? "s" : "") ago"
    } else if let week = components.weekOfYear, week > 0 {
        return "\(week) week\(week > 1 ? "s" : "") ago"
    } else if let day = components.day, day > 0 {
        return "\(day) day\(day > 1 ? "s" : "") ago"
    } else if let hour = components.hour, hour > 0 {
        return "\(hour) hour\(hour > 1 ? "s" : "") ago"
    } else if let minute = components.minute, minute > 0 {
        return "\(minute) minute\(minute > 1 ? "s" : "") ago"
    } else if let second = components.second, second > 0 {
        return "\(second) second\(second > 1 ? "s" : "") ago"
    } else {
        return "just now"
    }
}

func getThumbnailImage(forUrl url: URL) -> UIImage? {
    let asset: AVAsset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
        let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
        return UIImage(cgImage: thumbnailImage)
    } catch let error {
        print(error)
    }
    
    return nil
}

func resolutionSizeForLocalVideo(url: URL) -> CGSize? {
    let asset = AVAsset(url: url)
    guard let track = asset.tracks(withMediaType: .video).first else { return nil }
    let size = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: abs(size.width), height: abs(size.height))
}
func setupAudio() {
    let audioSession = AVAudioSession.sharedInstance()
    _ = try? audioSession.setCategory(AVAudioSession.Category.playback)
    _ = try? audioSession.setActive(true)
    
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}

struct AppFont {
    enum FontType: String {
        case Regular = "SFProText-Regular"
        case Light = "SFProText-Light"
        case Medium = "SFProText-Medium"
        case Semibold = "SFProText-Semibold"
        case Bold = "SFProText-Bold"
        case Heavy = "SFProText-Heavy"
    }
    
    static func font(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size)!
    }
}

public extension UIDevice {
    
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case iPhone_12_12Pro_13_13Pro_14 = "iPhone 12 or 12 Pro or 13 or 13 Pro or 14"
        case iPhone_14Pro = "iPhone 14 Pro"
        case iPhone_12ProMax_13ProMax_14Plus = "iPhone 12 Pro Max or 13 Pro Max or 14 Plus"
        case iPhone_14ProMax = "iPhone 14 Pro Max"
        case iPhone12Mini_13Mini = "iPhone 12 Mini or 13 Mini"
        case unknown
    }
    
    var screenType: ScreenType {
        guard iPhone else { return .unknown }
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR_11
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2340:
            return .iPhone12Mini_13Mini
        case 2426:
            return .iPhone_11Pro
        case 2436:
            return .iPhones_X_XS
        case 2532:
            return .iPhone_12_12Pro_13_13Pro_14
        case 2688:
            return .iPhone_XSMax_ProMax
        case 2778:
            return .iPhone_12ProMax_13ProMax_14Plus
        case 2556:
            return .iPhone_14Pro
        case 2796:
            return .iPhone_14ProMax
        default:
            return .unknown
        }
    }
}

extension UIColor {
    
    @objc static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let tealColor = UIColor(red: 48/255, green: 164/255, blue: 182/255, alpha: 1)
    static let lightRed = UIColor.init(red: 247/255, green: 66/255, blue: 82/255, alpha: 1)
    static let darkBlue = UIColor(red: 9/255, green: 45/255, blue: 64/255, alpha: 1)
    static let lightBlue = UIColor(red: 218/255, green: 235/255, blue: 243/255, alpha: 1)
    
}

extension FileManager {
    @objc func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
                print("Success: removed temp fileUrl \(fileUrl), file: \(file)")
            }
        } catch {
            //catch the error somehow or catch these hands
            print("error clearing temp directory: ", error.localizedDescription)
        }
    }
}


extension UIView {
    
    /// Flip view horizontally.
    func flipX() {
        transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
    }
    
    /// Flip view vertically.
    func flipY() {
        transform = CGAffineTransform(scaleX: transform.a, y: -transform.d)
    }
    
    
    /// Flip view 180, slight delay then 360.
    func handleRotate360() {
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.45, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
    }
    
    
    
    /// Flip view 180, true to rotate 180, false to return to identity
    func handleRotate180(rotate: Bool) {
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.transform = rotate == true ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
        }
        
    }
    
    
    
}



public func didTakePicture(_ picture: UIImage, to orientation: UIImage.Orientation) -> UIImage {
    let flippedImage = UIImage(cgImage: picture.cgImage!, scale: picture.scale, orientation: orientation)
    // Here you have got flipped image you can pass it wherever you are using image
    return flippedImage
    
    //.upMirrored for front cam video
    //.leftMirrored for front cam photos
}


public func generateVideoThumbnail(withfile videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    do {
        let cmTime = CMTimeMake(value: 1, timescale: 60)
        let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
        return UIImage(cgImage: thumbnailCGImage)
        
    } catch let err {
        print(err)
    }
    
    return nil
}

public func generateVideoThumbnailAt(cmTime: CMTime, withfile videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    do {
        let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
        return UIImage(cgImage: thumbnailCGImage)
        
    } catch let err {
        print(err)
    }
    
    return nil
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func roundedImageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let renderer = UIGraphicsImageRenderer(size: square)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: square)
            UIBezierPath(ovalIn: rect).addClip()
            self.draw(in: rect)
            
            let borderRect = rect.insetBy(dx: width / 2, dy: width / 2)
            let borderPath = UIBezierPath(ovalIn: borderRect)
            borderPath.lineWidth = width
            color.setStroke()
            borderPath.stroke()
        }
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
        else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    // greatest common divisor for pair
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    // greatest common divisor for array
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension String
{
    func hashtags() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive)
        {
            let string = self as NSString

            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }

        return []
    }

    func mentions1() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "@[a-z0-9]+", options: .caseInsensitive)
        {
            let string = self as NSString

            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "@", with: "").lowercased()
            }
        }

        return []
    }

}

typealias ImageDownloadCompletion = (Result<URL, Error>) -> Void

func downloadImage(from url: URL, completion: @escaping ImageDownloadCompletion) {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        completion(.failure(NSError(domain: "File manager error", code: 0, userInfo: nil)))
        return
    }
    
    let filename = url.lastPathComponent
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data, let image = UIImage(data: data) else {
            completion(.failure(NSError(domain: "Image data error", code: 0, userInfo: nil)))
            return
        }
        
        // Save image data to fileURL
        do {
            try data.write(to: fileURL)
            completion(.success(fileURL))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

extension UIColor {
    // UIColor extension to initialize with hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
