import Foundation
import CoreLocation
import UIKit
import PhoneNumberKit
import Toast_Swift
import CommonCrypto
class Utility {
    static let shared = Utility()
    let phoneNumberKit: PhoneNumberKit
    
    private init() {
        phoneNumberKit = PhoneNumberKit()
    }
    
    private var viewModel = AddDeviceDataViewModel()
    
    func extractFirstNameAndLastName(from username: String) -> (firstName: String, lastName: String) {
        let prefix = "moves"
        
        if username.hasPrefix(prefix) {
            let firstName = prefix
            let lastName = username.dropFirst(prefix.count)
            return (firstName, String(lastName))
        } else {
            return ("", "")
        }
    }

    func generateRandomUsername(prefix: String = "moves", length: Int = 8) -> String {
        let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomPart = ""

        for _ in 0..<length {
            if let randomChar = lettersAndNumbers.randomElement() {
                randomPart.append(randomChar)
            }
        }

        return prefix + randomPart
    }
    
    // MARK: - Phone Number Validation Check
    static func isValidPhoneNumber(_ strPhone: String) -> Bool {
        do {
            _ = try shared.phoneNumberKit.parse(strPhone)
            return true
        } catch {
            print("Generic parser error")
            return false
        }
    }
    
    func encodeToShortString(_ longString: String?) -> String? {
        guard let longString = longString else { return nil }
        
        // Create SHA-256 hash
        guard let data = longString.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        // Encode hash bytes to Base64
        let base64String = Data(hash).base64EncodedString(options: .endLineWithLineFeed)
            .replacingOccurrences(of: "/", with: "-")
        
//        // Filter out non-alphabet characters
//           let filteredString = base64String.filter { $0.isLetter }
//
           // Return the first 10 characters
           return String(base64String.prefix(10))
    }
    
    static func showMessage(message: String, on view: UIView, duration: TimeInterval = 1.0, position: ToastPosition = .bottom) {
        view.makeToast(message, duration: duration, position: position)
    }
    
    internal func createActivityIndicator(_ uiView : UIView)->UIView{
        let container: UIView = UIView(frame: CGRect.zero)
        container.layer.frame.size = uiView.frame.size
        container.center = CGPoint(x: uiView.bounds.width/2, y: uiView.bounds.height/2)
        container.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor.clear
        
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 15
        loadingView.layer.shadowRadius = 5
        loadingView.layer.shadowOffset = CGSize(width: 0, height: 4)
        loadingView.layer.opacity = 2
        loadingView.layer.masksToBounds = false
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.clipsToBounds = true
        actInd.color = UIColor(named: "theme")
        actInd.style = .whiteLarge// .whiteLarge
        
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        container.isHidden = true
        uiView.addSubview(container)
        actInd.startAnimating()
        
        return container
    }
    
    func removeSpacesAndBrackets(from string: String) -> String {
        let charactersToRemove: Set<Character> = [" ", "(", ")"]
        return String(string.filter { !charactersToRemove.contains($0) })
    }
    
    func getOSInfo()->Int {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return os.majorVersion
    }
    
    func getHourAndMinute(from string: String) -> (hour: Int, minute: Int)? {
        let components = string.components(separatedBy: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1].components(separatedBy: " ")[0]) else {
            return nil
        }
        return (hour, minute)
    }
    
    func isEmpty(_ thing : String? )->Bool {
        
        if (thing?.count == 0) {
            return true
        }
        return false;
    }
    
    func addDeviceData() {
        let uid = UserDefaultsManager.shared.user_id
        let fcm = UserDefaultsManager.shared.device_token
        let ip = getIPAddress()
        UserDefaultsManager.shared.ip = ip
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let deviceType = "iOS"
        
        let addDeviceData = AddDeviceDataRequest(userId: uid, device: deviceType, appVersion: appVersion, ip: ip, deviceToken: fcm)
        viewModel.addDeviceData(parameters: addDeviceData)
    }
  
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))k")
            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }
        
    }
    
    func formatPointsInt(num: Int) -> String {
        var thousandNum = Double(num) / 1000
        var millionNum = Double(num) / 1000000
        
        if num >= 1000 && num < 1000000 {
            if floor(thousandNum) == thousandNum {
                return "\(Int(thousandNum))k"
            }
            return "\(thousandNum.roundToPlaces(places: 1))k"
        }
        
        if num >= 1000000 {
            if floor(millionNum) == millionNum {
                return "\(Int(millionNum))M"
            }
            return "\(millionNum.roundToPlaces(places: 1))M"
        }
        
        return "\(num)"
    }
    
    
    func beautifyJSON(_ jsonObject: Any) -> String? {
        do {
            // Check if the input is a valid JSON object
            if JSONSerialization.isValidJSONObject(jsonObject) {
                // Convert the JSON object to pretty-printed Data
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                
                // Convert Data to a String and return it
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                } else {
                    print("Failed to convert JSON data to String.")
                    return nil
                }
            } else {
                print("Invalid JSON object.")
                return nil
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func formatToCurrency(cents: Int) -> String {
        let dollars = Double(cents) / 100.0

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
    
    // Function to format dollars (Double) to currency
    func formatToCurrency(dollars: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
    
    func priceToCents(price: Double) -> Int {
        return Int(price * 100)
    }

    func getTimeZone(for state: String) -> TimeZone? {
        switch state {
        case "AL": return TimeZone(identifier: "America/Chicago")
        case "AK": return TimeZone(identifier: "America/Anchorage")
        case "AZ": return TimeZone(identifier: "America/Phoenix")
        case "AR": return TimeZone(identifier: "America/Chicago")
        case "CA", "California":
                return TimeZone(identifier: "America/Los_Angeles")
        case "CO": return TimeZone(identifier: "America/Denver")
        case "CT": return TimeZone(identifier: "America/New_York")
        case "DE": return TimeZone(identifier: "America/New_York")
        case "FL": return TimeZone(identifier: "America/New_York")
        case "GA": return TimeZone(identifier: "America/New_York")
        case "HI": return TimeZone(identifier: "Pacific/Honolulu")
        case "ID": return TimeZone(identifier: "America/Denver")
        case "IL": return TimeZone(identifier: "America/Chicago")
        case "IN": return TimeZone(identifier: "America/Indiana/Indianapolis")
        case "IA": return TimeZone(identifier: "America/Chicago")
        case "KS": return TimeZone(identifier: "America/Chicago")
        case "KY": return TimeZone(identifier: "America/New_York")
        case "LA": return TimeZone(identifier: "America/Chicago")
        case "ME": return TimeZone(identifier: "America/New_York")
        case "MD": return TimeZone(identifier: "America/New_York")
        case "MA": return TimeZone(identifier: "America/New_York")
        case "MI": return TimeZone(identifier: "America/New_York")
        case "MN": return TimeZone(identifier: "America/Chicago")
        case "MS": return TimeZone(identifier: "America/Chicago")
        case "MO": return TimeZone(identifier: "America/Chicago")
        case "MT": return TimeZone(identifier: "America/Denver")
        case "NE": return TimeZone(identifier: "America/Chicago")
        case "NV": return TimeZone(identifier: "America/Los_Angeles")
        case "NH": return TimeZone(identifier: "America/New_York")
        case "NJ": return TimeZone(identifier: "America/New_York")
        case "NM": return TimeZone(identifier: "America/Denver")
        case "NY": return TimeZone(identifier: "America/New_York")
        case "NC": return TimeZone(identifier: "America/New_York")
        case "ND": return TimeZone(identifier: "America/Chicago")
        case "OH": return TimeZone(identifier: "America/New_York")
        case "OK": return TimeZone(identifier: "America/Chicago")
        case "OR": return TimeZone(identifier: "America/Los_Angeles")
        case "PA": return TimeZone(identifier: "America/New_York")
        case "RI": return TimeZone(identifier: "America/New_York")
        case "SC": return TimeZone(identifier: "America/New_York")
        case "SD": return TimeZone(identifier: "America/Chicago")
        case "TN": return TimeZone(identifier: "America/Chicago")
        case "TX": return TimeZone(identifier: "America/Chicago")
        case "UT": return TimeZone(identifier: "America/Denver")
        case "VT": return TimeZone(identifier: "America/New_York")
        case "VA": return TimeZone(identifier: "America/New_York")
        case "WA": return TimeZone(identifier: "America/Los_Angeles")
        case "WV": return TimeZone(identifier: "America/New_York")
        case "WI": return TimeZone(identifier: "America/Chicago")
        case "WY": return TimeZone(identifier: "America/Denver")
        default: return nil
        }
    }
    
    func getCityName(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            let cityName = placemark.locality ?? "Unknown city"
            completion(cityName)
        }
    }
    func handleError(error: Error) {
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)
            
            if let dataError = error as? Moves.DataError {
                switch dataError {
                case .invalidResponse, .invalidURL, .network:
                    keyWindow?.makeToast("Unreachable network. Please try again")
                case .invalidData:
                    print("Invalid Data")
                case .decoding:
                    print("Decoding Error")
                }
            } else {
                if isDebug {
                    keyWindow?.makeToast("Something went wrong. Please try again")
                }
            }
        }
    }
    

    func dayToIndex(day: String) -> Int? {
        switch day.lowercased() {
        case "monday": return 2
        case "tuesday": return 3
        case "wednesday": return 4
        case "thursday": return 5
        case "friday": return 6
        case "saturday": return 7
        case "sunday": return 1
        default: return nil
        }
    }

    func checkRestaurantStatus(for state: String, storeLocalHours: [StoreLocalHour]) -> String {
        guard let timeZone = getTimeZone(for: state) else {
            return "Invalid state"
        }

        // Get the current date and time in the specified time zone
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let currentDate = Date()
        let currentDayIndex = calendar.component(.weekday, from: currentDate)

        guard let todayStoreHours = storeLocalHours.first(where: { dayToIndex(day: $0.day) == currentDayIndex }) else {
            return "No operational hours found for today."
        }

        guard let operational = todayStoreHours.operational else {
            return "Operational hours not available."
        }

        let operationalLowercased = operational.lowercased()
        if operationalLowercased == "open 24 hours" {
            return "Open 24 hours"
        } else if operationalLowercased == "closed now" {
            return "Closed now"
        }

        // Parse operational hours
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "hh:mma"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateFormatter1 = DateFormatter()
        dateFormatter1.timeZone = timeZone
        dateFormatter1.dateFormat = "HH:mm"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")

        let operationalTimes = operational.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var statusText = "Closed now"
        var nextOpenTime: Date?

        for timeRange in operationalTimes {
            let hours = timeRange.split(separator: "-").map { String($0.trimmingCharacters(in: .whitespaces)) }
            
            guard hours.count == 2 else { continue }
            
            // Attempt to parse both time formats
            guard let startTimeOfDay = dateFormatter.date(from: hours[0])
                ?? dateFormatter1.date(from: hours[0]),
                  let endTimeOfDay = dateFormatter.date(from: hours[1])
                ?? dateFormatter1.date(from: hours[1]) else {
                continue
            }
            
            // Use calendar to get date components
            let calendar = Calendar.current
            var startTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTimeOfDay),
                                          minute: calendar.component(.minute, from: startTimeOfDay),
                                          second: 0, of: currentDate)!
            var endTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTimeOfDay),
                                        minute: calendar.component(.minute, from: endTimeOfDay),
                                        second: 0, of: currentDate)!
            
            // Handle cases where the store closes past midnight
            if endTime < startTime {
                endTime = calendar.date(byAdding: .day, value: 1, to: endTime)!
            }
            
            if currentDate >= startTime && currentDate <= endTime {
                let endTimeString = dateFormatter1.string(from: endTime)
                let timeRemaining = endTime.timeIntervalSince(currentDate)
                
                if timeRemaining <= 3600 { // Less than or equal to 1 hour
                    let minutesRemaining = Int(timeRemaining / 60)
                    statusText = "Open now, \(minutesRemaining) minutes remaining to close"
                } else {
                    statusText = "Open now, until \(endTimeString)"
                }
                return statusText
            } else if currentDate < startTime, nextOpenTime == nil {
                nextOpenTime = startTime
            }
        }

        if let nextOpenTime = nextOpenTime {
            let nextOpenTimeString = DateFormatter.localizedString(from: nextOpenTime, dateStyle: .none, timeStyle: .short)
            statusText = "Closed, next open at \(nextOpenTimeString)"
        }

        return statusText

    }



    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
    
    func detectURL(ipString:String)-> String{
        let input = ipString
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        if matches.isEmpty{
            return "https://app.movesapp.io/mobileapp_api/api/" + ipString
        }else{
            
            var urlString = ""
            for match in matches {
                guard let range = Range(match.range, in: input) else { continue }
                let url = input[range]
                print(url)
                
                urlString = String(url)
            }
            
            return urlString
        }
        
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}


func scheduleNotification(title: String, body: String, progress: Float? = nil, identifier: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    
    if let progress = progress {
        let percentCompleted = Int(progress * 100)
        content.body = "\(body) \(percentCompleted)%"
    } else {
        content.body = body
    }
    
    content.sound = UNNotificationSound.default

    // Create notification trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Set a minimal time interval of 1 second

    // Create notification request
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    // Add the notification request
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Notification '\(identifier)' scheduled successfully")
        }
    }
    
}
