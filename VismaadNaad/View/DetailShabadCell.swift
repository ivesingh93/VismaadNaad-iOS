//
//  DetailShabadCell.swift
//  SehajBani
//
//  Created by B2BConnect on 26/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown

class DetailShabadCell: UITableViewCell {
    
    @IBOutlet weak var shabadNameLabel: UILabel!
    @IBOutlet weak var shabadDurationLabel: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!

    var dropDown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpContent(_ shabad: Shabad) {
        shabadNameLabel.text = shabad.shabad_english_title
        shabadDurationLabel.text = shabad.shabad_length
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "headphone")
            let imageOffsetY:CGFloat = -5.0;
            attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: attachment.image!.size.width, height: attachment.image!.size.height)
            let attachmentString = NSMutableAttributedString(attachment: attachment)
            let listenerCount = NSAttributedString(string: " \(shabad.listeners)")
            attachmentString.append(listenerCount)
            listenersCountLabel.attributedText = attachmentString
    }
}

@objc protocol PlaylistShabadDelegate {
    func didClickedPlayNow(_ cell: PlaylistShabadCell)
    @objc optional func didClickedRemoveFromFavorite(_ cell: PlaylistShabadCell)
}

class PlaylistShabadCell: UITableViewCell {
    
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var shabadNameLabel: UILabel!
    @IBOutlet weak var shabadDurationLabel: UILabel!
    @IBOutlet weak var raagiName: UILabel!
    
    var dropDown = DropDown()
    
    var delegate: PlaylistShabadDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpContent(_ shabad: Shabad) {
        shabadNameLabel.text = shabad.shabad_english_title
        shabadDurationLabel.text = shabad.shabad_length
        raagiName.text = shabad.raagi_name
    }
    @IBAction func btnOptionsClicked(_ sender: Any) {
        dropDown.dataSource = ["Play now", "Delete"]
        dropDown.anchorView = optionsButton
        dropDown.width = 140
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.dropDown.hide()
            if item == "Play now" {
                self.delegate?.didClickedPlayNow(self)
            }
            else if item == "Delete" {
                self.delegate?.didClickedRemoveFromFavorite?(self)
            }
        }
        dropDown.dismissMode = .automatic
        dropDown.show()
    }
}
