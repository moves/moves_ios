//
//  CircleLable.swift
//  ShoppingList
//
//  Created by Mac on 18/02/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//


import UIKit

class CircleLabel: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    func commonInit(){
        //self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = true
        self.textColor = UIColor.black
        //self.setProperties(borderWidth: 1.0, borderColor:UIColor.black)
    }
    func setProperties(borderWidth: Float, borderColor: UIColor) {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }
}
