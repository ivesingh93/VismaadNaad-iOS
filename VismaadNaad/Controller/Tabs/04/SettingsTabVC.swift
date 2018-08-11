//
//  SettingsTabVC.swift
//  VismaadNaad
//
//  Created by Jasmeet Singh on 26/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
class SettingsTabVC: UIViewController {
    
    @IBOutlet weak var lcTopScrollView: NSLayoutConstraint!
    @IBOutlet weak var txtMessageField: UITextField!
    @IBOutlet weak var txtEmailField: UITextField!
    @IBOutlet weak var txtNameField: UITextField!
    @IBOutlet weak var btnLogout: UIButton!

    var bannerView: GADBannerView!

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        googleAdBanner()
        if CoreDataService.isGuestUser() == true {
            btnLogout.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func googleAdBanner() {
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMob.settingsAdUnitKey
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
    // MARK: - view positioning
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
    func openMailComposer(_ name: String, _ email: String, _message: String) {
        self.view.endEditing(true)
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Feedback")
            mailComposer.setToRecipients([txtEmailField.text!])
            mailComposer.setMessageBody(txtMessageField.text!, isHTML: false)
            self.present(mailComposer, animated: true, completion: nil)
        }
        else {
            Helper.showMessage(message: Messages.configureMail, success: false)
        }
    }
    
    //MARK:- Actions
    @IBAction func btnSubmitClicked(_ sender: Any) {
        var message = ""
        if txtNameField.text!.isEmpty {
            message = Messages.enterName
        }
        else if txtEmailField.text!.isValidEmail() == false {
            message = Messages.invalidEmail
        }
        else if txtMessageField.text!.isEmpty {
            message = Messages.enterMessage
        }
        if message.isEmpty == false {
            openMailComposer(txtNameField.text!, txtEmailField.text!, _message: txtMessageField.text!)
        } else {
            Helper.showMessage(message: message, success: false)
        }
    }
    @IBAction func btnLogoutClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: Messages.logoutConfirmation, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            CoreDataService.deleteLogin()
            Player.shared.player.stop()
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.currentShabad)
            UserDefaults.standard.synchronize()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnFBLikeClicked(_ sender: UIButton) {
        UIApplication.shared.open(URL.init(string: "https://www.facebook.com/Vismaad-Apps-1413125452234300/")!, options: [:]) { (success) in
        }
    }

}

//MARK:- Mail Composer
extension SettingsTabVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case .cancelled:
            break;
        case .saved:
            break;
        case .sent:
            break;
        case .failed:
            break;
        }
        controller.dismiss(animated: true) {
            if result == .sent {
                Helper.showMessage(message: Messages.mailSent, success: true)
            }
            
        }
    }
}
extension SettingsTabVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        lcTopScrollView.constant = 55
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
