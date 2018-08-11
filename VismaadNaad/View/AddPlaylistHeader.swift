//
//  AddPlaylistHeader.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 11/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

protocol CreateHeaderDelegate {
    func didTapCreateButton()
}

class AddPlaylistHeader: UITableViewCell {

    @IBOutlet weak var btnCreate: UIButton!
    
    var delegate: CreateHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnCreatePlaylistClicked(_ sender: UIButton) {
        delegate?.didTapCreateButton()
    }
}

