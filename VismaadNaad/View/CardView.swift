//
//  CardView.swift
//  TravelBuddy
//
//  Created by Satinder on 10/01/18.
//  Copyright © 2018 Ankur Batham. All rights reserved.
//

import UIKit
import Foundation
@IBDesignable class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: CGFloat = 0
    @IBInspectable var shadowOffsetHeight: CGFloat = 3
    @IBInspectable var shadowColor: UIColor = .black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}
