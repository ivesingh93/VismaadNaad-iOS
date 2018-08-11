//
//  Helper.swift
//  SehajBani
//
//  Created by Jasmeet on 04/02/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MobileCoreServices
import AVFoundation
import AVKit
import SwiftMessages

class Helper: NSObject {
    
    class func showAlertDilog(with message:String, _ title: String,_ inViewController:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        inViewController.present(alert, animated: true, completion: nil)
    }
    
    class func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailStr)
    }
    
    class func changeColor(_ colorName: String) -> UIColor {
        if colorName == ColorNames.white {
            return .white
            
        } else if colorName == ColorNames.black {
            return .black
        }
        else if colorName == ColorNames.sepia {
            return Colors.sepia
        }
        else if colorName == ColorNames.green {
            return Colors.green
        }
        return .white
    }
    
    class func getTravelDate(_ myDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: myDate)!
        dateFormatter.dateFormat = "MMM dd, hh:mm a"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    class func getCommentDate(_ myDate: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = dateFormatter.string(from: myDate)
        return dateString
    }
    
    class func getTravelTimeInHoursMinutes(_ myDate: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: myDate)!
        dateFormatter.dateFormat = "HH:mm a"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    class func getTravelTimeInDayAndMonth(_ myDate: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: myDate)!
        dateFormatter.dateFormat = "MMM dd"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    class func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    class func currentDate() -> String? {
        let todaysDate = Date()
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "MMddyyyyHHmmss.SSS"
        if #available(iOS 11, *) {
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        return dateFormatter.string(from: todaysDate)
    }
    class func postDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        //Sat, 10 Feb 2018, 2:58 PM
        dateFormatter.dateFormat = "eee, dd MM yyyy, hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    class func distanceBetweenTwoLocations(_ source:CLLocation,_ destination:CLLocation) -> Double{
        let distanceMeters = source.distance(from: destination)
        let distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.roundedTwoDigit()
        return roundedTwoDigit
    }
    
    
    class func generateThumnail(filePath : NSURL) -> UIImage?{
        do {
            let asset = AVURLAsset(url: filePath as URL , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let scaledSize = CGSize(width: 600 * UIScreen.main.scale, height: 600 *  UIScreen.main.scale)
            imgGenerator.maximumSize = scaledSize
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(1, 2), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
            // thumbnail here
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    class func showMessage(message: String, success: Bool) {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme( success ? .success : .warning)
        messageView.configureDropShadow()
        messageView.configureContent(title: Config.appName, body: message)
        messageView.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .bottom
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelAlert)
        SwiftMessages.show(config: successConfig, view: messageView)
    }
    class func getDOB(_ date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    
}


func print_debug<T>(_ obj:T) {
    print(obj)
}

public enum DisplayType {
    case unknown
    case iphone4
    case iphone5
    case iphone6
    case iphone6plus
    static let iphone7 = iphone6
    static let iphone7plus = iphone6plus
    case iphoneX
}

public final class Display {
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength:CGFloat { return max(width, height) }
    class var minLength:CGFloat { return min(width, height) }
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    class var carplay:Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
    class var tv:Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    class var typeIsLike:DisplayType {
        if phone && maxLength < 568 {
            return .iphone4
        }
        else if phone && maxLength == 568 {
            return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6
        }
        else if phone && maxLength == 736 {
            return .iphone6plus
        }
        else if phone && maxLength == 812 {
            return .iphoneX
        }
        return .unknown
    }
}

protocol CustomTextFieldDelegate {
    func didClearText()
}

class CustomTextField : UITextField
{
    var customDelegate: CustomTextFieldDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        clearButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        
        self.rightView = clearButton
        clearButton.addTarget(self, action: #selector(clearClicked(_:)), for: .touchUpInside)
        
        self.clearButtonMode = UITextFieldViewMode.never
        self.rightViewMode = UITextFieldViewMode.always
    }
    
    @objc func clearClicked(_ sender:UIButton) {
        self.text = ""
        customDelegate?.didClearText()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

