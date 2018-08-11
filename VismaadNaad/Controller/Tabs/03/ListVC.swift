

//
//  ListVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 08/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import Alamofire
class ListVC: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var navigationView: NavigationBarView!

    var playlists = [String]()
    var shabad: Shabad?
    var raagiName: String?
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    func initialize() {
        navigationView.leftNavButton.addTarget(self, action: #selector(btnBackClicked), for: .touchUpInside)
        
        tableview.estimatedRowHeight = 110
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getPlaylists()

    }
    
    // MARK: - Other methods
    func getPlaylists() {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()

            let queryString = "userRoutes/users/\(user.username!)" + EndPointMethod.playlists
            NetworkManager.sharedManager.getRequest(with: queryString, nil) { (status, error, result) in
                NetworkManager.stopLoader()
                if status {
                    self.playlists.removeAll()
                    if let arrayJSON = result.array {
                        for playlist in arrayJSON {
                            self.playlists.append(playlist.stringValue)
                        }
                    }
                    self.tableview.reloadData()
                }
            }
      }
    }
    
    func addShabadToPlaylist(_ shabadsToAdd: [[String: Any]]) {
        if let _ = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            NetworkManager.sharedManager.postRequestWithArrayEncoded(with: PlaylistMethod.addShabadURL, shabadsToAdd) { (status, response, json) in
                NetworkManager.stopLoader()
                if status {
                    var message = ""
                    if let shabad = self.shabad {
                        message = "\(shabad.shabad_english_title) added to playlist."
                    } else {
                        message = Messages.shabadsAdded
                    }
                    Helper.showMessage(message: message, success: true)
                }
            }
        }
    }
    
    func deletePlaylist(_ indexpath: IndexPath) {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            let playlistName = playlists[indexpath.row - 1]

            NetworkManager.sharedManager.postRequest(with: PlaylistMethod.deleteURL, PlaylistMethod.parametersForDeletePlaylist(username: user.username!, playlist_name: playlistName)) { (status, response, json) in
                NetworkManager.stopLoader()
                if status {
                    let statusCode = json["ResponseCode"].int
                    if statusCode == 200 {
                        Helper.showMessage(message: "Playlist \(playlistName) deleted.", success: true)
                        self.playlists.remove(at: indexpath.row - 1)
                        self.tableview.reloadData()
                    } else {
                        Helper.showMessage(message: "Playlist \(playlistName) not deleted. Please try again later", success: false)
                    }
                }
            }
        }
    }
    // MARK: - Actions
    @objc func btnBackClicked() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexpath = sender as? IndexPath {
            if segue.identifier == Segue.addPlaylist {
                let addPlaylistVc = segue.destination as! AddPlaylistVC
                if indexpath.row != 0 {
                    addPlaylistVc.playlistName = self.playlists[indexpath.row - 1]
                }
                addPlaylistVc.delegate = self
                addPlaylistVc.raagiName = raagiName
            }

        }
    }

}
extension ListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.className, for: indexPath) as! ListCell
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.lblPlaylistName.text = "Create Playlist"
            cell.imgPlaylist.image = #imageLiteral(resourceName: "addPlaylist")
        } else {
        cell.setUpContent(playlists[indexPath.row - 1])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: Segue.addPlaylist, sender: indexPath)
        } else {
            let playlistName = playlists[indexPath.row - 1]
            if let shabad = shabad {
                self.addShabadToPlaylist([PlaylistMethod.parametersForAddShabad(username: CoreDataService.getLogin()!.username!, playlist_name: playlistName, id: shabad.id)])
            } else {
                self.performSegue(withIdentifier: Segue.addPlaylist, sender: indexPath)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }
        return 65
    }
}

extension ListVC: AddPlaylistDelegate {
    func didAddPlaylist(_ shabadsToAdd: [[String: Any]], status: Bool) {
        self.addShabadToPlaylist(shabadsToAdd)
    }
}

