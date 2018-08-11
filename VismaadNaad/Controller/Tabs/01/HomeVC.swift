//
//  ViewController.swift
//  Player
//
//  Created by B2BConnect on 21/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SDWebImage
import FRadioPlayer
import GoogleMobileAds
//import FBAudienceNetwork

class HomeVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var shabadPreview: ShabadPeview!
    
    @IBOutlet weak var lcShabadPreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var lcTopCollectionView: NSLayoutConstraint!
    var bannerView: GADBannerView!
    var albumList = [Album]()
    var filteredAlbumList = [Album]()
    
    let player = Player.shared
    
//    let adRowStep = 7
//    var adsManager: FBNativeAdsManager!
//    var adsCellProvider: FBNativeAdCollectionViewCellProvider!
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        loadAlbumList()
        addObservers()
        googleAdBanner()
        shabadPreview.isHidden = true
        
        shabadPreview.playButton.addTarget(self, action: #selector(btnPlayClicked(_ :)), for: .touchUpInside)
        shabadPreview.detailButton.addTarget(self, action: #selector(btnDetailClicked), for: .touchUpInside)
        
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
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShabadDetails(_:)), name: NSNotification.Name(NotificationObserverKey.playerStateDidChange), object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.performSegue(withIdentifier: Segue.playerDirect, sender: self)
    }
    
    
    
    //MARK: - Other methods
    // Load albumList
    func loadAlbumList() {
        NetworkManager.startLoader()
        NetworkManager.sharedManager.getRequest(with: EndPointMethod.raagiInfo, nil) { (status, error, result) in
            NetworkManager.stopLoader()
            if status {
                if let arrayJSON = result.array {
                    for dictJSON in arrayJSON{
                        let album = Album()
                        album.setContent(dictJSON)
                        self.albumList.append(album)
                    }
                    self.filteredAlbumList = self.albumList
                 //   self.configureAdManagerAndLoadAds()
                }
                self.collectionView.reloadData()
            }
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
                player.player.seek(toSecond: Int(Double(UserDefaults.standard.float(forKey: UserDefaultsKey.currentShabadDuration))))
                UserDefaults.standard.synchronize()
            } else {
                shabadPreview.playing = false
            }
        }
    }
    
    //MARK: - Google / Facebook Ads
//    func configureAdManagerAndLoadAds() {
//        if adsManager == nil {
//            FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
//            adsManager = FBNativeAdsManager(placementID: FacebookAd.key, forNumAdsRequested: 3)
//            adsManager.delegate = self
//            adsManager.mediaCachePolicy = .all
//            adsManager.loadAds()
//        }
//    }
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMob.homeAdUnitKey
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.playerDirect {
            let destinationVc = segue.destination as! PlayerVC
            destinationVc.hidesBottomBarWhenPushed = true
            destinationVc.shabadList = player.shabadList
            if player.player.state == .urlNotSet {
                player.selectedIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.currentIndexOfShabad)
            }
            destinationVc.selectedIndex = player.selectedIndex
            destinationVc.isAlreadyPlayingShabad = true
        } else {
            if let indexpath = sender as? IndexPath {
                if segue.identifier == Segue.detail {
//                    let album = filteredAlbumList[indexpath.item - Int(indexpath.item / adRowStep)]
                    let album = filteredAlbumList[indexpath.item]
                    let destinationVc = segue.destination as! DetailVC
                    destinationVc.hidesBottomBarWhenPushed = true
                    destinationVc.album = album
                } else if segue.identifier == Segue.option {
                    let album = filteredAlbumList[indexpath.row]
                    let destinationVc = segue.destination as! OptionVC
                    destinationVc.album = album
                }
            }
        }
    }
    
}

//MARK: - CollectionView methods
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return 0
        }
        return filteredAlbumList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
//            return adsCellProvider.collectionView(collectionView, cellForItemAt:indexPath)
//        }
        let albumCell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionCell.className, for: indexPath) as! AlbumCollectionCell
        albumCell.delegate = self
//        let album = filteredAlbumList[indexPath.item - Int(indexPath.item / adRowStep)]
        let album = filteredAlbumList[indexPath.item]
        albumCell.setUpAlbum(album)
        return albumCell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
//            return CGSize(width: UIScreen.main.bounds.size.width, height: 60)
//        }
        let width = (UIScreen.main.bounds.size.width / 3) - 10
        if Display.typeIsLike == .iphone5 {
            return CGSize(width: width, height: width + 110)
        }
        else if Display.typeIsLike == .iphone7  {
            return CGSize(width: width, height: width + 90)
        }
        else if Display.typeIsLike == .iphoneX {
            return CGSize(width: width, height: width + 90)
        }
        return CGSize(width: width, height: width + 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(section == 0) {
            return CGSize(width:collectionView.frame.size.width, height:110)
        } else {
            return CGSize.zero
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        if (kind == UICollectionElementKindSectionHeader) {
            let section = indexPath.section
            switch (section) {
            case 0:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchCollectionHeader.className, for: indexPath) as! SearchCollectionHeader
                headerView.delegate = self
                reusableview = headerView
            default:
                return reusableview
                
            }
        }
        return reusableview
    }
}

extension HomeVC: AlbumCollectionDelegate {
    func didSingleTap(_ cell: AlbumCollectionCell) {
        let indexPath = collectionView.indexPath(for: cell)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {                                             cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { finished in
                self.performSegue(withIdentifier: Segue.detail, sender: indexPath)
            }
            ) } )
    }
    func didLongPress(_ cell: AlbumCollectionCell) {
        let indexPath = collectionView.indexPath(for: cell)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {                                             cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { finished in
                self.performSegue(withIdentifier: Segue.option, sender: indexPath)
            }
            ) }
        )
    }
    func didAddToFavorite(_ cell: AlbumCollectionCell) {
        if CoreDataService.isGuestUser() == false {
            if let _ = collectionView.indexPath(for: cell) {
            }
        } else {
            Helper.showMessage(message: Messages.notLoggedIn, success: false)
        }
    }
}


extension HomeVC: SearchCollectionHeaderDelegate {
    func searchFieldTextChange(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            searchResults(updatedText)
        }
    }
    
    func searchFieldDidReturn(_ textField: UITextField) {
        view.endEditing(true)
    }
    
    func reload() {
        view.endEditing(true)
        filteredAlbumList = albumList
        collectionView.reloadData()
    }
    
    func searchResults(_ text: String) {
        if text.isEmpty == false {
            filteredAlbumList = albumList.filter { $0.raagi_name.range(of: text, options: [.diacriticInsensitive, .caseInsensitive]) != nil }
        } else {
            filteredAlbumList = albumList
        }
        collectionView.reloadSections(IndexSet.init(integer: 1))
    }
    
}
extension HomeVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        lcTopCollectionView.constant = 55
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
//extension HomeVC: FBNativeAdDelegate, FBNativeAdsManagerDelegate {
//    func nativeAdsFailedToLoadWithError(_ error: Error) {
//        print(error.localizedDescription)
//    }
//
//    func nativeAdsLoaded() {
//        adsCellProvider = FBNativeAdCollectionViewCellProvider.init(manager: adsManager, for: FBNativeAdViewType.genericHeight100)
//        adsCellProvider.delegate = self
//
//        if collectionView != nil {
//            collectionView.reloadData()
//        }
//    }
//    func nativeAdsFailedToLoadWithError(error: Error) {
//        print(error)
//    }
//    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
//    }
//}
