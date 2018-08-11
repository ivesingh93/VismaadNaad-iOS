//
//  NavigationBarView.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 8/05/18.
//
//

import UIKit
import Foundation
@IBDesignable class NavigationBarView:UIView {
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowOpacity: Float = 0.5
    var view:UIView!
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    //Left navigation Title
    @IBOutlet weak var lblLeftButtonTitle: UILabel!
    //Left navigation item button
    @IBOutlet weak var leftNavButton: UIButton!
    
    //Left navigation item button image, cutomizable from every screen
    @IBInspectable var leftNavTitle : String? {
                set (leftNavTitle) {
                    lblLeftButtonTitle.text = leftNavTitle
        }
        get {
            return lblLeftButtonTitle.text
        }
    }
    
    @IBInspectable var leftNavImage : UIImage? {
        set (leftNavImage) {
            leftNavButton.setImage(leftNavImage, for: .normal)
        }
        get {
            return leftNavButton.image(for: .normal)
        }
    }
    @IBInspectable var hide : Bool {
        set (hide) {
            leftNavButton.isHidden = hide
        }
        get {
            return leftNavButton.isHidden
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName:"NavigationBarView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
    
    //This method will add a bottom border
    func addBottomBorderWithColor() {

        let borderHeight:CGFloat = 3.0
        let border = CALayer()

        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderHeight, width: UIScreen.main.bounds.size.width, height: borderHeight)
        self.layer.addSublayer(border)
    }
}

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}
