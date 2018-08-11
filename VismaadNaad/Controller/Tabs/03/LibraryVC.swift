
//
//  LibraryVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 24/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import FRadioPlayer
import GoogleMobileAds
class LibraryVC: UIViewController {
    
    var playlists = [Playlist]()
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var shabadPreview: ShabadPeview!
    @IBOutlet weak var lcTopTableview: NSLayoutConstraint!
    let player = Player.shared
    var bannerView: GADBannerView!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = CoreDataService.getLogin() {
        } else {
            showDialog()
        }
        addObservers()
        shabadPreview.playButton.addTarget(self, action: #selector(btnPlayClicked(_ :)), for: .touchUpInside)
        shabadPreview.detailButton.addTarget(self, action: #selector(btnDetailClicked), for: .touchUpInside)
        googleAdBanner()
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShabadDetails(_:)), name: NSNotification.Name(NotificationObserverKey.playerStateDidChange), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = CoreDataService.getLogin() {
            getPlaylists()
        }
        shabadPreview.isHidden = true
        
        
        // Check if any shabad was playing last time app was exited, if yes restart the player
        if let shabad = player.currentShabadPlaying() {
            shabadPreview.shabadName = shabad.shabad_english_title
            shabadPreview.raagiName = shabad.raagi_name
            shabadPreview.isHidden = false
            shabadPreview.playing = false
            if let shabadList = player.currentShabadList() {
                player.shabadList = shabadList
            }
        }
        
    }
    func showDialog()  {
        let dialogVc = self.storyboard?.instantiateViewController(withIdentifier: DialogVC.className) as! DialogVC
        dialogVc.set(message: Messages.notLoggedIn, delegate: self, cancelButtonTitle: "CANCEL", okButtonTitle: "PROCEED")
        dialogVc.delegate = self
        self.view.addSubview(dialogVc.view)
        self.addChildViewController(dialogVc)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @objc func btnPlayClicked(_ sender: UIButton) {
        if player.player.state == .urlNotSet {
            player.selectedIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.currentIndexOfShabad)
        }
        player.togglePlay()
        shabadPreview.playing = !shabadPreview.playing
    }
    
    @objc func btnDetailClicked() {
        self.performSegue(withIdentifier: Segue.playerDirectFromLibrary, sender: self)
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
    func deletePlaylist(_ playlist: String, from indexpath: IndexPath) {
        if let user = CoreDataService.getLogin() {
            let name = playlists[indexpath.row - 1].playlist_name
            NetworkManager.startLoader()
            let parameters = PlaylistMethod.parametersForDeletePlaylist(username: user.username!, playlist_name: name)
            NetworkManager.sharedManager.postRequest(with: PlaylistMethod.deleteURL, parameters) { (status, response, json) in
                NetworkManager.stopLoader()
                if status {
                    let statusCode = json["ResponseCode"].int
                    if statusCode == 200 {
                        self.playlists.remove(at: indexpath.row - 1)
                        self.tableview.reloadData()
                        Helper.showMessage(message: "\(playlist.capitalized) removed from playlists.", success: true)
                        
                    } else {
                        Helper.showMessage(message: "\(playlist.capitalized) couldn't be removed. Please try again later.", success: true)
                    }
                } else {
                    Helper.showMessage(message: "\(playlist.capitalized) couldn't be removed. Please try again later.", success: true)
                }
            }}
    }
    @objc func updateShabadDetails(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: String] {
            shabadPreview.shabadName = userInfo["shabadName"]
            shabadPreview.raagiName = userInfo["raagiName"]
        }
        if let state = notification.object as? FRadioPlaybackState {
            if state == .playing {
                shabadPreview.playing = true
                player.player.seek(toSecond: Int(Double(UserDefaults.standard.float(forKey: UserDefaultsKey.currentShabadDuration))))
                UserDefaults.standard.synchronize()
            } else {
                shabadPreview.playing = false
            }
        }
    }
    
    //MARK: - Google Ads
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMob.libraryAdUnitKey
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtTopOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtTopOfView(bannerView)
        }
    }
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtTopOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.topAnchor.constraint(equalTo: bannerView.topAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtTopOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: topLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.playerDirectFromLibrary {
            let destinationVc = segue.destination as! PlayerVC
            destinationVc.hidesBottomBarWhenPushed = true
            destinationVc.shabadList = player.shabadList
            if player.player.state == .urlNotSet {
                player.selectedIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.currentIndexOfShabad)
            }
            destinationVc.selectedIndex = player.selectedIndex
            destinationVc.isAlreadyPlayingShabad = true
        }
        else if segue.identifier == Segue.playlist {
            let destinationVc = segue.destination as! PlaylistVC
            if let indexpath = sender as? IndexPath {
                destinationVc.playlistName = playlists[indexpath.row - 1].playlist_name
            }
        }
        else if segue.identifier == Segue.createPlaylistFromLibrary {
            let destinationVc = segue.destination as! CreatePlaylistVC
            destinationVc.playlists = playlists
        }
    }
    
}
//MARK: - Tableview methods
extension LibraryVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let addPlaylistHeaderCell = tableView.dequeueReusableCell(withIdentifier: AddPlaylistHeader.className) as! AddPlaylistHeader
            addPlaylistHeaderCell.selectionStyle = .none
            addPlaylistHeaderCell.delegate = self
            addPlaylistHeaderCell.delegate = self
            return addPlaylistHeaderCell
        }
        let playlistCell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.className) as! PlaylistCell
        playlistCell.selectionStyle = .none
        playlistCell.delegate = self
        playlistCell.setUpContent(playlists[indexPath.row - 1])
        return playlistCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { finished in
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {                                             cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { finished in
                        self.performSegue(withIdentifier: Segue.playlist, sender: indexPath)
                    }
                    ) } )
            }

        }
    }
    
}
extension LibraryVC: CreateHeaderDelegate {
    func didTapCreateButton() {
        if let _ = CoreDataService.getLogin() {
            self.performSegue(withIdentifier: Segue.createPlaylistFromLibrary, sender: nil)
        } else {
            showDialog()
        }
    }
}
extension LibraryVC: PlaylistCellDelegate {
    func didClickedDeletePlaylist(_ cell: PlaylistCell) {
        if let indexpath = self.tableview.indexPath(for: cell)  {
            let alert = UIAlertController.init(title: "", message: "Are you sure you want to delete \(cell.lblPlaylistName.text!) playlist?", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) in
                self.deletePlaylist(cell.lblPlaylistName.text!, from : indexpath)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension LibraryVC: DialogDelegate {
    func didClickedOk() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func didClickedCancel() {
        self.tabBarController?.selectedIndex = 0
    }
}
extension LibraryVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        lcTopTableview.constant = 55
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
}
