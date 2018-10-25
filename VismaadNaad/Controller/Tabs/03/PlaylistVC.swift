
//
//  PlaylistVC.swift
//  VismaadNaad
//
//  Created by Jasmeet Singh on 02/07/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import ParallaxHeader
import FRadioPlayer
import SDWebImage
import GoogleMobileAds

class PlaylistVC: UIViewController {
    var shabadsList = [Shabad]()
    var filteredShabadsList = [Shabad]()
    var playlistName: String?
    @IBOutlet weak var lcBottomShabadPreview: NSLayoutConstraint!
    @IBOutlet weak var lcBottomTableview: NSLayoutConstraint!
    @IBOutlet weak var shabadPreview: ShabadPeview!
    var bannerView: GADBannerView!
    
    let player = Player.shared

    @IBOutlet weak var tableview: UITableView!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    func initialize() {
        
        tableview.estimatedRowHeight = UITableViewAutomaticDimension
        if #available(iOS 11.0, *) {
            tableview.contentInsetAdjustmentBehavior = .never
        }
        
        shabadPreview.isHidden = true
        shabadPreview.playButton.addTarget(self, action: #selector(btnPlayClicked(_ :)), for: .touchUpInside)
        shabadPreview.detailButton.addTarget(self, action: #selector(btnDetailClicked), for: .touchUpInside)
        
        // Check if any shabad was playing last time app was exited, if yes restart the player
        if let shabad = player.currentShabadPlaying() {
            shabadPreview.shabadName = shabad.shabad_english_title
            shabadPreview.raagiName = shabad.raagi_name
            shabadPreview.isHidden = false
            shabadPreview.playing = false
            lcBottomTableview.constant = 50
            if let shabadList = player.currentShabadList() {
                player.shabadList = shabadList
            }
        }
        
        if let playlist = playlistName {
            loadShabads(playlist)
        }
        googleAdBanner()
    }
  
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
                        let headerView = DetailTableHeader.init(frame: .zero)
                        headerView.setUpContent(name, shabads: self.filteredShabadsList.count)
                        self.tableview.parallaxHeader.view = headerView
                        self.tableview.parallaxHeader.height = 280
                        self.tableview.parallaxHeader.minimumHeight = 60
                        self.tableview.parallaxHeader.mode = .bottomFill
                        self.tableview.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                        }
                    }
                    self.tableview.reloadData()
                }
                NetworkManager.stopLoader()
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
    @IBAction func btnBackClicked() {
        navigationController?.popViewController(animated: true)
    }
    @objc func btnPlayClicked(_ sender: UIButton) {
        if player.player.state == .urlNotSet {
            player.selectedIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.currentIndexOfShabad)
        }
        player.togglePlay()
        shabadPreview.playing = !shabadPreview.playing
    }
    @objc func btnDetailClicked() {
        self.performSegue(withIdentifier: Segue.playerFromPlaylistDetail, sender: self)
    }

    //MARK: - Google Ads
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMob.playlistAdUnitKey
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
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
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if let indexpath = sender as? IndexPath {
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

extension PlaylistVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredShabadsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shabadCell = tableView.dequeueReusableCell(withIdentifier: PlaylistShabadCell.className, for: indexPath) as! PlaylistShabadCell
        shabadCell.selectionStyle = .none
        let shabad = filteredShabadsList[indexPath.row]
        shabadCell.setUpContent(shabad)
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
                    self.performSegue(withIdentifier: Segue.playerFromPlayist, sender: indexPath)
                }
                ) } )
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 80
//        }
        return UITableViewAutomaticDimension
    }
}
extension PlaylistVC: PlaylistShabadDelegate {
   
    func didClickedPlayNow(_ cell: PlaylistShabadCell) {
        if let indexPath = tableview.indexPath(for: cell) {
            self.performSegue(withIdentifier: Segue.playerFromPlayist, sender: indexPath)
        }
    }
    func didClickedRemoveFromFavorite(_ cell: PlaylistShabadCell) {
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

extension PlaylistVC: CreateHeaderDelegate {
    func didTapCreateButton() {
        if let controller = AppDelegate.shared().window?.rootViewController as? UINavigationController {
            for vc in controller.viewControllers {
                if let tabVc = vc as? UITabBarController {
                    tabVc.selectedIndex = 0
                    self.navigationController?.popViewController(animated: true)
                    break
                }
            }
        }
    }
}

extension PlaylistVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        lcBottomShabadPreview.constant = 55
        if shabadPreview.isHidden == false {
            lcBottomTableview.constant = 100
        } else {
            lcBottomTableview.constant = 55
        }
        bannerView.alpha = 1

//        UIView.animate(withDuration: 1, animations: {
//            bannerView.alpha = 1
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
