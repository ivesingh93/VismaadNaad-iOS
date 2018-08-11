//
//  AlbumCollectionCell.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 26/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown
@objc protocol AlbumCollectionDelegate {
    func didSingleTap(_ cell: AlbumCollectionCell)
    func didLongPress(_ cell: AlbumCollectionCell)
    @objc optional func didAddToFavorite(_ cell: AlbumCollectionCell)
    @objc optional func didClickedDeletePlaylist(_ playlist: String, in cell: AlbumCollectionCell)

}
class AlbumCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var albumCountLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    var dropDown = DropDown()
    
    var album: Album?
    var playlist: String?
    var delegate: AlbumCollectionDelegate?
    
    func setUpAlbum(_ album: Album) {
        self.album = album
        albumTitleLabel.text = album.raagi_name
        albumCountLabel.text = "\(album.shabads_count) shabads"
        albumImageView.sd_setShowActivityIndicatorView(true)
        albumImageView.sd_setIndicatorStyle(.white)
        let urlString = album.raagi_image_url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        albumImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: nil)
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        self.addGestureRecognizer(singleTap)
        
     //   let longPress = UILongPressGestureRecognizer(target: self, action:#selector(self.longPressAction(_:)))
     //   longPress.delegate = self
       // self.addGestureRecognizer(longPress)
        
       // singleTap.require(toFail: longPress)
    }
    
    func setUpPlaylist(_ playlist: String) {
        self.playlist = playlist
        albumTitleLabel.text = playlist
        albumCountLabel.text = ""
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        self.addGestureRecognizer(singleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(self.longPressAction(_:)))
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
        
        singleTap.require(toFail: longPress)
    }
    @IBAction func btnOptionsClicked(_ sender: Any) {
        if let _ = self.album {
             dropDown.dataSource = ["Play now"]
        } else {
             dropDown.dataSource = ["Delete", "Play now"]
        }
       
        dropDown.anchorView = optionsButton
        dropDown.width = 140
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Add to Playlist" {
                self.delegate?.didAddToFavorite?(self)
            } else if item == "Delete" {
                self.delegate?.didClickedDeletePlaylist?(self.playlist!, in: self)
            }
            else if item == "Play now" {
                
            }
            self.dropDown.hide()
        }
        dropDown.dismissMode = .automatic
        dropDown.show()
    }
    
    @objc func singleTapAction(_ gesture: UITapGestureRecognizer) {
        delegate?.didSingleTap(self)
    }
    @objc func longPressAction(_ gesture: UITapGestureRecognizer) {
        delegate?.didLongPress(self)
    }
}
extension AlbumCollectionCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UIControl.classForCoder()) == true {
            return false
        }
        return true
    }
}
