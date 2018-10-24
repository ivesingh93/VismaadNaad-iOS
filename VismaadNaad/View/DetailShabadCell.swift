//
//  DetailShabadCell.swift
//  SehajBani
//
//  Created by B2BConnect on 26/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown

@objc protocol DetailShabadDelegate {
    func didClickedPlayNow(_ cell: DetailShabadCell)
    @objc optional func didClickedAddToFavorite(_ cell: DetailShabadCell)
    @objc optional func didClickedRemoveFromFavorite(_ cell: DetailShabadCell)
}
class DetailShabadCell: UITableViewCell {
    
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var shabadNameLabel: UILabel!
    @IBOutlet weak var shabadDurationLabel: UILabel!
    @IBOutlet weak var raagiName: UILabel!
    @IBOutlet weak var listenersCountLabel: UILabel!

    var dropDown = DropDown()
    
    var delegate: DetailShabadDelegate?
    
    var isPlaylist = false
    
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
        let attachmentString = NSAttributedString(attachment: attachment)
        let listenerCount = NSMutableAttributedString(string: "\(shabad.listeners)")
        listenerCount.append(attachmentString)
        listenersCountLabel.attributedText = listenerCount
        if isPlaylist == true {
           raagiName.text = shabad.raagi_name
        } else {
            optionsButton.isHidden = true
        }
    }
    @IBAction func btnOptionsClicked(_ sender: Any) {
        dropDown.dataSource = ["Play now", isPlaylist ? "Delete" : "Add to Playlist"]
        dropDown.anchorView = optionsButton
        dropDown.width = 140
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.dropDown.hide()
            if item == "Add to Playlist" {
                self.delegate?.didClickedAddToFavorite?(self)
            } else if item == "Play now" {
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
