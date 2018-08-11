

//
//  DetailTableHeader.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 08/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SDWebImage

class DetailTableHeader: UIView {
    
    var view:UIView!;
    @IBOutlet weak var raagiNameLabel: UILabel!
    @IBOutlet weak var albumDurationLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var raagiImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func setUpContent(_ album: Album) {
        visualEffectView.alpha = 1.0
        raagiNameLabel.text = album.raagi_name
        albumDurationLabel.text = "\(album.shabads_count) shabads - \(album.minutes_of_shabads) minutes"
        raagiImageView.sd_setShowActivityIndicatorView(true)
        raagiImageView.sd_setIndicatorStyle(.white)
        let urlString = album.raagi_image_url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        raagiImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: nil)
        backgroundImage.sd_setImage(with: URL(string: urlString!), placeholderImage: nil)
    }

    func setUpContent(_ playlist: String, shabads: Int) {
        if let _ = CoreDataService.getLogin() {
            visualEffectView.alpha = 0.85
           raagiNameLabel.text = playlist
            //titleLabel.text = playlist
           albumDurationLabel.text = "\(shabads) shabads"
            raagiImageView.image = #imageLiteral(resourceName: "playlist")
            raagiImageView.backgroundColor = .clear
            var number = arc4random_uniform(10)
            if number == 0 {
                number = 1
            }
            backgroundImage.image = UIImage(named: "darbarsahib_\(number)")
            
        }
    }
    func loadViewFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        //        let bundle = NSBundle(forClass: type(of: self))
        let nib = UINib(nibName:"DetailTableHeader", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
 
}
