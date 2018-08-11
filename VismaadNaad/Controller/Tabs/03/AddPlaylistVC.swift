//
//  AddPlaylistVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 05/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

protocol AddPlaylistDelegate {
    func didAddPlaylist(_ shabadsToAdd: [[String: Any]], status: Bool)
}
class AddPlaylistVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var navigationView: NavigationBarView!

    var raagiName: String?
    var playlistName: String?
    var shabad: Shabad?
    var delegate: AddPlaylistDelegate?
    var playlists = [Playlist]()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    func initialize() {
        if let name = playlistName {
            navigationView.leftNavTitle = name
        } else {
            navigationView.leftNavTitle = "Add to playlist"
        }
        navigationView.leftNavButton.addTarget(self, action: #selector(btnBackClicked), for: .touchUpInside)
        tableview.allowsMultipleSelection = true
//        if let name = raagiName {
//        loadShabadsList(name)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getPlaylists()
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Other methods
    // Load Shabads according to raagi name
    func getPlaylists() {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            
            let queryString = "userRoutes/users/\(user.username!)" + EndPointMethod.playlists
            NetworkManager.sharedManager.getRequest(with: queryString, nil) { (status, error, result) in
                NetworkManager.stopLoader()
                if status {
                    self.playlists.removeAll()
                    if let arrayJSON = result.array {
                        for dictJSON in arrayJSON {
                            let playlist = Playlist()
                            playlist.setContent(dictJSON)
                            self.playlists.append(playlist)
                        }
                    }
                    self.tableview.reloadData()
                }
            }
        }
    }
    func addShabadToPlaylist(_ shabadsToAdd: [[String: Any]], playlist: String) {
        if let _ = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            NetworkManager.sharedManager.postRequestWithArrayEncoded(with: PlaylistMethod.addShabadURL, shabadsToAdd) { (status, response, json) in
                NetworkManager.stopLoader()
                if status {
                    var message = ""
                    if let shabad = self.shabad {
                        message = "\(shabad.shabad_english_title) added to \(playlist)."
                        self.getPlaylists()
                    } else {
                        message = Messages.shabadsAdded
                    }
                    Helper.showMessage(message: message, success: true)
                }
            }
        }
    }
     // MARK: - Actions
    @objc func btnBackClicked() {
        self.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.createPlaylistFromAdd {
            let destinationVc = segue.destination as! CreatePlaylistVC
            destinationVc.playlists = playlists
            destinationVc.delegate = self
        }
    }

}

extension AddPlaylistVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPlaylistHeader.className, for: indexPath) as! AddPlaylistHeader
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        let playlistCell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.className) as! PlaylistCell
        playlistCell.selectionStyle = .none
        playlistCell.delegate = self
        playlistCell.optionsButton.isHidden = true
        playlistCell.setUpContent(playlists[indexPath.row - 1])
        return playlistCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            if let shabad = shabad {
                if let cell = tableView.cellForRow(at: indexPath) {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    }, completion: { finished in
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {                                             cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }, completion: { finished in
                            let playlist = self.playlists[indexPath.row - 1].playlist_name
                            let dict = PlaylistMethod.parametersForAddShabad(username: CoreDataService.getLogin()!.username!, playlist_name: playlist, id: shabad.id)
                            self.addShabadToPlaylist([dict], playlist: playlist)
                        }
                        ) } )
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension AddPlaylistVC: CreateHeaderDelegate {
    func didTapCreateButton() {
        self.performSegue(withIdentifier: Segue.createPlaylistFromAdd, sender: nil)
    }
}
extension AddPlaylistVC: PlaylistCellDelegate {
    func didClickedDeletePlaylist(_ cell: PlaylistCell) {
    }
}
extension AddPlaylistVC: CreatePlaylistDelegate {
    func didCreatePlaylist() {
        getPlaylists()
    }
}
