//
//  UIDevice+Extension.swift
//  YBLive
//
//  Created by YS on 2024/7/5.
//  Copyright © 2024 cat. All rights reserved.
//

import UIKit

public extension ExtensionNameSpaceStatic where Base: UIDevice {

    var isIphoneX: Bool {
        if #available(iOS 15.0, *) {
            if let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene {
               return windowScene.windows.first?.safeAreaInsets.bottom ?? 0 > 0
            }
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }

    var screenScale: CGFloat { UIScreen.main.scale }

    var screenWidth: CGFloat { UIScreen.main.bounds.size.width }

    var screenHeight: CGFloat { UIScreen.main.bounds.size.height }

    var statusBarHeight: CGFloat { isIphoneX ? 44 : 20 }

    var navigationBarHeight: CGFloat { statusBarHeight + 44 }

    var bottomSafeAreaHeight: CGFloat { isIphoneX ? 34 : 0 }

    var tabBarHeight: CGFloat { bottomSafeAreaHeight + 49 }

}

extension UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}
