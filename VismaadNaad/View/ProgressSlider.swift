
//
//  ProgressSlider.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 10/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

class ProgressSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
 
  
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    func getColoredThumbImage(color: UIColor) -> UIImage {
        
        //we will make circle with this diameter
        let edgeLen: CGFloat = 26
        
        //circle will be created from UIView
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen, height: edgeLen))
        circle.backgroundColor = color
        circle.clipsToBounds = true
        circle.isOpaque = false
        
        //in the layer we add corner radius to make it circle and add shadow
        circle.layer.cornerRadius = edgeLen/2
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOffset = CGSize(width: 1, height: 1)
        circle.layer.shadowRadius = 2
        circle.layer.shadowOpacity = 0.5
        circle.layer.masksToBounds  = false
        
        //we add circle to a view, that is bigger than circle so we have extra 10 points for the shadow
        let view = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen+10, height: edgeLen+10))
        view.backgroundColor = UIColor.clear
        view.addSubview(circle)
        
        circle.center = view.center
        
        //here we are rendering view to image, so we can use it later
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
