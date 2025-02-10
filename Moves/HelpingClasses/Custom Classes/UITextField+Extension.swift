//
//  UITextField+Extension.swift
//  textViewSample
//
//  Created by Robert Chen on 5/22/15.
//  Copyright (c) 2015 Thorn Technologies. All rights reserved.
//

import UIKit

func += <KeyType, ValueType> ( left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension String {
    func NSRangeFromRange(range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        
        // Safely unwrap lowerBound and upperBound
        guard let from = range.lowerBound.samePosition(in: utf16view),
              let to = range.upperBound.samePosition(in: utf16view) else {
            // Return an empty NSRange if indices are not valid
            return NSRange(location: 0, length: 0)
        }
        
        // Calculate distances and create NSRange
        let location = utf16view.distance(from: utf16view.startIndex, to: from)
        let length = utf16view.distance(from: from, to: to)
        return NSRange(location: location, length: length)
    }
    
    mutating func dropTrailingNonAlphaNumericCharacters() {
        let nonAlphaNumericCharacters = NSCharacterSet.alphanumerics.inverted
        let characterArray = components(separatedBy: nonAlphaNumericCharacters)
        if let first = characterArray.first {
            self = first
        }
    }
}

extension UITextView {

    public func resolveHashTags(possibleUserDisplayNames: [String]? = nil) {
        
        let schemeMap = [
            "#":"hash",
            "@":"mention"
        ]
        
        // Separate the string into individual words.
        // Whitespace is used as the word boundary.
        let words = self.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText)
        
        var bookmark = self.text.startIndex
        
        for word in words {
            
            var scheme: String? = nil
            
            if word.hasPrefix("#") {
                scheme = schemeMap["#"]
            } else if word.hasPrefix("@") {
                scheme = schemeMap["@"]
            }
            
            var wordWithTagRemoved = String(word.dropFirst())
            wordWithTagRemoved.dropTrailingNonAlphaNumericCharacters()
            
            guard let schemeMatch = scheme, Int(wordWithTagRemoved) == nil && !wordWithTagRemoved.isEmpty else {
                bookmark = self.text.index(bookmark, offsetBy: word.count + 1, limitedBy: self.text.endIndex) ?? self.text.endIndex
                continue
            }
            
            if let matchRange = self.text.range(of: word, options: .literal, range: bookmark..<self.text.endIndex),
                let escapedString = wordWithTagRemoved.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let nsRange = NSRange(matchRange, in: self.text)
                
                // Add attributes: link and text color
                attributedString.addAttribute(NSAttributedString.Key.link, value: "\(schemeMatch):\(escapedString)", range: nsRange)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: nsRange)
            }
            
            bookmark = self.text.index(bookmark, offsetBy: word.count + 1, limitedBy: self.text.endIndex) ?? self.text.endIndex
        }
        
        self.attributedText = attributedString
    }
}
