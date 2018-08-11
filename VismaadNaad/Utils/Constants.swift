//
//  Constants.swift
//  Player
//
//  Created by B2BConnect on 21/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.


import Foundation
import UIKit

struct Config {
    static let appName = "VismaadNaad"
}
struct Segue {
    static let signUp = "segueSignUp"
    static let home = "segueHome"
    static let homeFromSignUp = "segueHomeSignUp"
    static let detail = "segueDetail"
    static let player = "seguePlayer"
    static let setting = "segueSetting"
    static let option = "segueOption"
    static let playerDirect = "seguePlayerDirect"
    static let addPlaylist = "segueAddPlaylist"
    static let addPlaylistFromLibrary = "segueAddPlaylistFromLibrary"
    static let addPlaylistFromDetail = "segueAddPlaylistFromDetail"
    static let addPlaylistFromPlayer = "segueAddPlaylistFromPlayer"
    static let createPlaylistFromAdd = "segueCreatePlaylistFromAdd"
    static let createPlaylistFromLibrary = "segueCreatePlaylistFromLibrary"
    static let playlist = "seguePlaylist"
    static let playerFromPlayist = "seguePlayerFromPlaylist"
    static let playerDirectFromLibrary = "seguePlayerDirectFromLibrary"
    static let playerFromPlaylistDetail = "seguePlayerFromPlaylistDetail"
}
struct Messages {
    static let noInternet = "No Internet Connection. Please check your internet connection and proceed."
    static let enterEmail = "Please enter email."
    static let invalidEmail = "Please enter valid email."
    static let passwordStrength = "Password should be minimum of 6 characters."
    static let enterFirstName = "Please enter first name."
    static let enterLastName = "Please enter last name."
    static let enterPhoneNumber = "Please enter phone number."
    static let enterUsername = "Please enter username."
    static let enterDOB = "Please enter D.O.B"
    static let enterGender = "Please enter gender."
    static let credentialsMismatch = "Credentials do not match."
    static let passwordMismatch = "Password do not match."
    static let notLoggedIn = "You are currently not logged in application. Please login to proceed."
    static let signUpSuccess = "Your account has been created successfully, Please login again."
    static let signUpFailure = "Unable to create account. Please try again later."
    static let shabadsAdded = "Shabads added to playlist."
    static let logoutConfirmation = "Are you sure you want to sign out from application?"
    static let playlistFailed = "Unable to create playlist at this time. Please try again later."
    static let enterPlaylistName = "Please enter playlist name."
    static let loginFailed = "Login failed. Please try again later."
    static let configureMail = "Please configure mail from settings."
    static let enterMessage = "Please enter message."
    static let enterName = "Please enter name."
    static let mailSent = "Mail Sent successfully."
}
struct TextFormatting {
    static let doubleLineBreak = "\n\n"
    static let singleLineBreak = "\n"
    static let gurbaniColor = UIColor.black
    static let punjabiColor = UIColor(red: 153/255, green: 102/255, blue: 51/255, alpha: 1.0)
    static let teekPadArthColor = UIColor(red: 74/255, green: 184/255, blue: 37/255, alpha: 1.0)
    static let teekaArthColor = UIColor(red: 36/255, green: 71/255, blue: 178/255, alpha: 1.0)
    static let englishColor = UIColor(red: 8/255, green: 87/255, blue: 94/255, alpha: 1.0)
}

struct ColorNames {
    static let white = "White"
    static let black = "Black"
    static let sepia = "Sepia"
    static let green = "Green"
}
struct Language {
    static let english = "English"
    static let teeka = "Teeka"
    static let punjabi = "Punjabi"
}

struct FontSize {
    static let maximum = 40.0
    static let minimum = 2.0
    static let normal = 27.0
}

struct PlayingState {
    static let loading = "Loading..."
    static let loadingFinished = "Loading finished..."
}

struct UserDefaultsKey {
    static let language = "language"
    static let color = "color"
    static let zoomLevel = "zoomLevel"
    static let currentShabad = "currentShabad"
    static let currentShabadDuration = "currentShabadDuration"
    static let currentShabadList = "currentShabadList"
    static let currentIndexOfShabad = "currentIndexOfShabad"
    static let visitsToPlayer = "visitsToPlayer"

}

struct NotificationObserverKey {
    static let playerStateDidChange = "PlayerStateDidChange"
}

struct LoginSource {
    static let email = "EMAIL"
    static let facebook = "Facebook"
    static let google = "gmail"
}


struct AdMob {
    static let key = "ca-app-pub-1910245378817352~9910729362"// ca-app-pub-6111320766286267~6005644574
    static let homeAdUnitKey = "ca-app-pub-1910245378817352/1753037740"
    static let detailAdUnitKey = "ca-app-pub-1910245378817352/8575782185"
    static let playerAdUnitKey = "ca-app-pub-1910245378817352/1627230456"
    static let settingsAdUnitKey = "ca-app-pub-1910245378817352/4246079960"
    static let libraryAdUnitKey = "ca-app-pub-1910245378817352/8213245130"
    static let playlistAdUnitKey = "ca-app-pub-1910245378817352/6113270376"
    //Test: ca-app-pub-3940256099942544/2934735716, Live: ca-app-pub-6111320766286267/4800374115
}
struct FacebookAd {
    static let key = "258729408192003_258730331525244"
    static let fullScreenAdKey = "372352669918123_418123532007703"
}

