//
//  PlaylistCell.swift
//  VismaadNaad
//
//  Created by B2BConnect on 01/07/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown
protocol PlaylistCellDelegate {
    func didClickedDeletePlaylist(_ cell: PlaylistCell)
}
class PlaylistCell: UITableViewCell {
    @IBOutlet weak var lblPlaylistName: UILabel!
    @IBOutlet weak var lblCreatedBy: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    var delegate: PlaylistCellDelegate?
    var dropDown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setUpContent(_ playlist: Playlist) {
        lblPlaylistName.text = playlist.playlist_name
        lblCreatedBy.text = "\(playlist.shabads_count) shabads"
    }
    @IBAction func btnDeletePlaylistClicked(_ sender: Any) {
        dropDown.dataSource = ["Delete"]
        dropDown.anchorView = optionsButton
        dropDown.width = 140
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Delete" {
                self.delegate?.didClickedDeletePlaylist(self)
                self.dropDown.hide()
            }
        }
        dropDown.dismissMode = .automatic
        dropDown.show()
    }
}
