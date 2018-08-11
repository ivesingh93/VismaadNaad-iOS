//
//  ListCell.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 08/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
class ListCell: UITableViewCell {

    @IBOutlet weak var lblPlaylistName: UILabel!
    @IBOutlet weak var imgPlaylist: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpContent(_ playlist: String) {
        lblPlaylistName.text = playlist
        imgPlaylist.image = #imageLiteral(resourceName: "playlist")
    }

}
