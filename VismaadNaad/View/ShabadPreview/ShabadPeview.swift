//
//  ShabadPeview.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 16/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

class ShabadPeview: UIView {

     var view:UIView!
    
    @IBOutlet weak var raagiNameLabel: UILabel!
    @IBOutlet weak var shabadNameLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var shabadName: String? {
        set (shabadName) {
            shabadNameLabel.text = shabadName
        }
        get {
            return shabadNameLabel.text
        }
    }
    
    @IBInspectable var raagiName: String? {
        set (raagiName) {
            raagiNameLabel.text = raagiName
        }
        get {
            return raagiNameLabel.text
        }
    }
    
    @IBInspectable var playing: Bool {
        set (playing) {
            print("Playing or not: \(NSNumber(value: playing))")
            playButton.isSelected = !playing
            if playing {
                show()
            } 
        }
        get {
            return playButton.isSelected
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.isHidden = false
            self.superview!.layoutIfNeeded()
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.isHidden = true
            self.superview!.layoutIfNeeded()
        })

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
        let nib = UINib(nibName:"ShabadPreview", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
}
