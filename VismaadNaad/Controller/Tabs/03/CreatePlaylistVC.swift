
//
//  CreatePlaylistVC.swift
//  VismaadNaad
//
//  Created by B2BConnect on 01/07/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
protocol CreatePlaylistDelegate {
    func didCreatePlaylist()
}
class CreatePlaylistVC: UIViewController {

    @IBOutlet weak var txtPlaylistName: UITextField!
    var delegate: CreatePlaylistDelegate?
    
    var playlists:[Playlist]?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnCreateClicked(_ sender: UIButton) {
        if txtPlaylistName.text?.isEmpty == false {
            if let playlists = self.playlists {
                let playlistNames = playlists.map { $0.playlist_name }
                if playlistNames.contains(txtPlaylistName.text!) == false {
                    self.createPlaylist(txtPlaylistName.text!)
                } else {
                    Helper.showMessage(message: "Playlist with name '\(txtPlaylistName.text!)' already exists", success: false)
                }
            }
        } else {
        Helper.showMessage(message: Messages.enterPlaylistName, success: false)
        }
    }
    @IBAction func btnSkipClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Other methods
    func createPlaylist(_ name: String) {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            let parameters = PlaylistMethod.parametersForCreatePlaylist(username: user.username!, playlist_name: name)
            NetworkManager.sharedManager.postRequest(with: PlaylistMethod.createURL, parameters) { (status, response, json) in
                NetworkManager.stopLoader()
                self.txtPlaylistName.resignFirstResponder()
                if status {
                    let statusCode = json["ResponseCode"].int
                    if statusCode == 200 {
                    Helper.showMessage(message: "\(self.txtPlaylistName.text!) playlist created successfully.", success: true)
                        self.dismiss(animated: true, completion: {
                            self.delegate?.didCreatePlaylist()
                        })
                    } else {
                        Helper.showMessage(message: Messages.playlistFailed, success: false)
                    }
                } else {
                    Helper.showMessage(message: Messages.playlistFailed, success: false)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
