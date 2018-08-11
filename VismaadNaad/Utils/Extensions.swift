//
//  Extensions.swift
//  SehajBani
//
//  Created by Jasmeet on 04/02/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import Foundation
import  UIKit
import SystemConfiguration
import AVFoundation
import SwiftMessages

private var __maxLengths = [UITextField: Int]()
extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)
        
        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}


extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
    func viewControllerFromIdentifier(Identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Identifier)
    }
}

extension String {
    func isValidEmail() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func roundedTwoDigit() -> Double {
        return self.rounded()
    }
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


struct FontHelper {
    static let gurbaniLipi = "GurbaniLipi"
    static let verdana = "Verdana"
    static func guruLippi(fontsize: CGFloat) ->UIFont{
        return UIFont(name: gurbaniLipi, size: fontsize)!
    }
    static func verdana(fontsize: CGFloat) ->UIFont{
        return UIFont(name: verdana, size: fontsize)!
    }
}


extension UIPanGestureRecognizer {
    func elasticTranslation(in view: UIView?, withLimit limit: CGSize, fromOriginalCenter center: CGPoint, applyingRatio ratio: CGFloat = 0.20) -> CGPoint {
        let translation = self.translation(in: view)
        
        guard let sourceView = self.view else {
            return translation
        }
        
        let updatedCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        let distanceFromCenter = CGSize(width: abs(updatedCenter.x - sourceView.bounds.midX),
                                        height: abs(updatedCenter.y - sourceView.bounds.midY))
        
        let inverseRatio = 1.0 - ratio
        let scale: (x: CGFloat, y: CGFloat) = (updatedCenter.x < sourceView.bounds.midX ? -1 : 1, updatedCenter.y < sourceView.bounds.midY ? -1 : 1)
        let x = updatedCenter.x - (distanceFromCenter.width > limit.width ? inverseRatio * (distanceFromCenter.width - limit.width) * scale.x : 0)
        let y = updatedCenter.y - (distanceFromCenter.height > limit.height ? inverseRatio * (distanceFromCenter.height - limit.height) * scale.y : 0)
        
        return CGPoint(x: x, y: y)
    }
}


// MARK: - Image Scaling.
extension UIImage {
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    /// Switch MIN to MAX for aspect fill instead of fit.
    ///
    /// - parameter newSize: newSize the size of the bounds the image must fit within.
    ///
    /// - returns: a new scaled image.
    func scaleImageToSize(newSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = newSize.width/size.width
        let aspectheight = newSize.height/size.height
        
        let aspectRatio = max(aspectWidth, aspectheight)
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = 0
        //        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0;
        
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func crop(to: CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
            
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
            
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
                
            } else { //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }

}

extension UIImageView {
    
    func downloadedFrom(url: URL?,_ completionListener: (() -> Void)? = nil) {
        
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() {
                self.image = image
                completionListener?()
            }
            }.resume()
    }
    
    func downloadedFrom(link: String?, completionListener: (() -> Void)? = nil) {
        
        guard let link = link else {
            return
        }
        
        guard let url = URL(string: link) else { return }
        
        downloadedFrom(url: url, completionListener)
    }
    
    func roundTheImage() {
        let totalWidth = self.frame.width
        self.layer.cornerRadius = totalWidth / 2;
        self.layer.masksToBounds = true;
    }
    
    func setImageWithUrl(_ str: String?, placeholderImage: UIImage?) {
        if let url = str {
            setImageWithUrl(url: URL(string: url), placeholderImage: placeholderImage)
        }
    }
    
    func setImageWithUrl(url: URL?, placeholderImage: UIImage?, onCompletion: (() -> Void)? = nil) {
        if let url = url {
            self.sd_setImage(with: url, placeholderImage: placeholderImage, completed: { (image, error, cache, strUrl) in
                if let image = image {
                    self.image = image.crop(to: CGSize(width: self.layer.frame.width, height: self.layer.frame.height))
                    self.contentMode = .scaleAspectFill
                }
                self.layoutIfNeeded()
                if onCompletion != nil {
                    onCompletion!()
                }
            })
        }
    }
}

extension UIButton {
    
    func setImageWithUrl(_ str: String?, placeholderImage: UIImage?) {
        if let url = str {
            setImageWithUrl(url: URL(string: url), placeholderImage: placeholderImage)
        }
    }
    
    func setImageWithUrl(url: URL?, placeholderImage: UIImage?, onCompletion: (() -> Void)? = nil) {
        if let url = url, let imageView = self.imageView {
            imageView.sd_setImage(with: url, placeholderImage: placeholderImage, completed: { (image, error, cache, strUrl) in
                if let image = image {
                    imageView.image = image.crop(to: CGSize(width: self.layer.frame.width, height: self.layer.frame.height))
                    imageView.contentMode = .scaleAspectFill
                }
                self.layoutIfNeeded()
                if onCompletion != nil {
                    onCompletion!()
                }
            })
        }
    }
}

extension UILabel {
    
    func roundTheBackground() {
        let totalWidth = self.frame.width
        self.layer.cornerRadius = totalWidth / 2
        self.layer.masksToBounds = true
    }
    
    ///Find the index of character (in the attributedText) at point
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

extension UITableViewCell {
    
    func openUrl(_ url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func getFirstWord(of string: String) -> String {
        return String(string.split(separator: " ").first ?? "")
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    

    
    private func setFont(font: UIFont, views: [Any], fontSize: CGFloat, textColor: UIColor? = nil) {
        views.forEach { (view) in
            if let label = view as? UILabel{
                label.font = font
                if let color = textColor {
                    label.textColor = color
                }
            } else if let button = view as? UIButton {
                button.titleLabel?.font = font
                if let color = textColor {
                    button.titleLabel?.textColor = color
                }
            } else if let textField = view as? UITextField {
                textField.font = font
                if let color = textColor {
                    textField.textColor = color
                }
            } else if let textView = view as? UITextView {
                textView.font = font
                if let color = textColor {
                    textView.textColor = color
                }
            }
        }
    }
}

extension UIViewController {
    
    func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func roundTheBackgroundCorners(_ views: [UIView], cornerRadius: CGFloat = 4, borderColor: UIColor = .lightGray, borderWidth: CGFloat = 1.0) {
        views.forEach { (view) in
            view.roundTheBackgroundCorners(cornerRadius: cornerRadius, borderColor: borderColor, borderWidth: borderWidth)
        }
    }
    
    func share(data: String) {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIViewController.topViewController?.present(activity, animated: true, completion: nil)
    }
    
    class var topViewController: UIViewController? {
        return getTopViewController()
    }
    
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    func openUrl(_ url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
   
    
    func getDisplayTimeOrDate(_ date: Date) -> String {
        
        let cal = Calendar.current
        let dateFormatter = DateFormatter()
        let firstDayOfWeek = Date.init(timeIntervalSinceNow: 0).startOfWeek
        
        if cal.isDateInToday(date) {
            dateFormatter.dateFormat = "hh:mm a"
            
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
            
        } else if let day = firstDayOfWeek, date >= day {
            dateFormatter.dateFormat = "EEEE"
            
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        return dateFormatter.string(from: date)
    }
    
  
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func getFirstWord(of string: String) -> String {
        return String(string.split(separator: " ").first ?? "")
    }
    
    func closeController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showController(_ cont: UIViewController) {
        self.navigationController?.pushViewController(cont, animated: true)
    }
    
    func showWithTabBarController(_ cont: UIViewController) {
        self.tabBarController?.navigationController?.pushViewController(cont, animated: true)
    }
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byCharWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func showAlert(_ msg: String, _ okAction: ((UIAlertAction) -> Void)?  = nil) {
        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okAction))
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(_ title: String, _ message: String, yes: @escaping () -> Void, no: (() -> Void)? = nil) {
        showConfirmationAlert(title, message, yesTitle: "YES", noTitle: "NO", yes: yes, no: no)
    }
    
    func showConfirmationAlert(_ title: String, _ message: String, yesTitle: String, noTitle: String, yes: @escaping () -> Void, no: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: yesTitle, style: .default, handler: { (action: UIAlertAction!) in
            yes()
        }))
        
        alert.addAction(UIAlertAction(title: noTitle, style: .cancel, handler: { (action: UIAlertAction!) in
            if let no = no {
                no()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSomethingWentWrong() {
        showAlert("Something went wrong !!")
    }
    
    private func setFont(font: UIFont, views: [Any], fontSize: CGFloat, textColor: UIColor? = nil) {
        views.forEach { (view) in
            if let label = view as? UILabel{
                label.font = font
                if let color = textColor {
                    label.textColor = color
                }
            } else if let button = view as? UIButton {
                button.titleLabel?.font = font
                if let color = textColor {
                    button.titleLabel?.textColor = color
                    button.tintColor = color
                }
            } else if let textField = view as? UITextField {
                textField.font = font
                if let color = textColor {
                    textField.textColor = color
                }
            } else if let textView = view as? UITextView {
                textView.font = font
                if let color = textColor {
                    textView.textColor = color
                }
            } else if let searchBar = view as? UISearchBar {
                searchBar.subviews
                    .flatMap { $0.subviews }
                    .filter { $0 is UITextField }
                    .map { $0 as! UITextField }
                    .forEach {
                        $0.font = font
                        if let color = textColor {
                            $0.textColor = color
                        }
                }
            }
        }
    }
}

extension UIView {
    
    func roundTheView() {
        self.layer.cornerRadius = self.layer.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    func roundTheBackgroundCorners(cornerRadius: CGFloat = 4, borderColor: UIColor = .lightGray, borderWidth: CGFloat = 1.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth;
    }
    
}

extension Int {
    
    func toString() -> String {
        return String(self)
    }
    
    static func tenthPowerOf(_ num: Int) -> Int {
        var power = 1
        for _ in 1...num {
            power *= 10
        }
        return power
    }
    
    func toFloat() -> Float {
        return Float(self)
    }
    
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

extension Int64 {
    
    func toString() -> String {
        return String(self)
    }
}

extension Float {
    
    func toString() -> String {
        return String(self)
    }
    
    mutating func limitTo(decimalPlaces limit:Int) -> Float {
        let tenthPower:Float = Float(Int.tenthPowerOf(limit))
        return Float(Darwin.round(tenthPower * self) / tenthPower)
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}


extension UIViewController {
    
    var ProfileStoryBoard: UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    var LoginStoryBoard: UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    var MessagingStoryBoard: UIStoryboard {
        return UIStoryboard(name: "Messaging", bundle: nil)
    }
}



extension Date {
    
    static var now: Date {
        return Date.init(timeIntervalSinceNow: 0)
    }
    
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    func yearsTo(_ date : Date) -> Int{
        return Calendar.current.dateComponents([.year], from: self, to: date).year ?? 0
    }
    
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isTodayDate() -> Bool {
        return isSameDay(as: Date.now)
    }
    
    func isYesterdayDate() -> Bool {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let str = df.string(from: .now)
        let newDate = df.date(from: str)!
        return isSameDay(as: newDate)
    }
}

extension UITextView{
    
    func numberOfLines() -> CGFloat {
        if let fontUnwrapped = self.font {
            return self.contentSize.height / fontUnwrapped.lineHeight
        }
        return 0
    }
    
    func lineHeight() -> CGFloat {
        if let fontUnwrapped = self.font {
            return fontUnwrapped.lineHeight
        }
        return 0
    }
    
    func calculatedHeight() -> CGFloat {
        return self.lineHeight() * self.numberOfLines()
    }
}

extension UIScrollView {
    
    func scrollToBottom(_ animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        print_debug(labelSize)
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        print_debug(locationOfTouchInLabel)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch label.textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        }
        let xOffset = ((label.bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((label.bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
        
        //        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        //        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
        //                                                         locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print_debug(locationOfTouchInTextContainer)
        print_debug(indexOfCharacter)
        print_debug(targetRange)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}

extension UITabBarController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate: Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}
extension CMTime {
    var isValid : Bool { return (flags.intersection(.valid)) != [] }
    var floatValue: Float {
         let totalSeconds = CMTimeGetSeconds(self)
        return Float(totalSeconds)
    }
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
extension UICollectionView {
    func reloadItems(inSection section:Int) {
        reloadItems(at: (0..<numberOfItems(inSection: section)).map {
            IndexPath(item: $0, section: section)
        })
    }
}
