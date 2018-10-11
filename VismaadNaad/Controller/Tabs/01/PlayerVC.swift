//
//  PlayerVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 26/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import MediaPlayer
import FRadioPlayer
import DropDown
import GoogleMobileAds
import FBAudienceNetwork
class PlayerVC: UIViewController {
    
    @IBOutlet weak var navigationView: NavigationBarView!
    var bannerView: GADBannerView!

    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var raagiNameLabel: UILabel!
    @IBOutlet weak var shabadNameLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var moreOptionsButton: UIButton!
    
    @IBOutlet weak var slider: ProgressSlider!
    
    @IBOutlet weak var lcBottomMusicControls: NSLayoutConstraint!
    var dropDown = DropDown()
    
    var shabadDetailList = [ShabadDetail]()
    var shabadList = [Shabad]()
    var selectedLanguages = [String]()
    var isAlreadyPlayingShabad = false
    
    // Singleton reference to player
    let shabadPlayer = Player.shared
    let toast = ToastManager.shared
    
    var fontSize = FontSize.normal
    var selectedIndex = 0
    var fullScreenAd: FBInterstitialAd!
    var shabad: Shabad? {
        didSet {
            raagiNameLabel.text = shabad?.raagi_name
            shabadNameLabel.text = shabad?.shabad_english_title
            
        }
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    func initialize() {
        textview.text = nil
        raagiNameLabel.text = shabad?.raagi_name
        shabadNameLabel.text = shabad?.shabad_english_title
        slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .highlighted)
        navigationView.leftNavImage = #imageLiteral(resourceName: "back")
        navigationView.leftNavButton.addTarget(self, action: #selector(btnBackClicked), for: .touchUpInside)
        // FRadioPlayer settings
        shabadPlayer.delegate = self
        shabadPlayer.player.isAutoPlay = true
        shabadPlayer.shabadList = shabadList
        
        fontSize = UserDefaults.standard.double(forKey: UserDefaultsKey.zoomLevel)
        if let colorName = UserDefaults.standard.string(forKey: UserDefaultsKey.color) {
            textview.backgroundColor = Helper.changeColor(colorName)
        }
        
        shabad = shabadList[selectedIndex]

        if let shabad = shabad {
            rewindButton.isEnabled = false
            forwardButton.isEnabled = false
            playButton.isEnabled = false
            loadShabadLyrics(shabad)
        }
        // If shabad is already playing, enable rewind and pause button
        if isAlreadyPlayingShabad == true {
            rewindButton.isEnabled = true
            forwardButton.isEnabled = true
            playButton.isEnabled = true
            if let totalDuration = shabadPlayer.player.playerItem?.duration {
                if totalDuration.value != 0 {
                    totalDurationLabel.text = totalDuration.durationText
                    slider.maximumValue = totalDuration.floatValue
                }
            }
            if let duration = shabadPlayer.player.playerItem?.currentTime() {
                currentDurationLabel.text = duration.durationText
                slider.value = duration.floatValue
            }
            
            if shabadPlayer.player.isPlaying == false {
                playButton.isSelected = true
            } else {
                playButton.isSelected = false
            }
        } else {
            shabadPlayer.selectedIndex = selectedIndex
        }
        googleAdBanner()
        showFullScreenAd()
        addObservers()
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateShabadDetails(_:)), name: NSNotification.Name(NotificationObserverKey.playerStateDidChange), object: nil)
    }
    
    @objc func updateShabadDetails(_ notification: Notification) {
        if let state = notification.object as? FRadioPlaybackState {
            if state == .playing {
                self.playButton.isSelected = false
            } else {
                self.playButton.isSelected = true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    @IBAction func btnLanguageSelectionClicked(_ sender: Any) {
        self.performSegue(withIdentifier: Segue.setting, sender: sender)
    }
    @IBAction func btnLikeClicked(_ sender: Any) {
        self.view.makeToast("Liked")
    }
    @IBAction func btnMoreOptionsClicked(_ sender: UIButton) {
        if CoreDataService.isGuestUser() == false {
            self.performSegue(withIdentifier: Segue.addPlaylistFromPlayer, sender: sender)
        } else {
            Helper.showMessage(message: Messages.notLoggedIn, success: false)
        }
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        if let _ = shabadPlayer.player.playerItem?.duration {
            shabadPlayer.player.seek(toSecond: Int(Double(slider.value)))
        }
    }
    
    // MARK: - Other methods
    // Load lyrics of shabad
    func loadShabadLyrics(_ shabad: Shabad) {
        NetworkManager.startLoader()
        let queryString = "sggsRoutes/linesFrom/\(shabad.starting_id)/linesTo/\(shabad.ending_id)"
        NetworkManager.sharedManager.getRequest(with: queryString, nil) { (status, error, result) in
            if status {
                if let arrayJSON = result.array {
                    self.shabadDetailList.removeAll()
                    for dictJSON in arrayJSON {
                        let shabadDetail = ShabadDetail()
                        shabadDetail.setContent(dictJSON)
                        self.shabadDetailList.append(shabadDetail)
                    }
                    self.raagiNameLabel.text = shabad.raagi_name
                    self.shabadNameLabel.text = shabad.shabad_english_title
                    
                    // Language in which text is to be displayed.
                    if let languages = UserDefaults.standard.array(forKey: UserDefaultsKey.language) as? [String] {
                        if languages.count > 0 {
                            self.didChangeLanguages(languages)
                        } else {
                            self.displayShabadInGurmukhi()
                        }
                    }
                }
            }
            NetworkManager.stopLoader()
        }
    }
    @objc func displayShabadInGurmukhi() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiTeeka() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaPadArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekPadArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekaArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiPunjabi() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.punjabi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.punjabiColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiEnglish() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.english, attributes: [NSAttributedStringKey.font : FontHelper.verdana(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.englishColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiTeekaPunjabi() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaPadArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekPadArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekaArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.punjabi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.punjabiColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiTeekaEnglish() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.english, attributes: [NSAttributedStringKey.font : FontHelper.verdana(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.englishColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaPadArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekPadArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekaArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    @objc func displayShabadInGurmukhiPunjabiEnglish() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.punjabi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.punjabiColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.english, attributes: [NSAttributedStringKey.font : FontHelper.verdana(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.englishColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    
    @objc func displayShabadInGurmukhiTeekaPunjabiEnglish() {
        let attributedString = NSMutableAttributedString()
        for shabadDetail in shabadDetailList {
            attributedString.append(NSMutableAttributedString(string: shabadDetail.gurmukhi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize)), NSAttributedStringKey.foregroundColor: TextFormatting.gurbaniColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.punjabi, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.punjabiColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.english, attributes: [NSAttributedStringKey.font : FontHelper.verdana(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.englishColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaPadArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekPadArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.singleLineBreak))
            attributedString.append(NSMutableAttributedString(string: shabadDetail.teekaArth, attributes: [NSAttributedStringKey.font : FontHelper.guruLippi(fontsize: CGFloat(fontSize - 7)), NSAttributedStringKey.foregroundColor: TextFormatting.teekaArthColor]))
            attributedString.append(NSAttributedString(string: TextFormatting.doubleLineBreak))
        }
        textview.attributedText = attributedString
        textview.textAlignment = .center
    }
    
    
    // MARK: - Actions
    @objc func btnBackClicked() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func playTap(_ sender: UIButton) {
        shabadPlayer.player.togglePlaying()
        if shabadPlayer.player.isPlaying {
            playButton.isSelected = false
        } else {
            playButton.isSelected = true
        }
    }
    
    @IBAction func previousTap(_ sender: Any) {
        previous()
    }
    
    @IBAction func nextTap(_ sender: Any) {
        next()
    }
    
    @IBAction func fastForwardTap(_ sender: Any) {
        fastForward()
    }
    
    @IBAction func fastRewindTap(_ sender: Any) {
        fastRewind()
    }
    
    //MARK: - Music Player methods
    func next() {
        shabadPlayer.next()
        //        selectedIndex += 1
    }
    
    func previous() {
        shabadPlayer.previous()
        //        selectedIndex -= 1
    }
    
    func fastForward() {
        if let _ = shabadPlayer.player.playerItem?.duration {
            shabadPlayer.player.seek(toSecond: Int(Double(slider.value) + 5))
        }
    }
    
    func fastRewind() {
        if let _ = shabadPlayer.player.playerItem?.duration {
            shabadPlayer.player.seek(toSecond: Int(Double(slider.value) - 5))
        }
    }
    
    //MARK: - Google Ads
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMob.playerAdUnitKey
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
    
    //MARK: - Facebook Ads
    func showFullScreenAd() {
        var visits = UserDefaults.standard.integer(forKey: UserDefaultsKey.visitsToPlayer)
        if visits > 10 {
            fullScreenAd = FBInterstitialAd(placementID: FacebookAd.fullScreenAdKey)
            fullScreenAd.delegate = self
            fullScreenAd.load()
            visits = 0
        }
        visits = visits + 1
        UserDefaults.standard.set(visits, forKey: UserDefaultsKey.visitsToPlayer)
        UserDefaults.standard.synchronize()
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.setting {
            let settingsVc = segue.destination as! SettingsVC
            settingsVc.delegate = self
            settingsVc.languagesSelected = selectedLanguages
        }
        else if segue.identifier == Segue.addPlaylistFromPlayer {
            let destinationVc = segue.destination as! AddPlaylistVC
            destinationVc.shabad = shabad
            destinationVc.raagiName = shabad?.raagi_name
        }
    }
}

//MARK: - PlayerDelegate Delegates
extension PlayerVC: PlayerDelegate {
    func updateShabad(_ shabad: Shabad) {
        self.shabad = shabad
        loadShabadLyrics(shabad)
    }
    
    func playbackProgressDidChange(_ player: FRadioPlayer) {
        if let duration = player.playerItem?.currentTime() {
            currentDurationLabel.text = duration.durationText
            slider.value = duration.floatValue
        }
        
        if let totalDuration = player.playerItem?.duration {
            if totalDuration.value != 0 {
                totalDurationLabel.text = totalDuration.durationText
                slider.maximumValue = totalDuration.floatValue
            }
        }
        if slider.value == slider.maximumValue {
            print("Shabad playing finished")
            slider.value = 0
            currentDurationLabel.text = "00.00"
            next()
        }
    }
    func player(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
//        if state == .loading {
//          //  self.view.makeToast(PlayingState.loading)
//            rewindButton.isEnabled = false
//            forwardButton.isEnabled = false
//            playButton.isEnabled = false
//        } else if state == .loadingFinished {
//     //       self.view.makeToast(PlayingState.loadingFinished)
//            rewindButton.isEnabled = true
//            forwardButton.isEnabled = true
//            if (player.playbackState == .playing) {
//            playButton.isSelected = false
//            playButton.isEnabled = true
//            }
//        }
    }
    
    func player(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        if state == .playing {
            rewindButton.isEnabled = true
            forwardButton.isEnabled = true
            playButton.isEnabled = true
        } else {

            //            rewindButton.isEnabled = false
            //            forwardButton.isEnabled = false
        }
    }   
}

//MARK: - Settings Delegates
extension PlayerVC: SettingDelegate {
    func didChangeZoomLevel(_ level: Double) {
        fontSize = level
        didChangeLanguages(selectedLanguages)
    }
    
    func didChangeColor(_ color: UIColor) {
        textview.backgroundColor = color
    }
    
    func didChangeLanguages(_ languages: [String]) {
        selectedLanguages = languages
        if languages.contains(Language.english) && languages.contains(Language.punjabi) && languages.contains(Language.teeka) {
            displayShabadInGurmukhiTeekaPunjabiEnglish()
        }
        else if languages.contains(Language.english) && languages.contains(Language.punjabi) {
            displayShabadInGurmukhiPunjabiEnglish()
        }
        else if languages.contains(Language.english) && languages.contains(Language.teeka) {
            displayShabadInGurmukhiTeekaEnglish()
        }
        else if languages.contains(Language.punjabi) && languages.contains(Language.teeka) {
            displayShabadInGurmukhiTeekaPunjabi()
        }
        else if languages.contains(Language.english) {
            displayShabadInGurmukhiEnglish()
        }
        else if languages.contains(Language.punjabi) {
            displayShabadInGurmukhiPunjabi()
        }
        else if languages.contains(Language.teeka) {
            displayShabadInGurmukhiTeeka()
        } else {
            displayShabadInGurmukhi()
        }
    }
}


extension PlayerVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        lcBottomMusicControls.constant = 40
        bannerView.alpha = 1
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
extension PlayerVC: FBInterstitialAdDelegate {
    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print(error.localizedDescription)
        self.shabadPlayer.player.play()
    }

    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        interstitialAd.show(fromRootViewController: self)
        self.shabadPlayer.player.stop()
    }
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        self.shabadPlayer.player.play()
    }
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        
    }
}
