//
//  DetailVC.swift
//  SehajBani
//
//  Created by B2BConnect on 25/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import ParallaxHeader
import FRadioPlayer
import SDWebImage
import GoogleMobileAds
//import FBAudienceNetwork
class DetailVC: UIViewController {
    var album: Album?
    var shabadsList = [Shabad]()
    var filteredShabadsList = [Shabad]()
    var playlistName: String?
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var lcSearchVieLeading: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var shabadPreview: ShabadPeview!
    @IBOutlet weak var bannerView: GADBannerView!

    @IBOutlet weak var txtSearchField: UITextField!
    @IBOutlet weak var lcBottomTableview: NSLayoutConstraint!

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var lcSearchButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var lcTrailingCloseButton: NSLayoutConstraint!
    
//    let adRowStep = 6
    
//    var adsManager: FBNativeAdsManager!
//
//    var adsCellProvider: FBNativeAdTableViewCellProvider!
    let player = Player.shared
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        addObservers()
    }
    func initialize() {
        lcSearchButtonLeading.constant = UIScreen.main.bounds.size.width / 2 - 130
        self.tabBarController?.delegate = self
        bannerView.isHidden = true

        shabadPreview.isHidden = true
        shabadPreview.playButton.addTarget(self, action: #selector(btnPlayClicked(_ :)), for: .touchUpInside)
        shabadPreview.detailButton.addTarget(self, action: #selector(btnDetailClicked), for: .touchUpInside)
        
        if #available(iOS 11.0, *) {
            tableview.contentInsetAdjustmentBehavior = .never
        }
        if let playlist = playlistName {
            loadShabads(playlist)
        }
        
        // Check if any shabad was playing last time app was exited, if yes restart the player
        if let album = album {
            if let shabad = player.currentShabadPlaying() {
                shabadPreview.shabadName = shabad.shabad_english_title
                shabadPreview.raagiName = album.raagi_name
                shabadPreview.isHidden = false
                lcBottomTableview.constant = 50
                if player.player.state == .urlNotSet {
                    shabadPreview.playing = false
                } else {
                    shabadPreview.playing = true
                }
            }
            let headerView = DetailTableHeader.init(frame: .zero)
            headerView.setUpContent(album)
            tableview.parallaxHeader.view = headerView
            tableview.parallaxHeader.height = 280
            tableview.parallaxHeader.minimumHeight = 60
            tableview.parallaxHeader.mode = .bottomFill
            tableview.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                if parallaxHeader.progress < 0.3 {
                    if self.txtSearchField.isHidden == true {
                    }
                } else {
                }
            }
            loadShabadsList(album.raagi_name)
        }
     googleAdBanner()
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShabadDetails(_:)), name: NSNotification.Name(NotificationObserverKey.playerStateDidChange), object: nil)
    }
//    func configureAdManagerAndLoadAds() {
//        if adsManager == nil {
//            FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
//            adsManager = FBNativeAdsManager(placementID: FacebookAd.key, forNumAdsRequested: UInt(self.filteredShabadsList.count % 4))
//            adsManager.delegate = self
//            adsManager.mediaCachePolicy = .all
//            adsManager.loadAds()
//        }
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - Other methods
    // Load Shabads according to raagi name
    func loadShabads(_ name: String) {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            let queryString = "userRoutes/users/\(user.username!)/playlists/\(name)"
            NetworkManager.sharedManager.getRequest(with: queryString, nil) { (status, error, result) in
                if status {
                    if let arrayJSON = result.array {
                        for dictJSON in arrayJSON {
                            let shabad = Shabad()
                            shabad.setContent(dictJSON)
                            shabad.shabad_url = API.shabadBaseURL + shabad.raagi_name + "/" + shabad.shabad_english_title + ".mp3"
                            self.shabadsList.append(shabad)
                        }
                        self.filteredShabadsList = self.shabadsList

                    }
                    self.tableview.reloadData()
                }
                NetworkManager.stopLoader()
            }
        }
        
    }
    func loadShabadsList(_ name: String) {
        NetworkManager.startLoader()
        let queryString = "raagiRoutes/raagis/\(name)/shabads"
        NetworkManager.sharedManager.getRequest(with: queryString, nil) { (status, error, result) in
            if status {
                if let arrayJSON = result.array {
                    for dictJSON in arrayJSON {
                        let shabad = Shabad()
                        shabad.setContent(dictJSON)
                        shabad.raagi_name = self.album!.raagi_name
                        shabad.shabad_url = API.shabadBaseURL + self.album!.raagi_name + "/" + shabad.shabad_english_title + ".mp3"
                        self.shabadsList.append(shabad)
                    }
                    self.filteredShabadsList = self.shabadsList
//                    self.configureAdManagerAndLoadAds()

                }
                self.tableview.reloadData()
            }
            NetworkManager.stopLoader()
        }
    }
    @objc func updateShabadDetails(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: String] {
            shabadPreview.shabadName = userInfo["shabadName"]
            shabadPreview.raagiName = userInfo["raagiName"]
        }
        if let state = notification.object as? FRadioPlaybackState {
            if state == .playing {
                shabadPreview.playing = true
            } else {
                shabadPreview.playing = false
            }
        }
    }
    
    func removeShabadFromPlaylist(_ name: String, indexPath: IndexPath) {
        if let user = CoreDataService.getLogin() {
            NetworkManager.startLoader()
            let shabad = self.filteredShabadsList[indexPath.row]
            let parameters = [PlaylistMethod.parametersForRemoveShabad(username: user.username!, playlist_name: name, id: shabad.id)]
            NetworkManager.sharedManager.postRequestWithArrayEncoded(with: PlaylistMethod.removeShabadURL, parameters) { (status, response, json) in
                NetworkManager.stopLoader()
                if status {
                    let statusCode = json["ResponseCode"].int
                    if statusCode == 200 {
                        self.filteredShabadsList.remove(at: indexPath.row)
                        self.tableview.reloadData()
                        Helper.showMessage(message: "\(shabad.shabad_english_title.capitalized) removed from \(name).", success: true)
                    } else {
                        Helper.showMessage(message: "\(shabad.shabad_english_title.capitalized) couldn't be removed from \(name). Please try again later", success: false)
                    }
                } else {
                    Helper.showMessage(message: "\(shabad.shabad_english_title.capitalized) couldn't be removed from \(name). Please try again later", success: false)
                }
            }
        }
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
        self.performSegue(withIdentifier: Segue.player, sender: self)
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSearchClicked(_ sender: Any) {
        lcSearchButtonLeading.constant = 10
        txtSearchField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.closeButton.isHidden = false
        }
      
    }
    @IBAction func btnCloseClicked(_ sender: Any) {
        lcSearchButtonLeading.constant = UIScreen.main.bounds.size.width / 2 - 130
        view.endEditing(true)
        filteredShabadsList = shabadsList
        tableview.reloadData()
        txtSearchField.text = nil
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.closeButton.isHidden = true
        }
    }
    
    //MARK: - Google Ads
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView.adUnitID = AdMob.homeAdUnitKey
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.addPlaylistFromDetail {
            let destinationVc = segue.destination as! AddPlaylistVC
            if let indexpath = sender as? IndexPath {
                destinationVc.shabad = shabadsList[indexpath.row]
                destinationVc.raagiName = album!.raagi_name
            }
        }
        else if let indexpath = sender as? IndexPath {
            UserDefaults.standard.set(0.0, forKey: UserDefaultsKey.currentShabadDuration)
            UserDefaults.standard.synchronize()
            let destinationVc = segue.destination as! PlayerVC
            destinationVc.hidesBottomBarWhenPushed = true
            destinationVc.shabadList = filteredShabadsList
            destinationVc.selectedIndex = indexpath.row
        } else {
            let destinationVc = segue.destination as! PlayerVC
            destinationVc.hidesBottomBarWhenPushed = true
            destinationVc.shabadList = player.shabadList
            if player.player.state == .urlNotSet {
                player.selectedIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.currentIndexOfShabad)
            }
            destinationVc.selectedIndex = player.selectedIndex
            destinationVc.isAlreadyPlayingShabad = true
            
        }
    }
}

extension DetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if adsCellProvider != nil {
//            if filteredShabadsList.count == 0 {
//                return 0
//            }
//            return Int(adsCellProvider.adjustCount(UInt(self.filteredShabadsList.count), forStride: UInt(adRowStep)))
//        }
        return filteredShabadsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
//            return adsCellProvider.tableView(tableView, cellForRowAt: indexPath)
//        }
        let shabadCell = tableView.dequeueReusableCell(withIdentifier: DetailShabadCell.className, for: indexPath) as! DetailShabadCell
        shabadCell.selectionStyle = .none
//        let shabad = filteredShabadsList[indexPath.row - Int(indexPath.row / adRowStep)]
        let shabad = filteredShabadsList[indexPath.row]

        shabadCell.setUpContent(shabad)
        if let _ = playlistName {
            shabadCell.isPlaylist = true
        }
        shabadCell.delegate = self
        return shabadCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { finished in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {                                             cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: { finished in
                    self.performSegue(withIdentifier: Segue.player, sender: indexPath)
                }
                ) } )
        }
    }
}
extension DetailVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.btnSearchClicked(searchButton)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            searchResults(updatedText)
            
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func searchResults(_ text: String) {
        if text.isEmpty == false {
            filteredShabadsList = shabadsList.filter { $0.shabad_english_title.range(of: text, options: [.diacriticInsensitive, .caseInsensitive]) != nil }
        } else {
            filteredShabadsList = shabadsList
        }
        print("Filter shabads \(filteredShabadsList)")
//        self.configureAdManagerAndLoadAds()
        tableview.reloadData()
    }
    
}
extension DetailVC: DetailShabadDelegate {
    func didClickedPlayNow(_ cell: DetailShabadCell) {
        if let indexPath = tableview.indexPath(for: cell) {
            self.performSegue(withIdentifier: Segue.player, sender: indexPath)
        }
    }
    func didClickedAddToFavorite(_ cell: DetailShabadCell) {
        if let indexPath = tableview.indexPath(for: cell) {
            if CoreDataService.isGuestUser() == false {
                self.performSegue(withIdentifier: Segue.addPlaylistFromDetail, sender: indexPath)
            } else {
                Helper.showMessage(message: Messages.notLoggedIn, success: false)
            }
        }
    }
    func didClickedRemoveFromFavorite(_ cell: DetailShabadCell) {
        if let indexPath = tableview.indexPath(for: cell) {
            if let name = playlistName {
                let alert = UIAlertController.init(title: "", message: "Are you sure you want to delete \(cell.shabadNameLabel.text!) shabad ?", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) in
                    self.removeShabadFromPlaylist(name, indexPath: indexPath)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
}
extension DetailVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: LibraryVC.classForCoder()) {
        }
        return true
    }
}

extension DetailVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if shabadPreview.isHidden == false {
            lcBottomTableview.constant = 100
        } else {
            lcBottomTableview.constant = 55
        }
        bannerView.isHidden = false

//        UIView.animate(withDuration: 1, animations: {
//            self.view.layoutIfNeeded()
//        })
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
//extension DetailVC: FBNativeAdDelegate, FBNativeAdsManagerDelegate {
//    func nativeAdsFailedToLoadWithError(_ error: Error) {
//        print(error.localizedDescription)
//    }
//
//    func nativeAdsLoaded() {
//        adsCellProvider = FBNativeAdTableViewCellProvider(manager: adsManager, for: FBNativeAdViewType.genericHeight100)
//        adsCellProvider.delegate = self
//
//        if tableview != nil {
//            tableview.reloadData()
//        }
//    }
//    func nativeAdsFailedToLoadWithError(error: Error) {
//        print(error)
//    }
//    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
//    }
//}
