
//
//  LayoutConstraint.swift
//  VismaadNaad
//
//  Created by B2BConnect on 28/07/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

class LayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable
    var iPhone4:CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 480 {
                constant = iPhone4
            }
        }
    }
    
    @IBInspectable
    var iPhone5:CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 568 {
                constant = iPhone5
            }
        }
    }
    
    @IBInspectable
    var iPhone6:CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 667 {
                constant = iPhone6
            }
        }
    }
    
    @IBInspectable
    var iPhone6Plus:CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 736 {
                constant = iPhone6Plus
            }
        }
    }
    @IBInspectable
    var iPhoneX:CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY >= 812 {
                constant = iPhoneX
            }
        }
    }
    
}
