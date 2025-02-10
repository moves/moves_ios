//
//  ExtensionCompatible.swift
//  YBLive
//
//  Created by YS on 2024/7/5.
//  Copyright © 2024 cat. All rights reserved.
//

import Foundation
import UIKit

public protocol ExtensionCompatible {}

public extension ExtensionCompatible {

    var ex: ExtensionNameSpace<Self> {
        ExtensionNameSpace(self)
    }

    static var ex: ExtensionNameSpaceStatic<Self> {
        ExtensionNameSpaceStatic(Self.self)
    }
}

public class ExtensionNameSpace<Base> {
    var base: Base
    init(_ instance: Base) {
        self.base = instance
    }
}

public class ExtensionNameSpaceStatic<Base> {
    var baseType: Base.Type
    init(_ instance: Base.Type) {
        self.baseType = instance
    }
}

extension String: ExtensionCompatible {}
extension UIColor: ExtensionCompatible {}
extension UIDevice: ExtensionCompatible {}
extension UIViewController: ExtensionCompatible {}


//extension CALayer {
//    var borderUIColor: UIColor? {
//            get {
//                if let color = self.borderColor {
//                    return UIColor(cgColor: color)
//                }
//                return nil
//            }
//            set {
//                self.borderColor = newValue?.cgColor
//            }
//        }
//}
