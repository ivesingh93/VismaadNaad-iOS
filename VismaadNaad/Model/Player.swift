
//
//  Player.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 16/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import MediaPlayer
import FRadioPlayer

protocol PlayerDelegate {
    func playbackProgressDidChange(_ player: FRadioPlayer)
    func player(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState)
    func player(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState)
    func updateShabad(_ shabad: Shabad)

}
class Player: NSObject {
    
    static let shared = Player()
    
    var delegate: PlayerDelegate?
    
    // Singleton reference to player
    let player: FRadioPlayer = FRadioPlayer.shared
    var shabadList = [Shabad]()
    
    
    private override init() {
        print("Player initialized")
        super.init()
        player.delegate = self
        setupRemoteTransportControls()
    }
    var selectedIndex = 0 {
        didSet {
            defer {
                selectShabad(at: selectedIndex)
                updateNowPlaying(with: shabad)
            }
            
            guard 0..<shabadList.endIndex ~= selectedIndex else {
                selectedIndex = selectedIndex < 0 ? shabadList.count - 1 : 0
                return
            }
        }
    }
    
    var shabad: Shabad? {
        didSet {
            updateNowPlaying(with: shabad)
        }
    }
    
    //MARK: - Music Player methods
    func next() {
        UserDefaults.standard.set(0.0, forKey: UserDefaultsKey.currentShabadDuration)
        UserDefaults.standard.synchronize()
        selectedIndex += 1
    }
    
    func previous() {
        UserDefaults.standard.set(0.0, forKey: UserDefaultsKey.currentShabadDuration)
        UserDefaults.standard.synchronize()
        selectedIndex -= 1
    }
    
    func fastForward() {
        if let _ = player.playerItem?.duration {
            //player.seek(toSecond: Int(Double(slider.value) + 5))
        }
    }
    
    func fastRewind() {
        if let _ = player.playerItem?.duration {
          //  player.seek(toSecond: Int(Double(slider.value) - 5))
        }
    }

    func selectShabad(at position: Int) {
        let shabad = shabadList[position]
        player.radioURL = URL(string: shabad.shabad_url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
//        print(player.radioURL)
        saveCurrentPlayingShabad(shabad)
        saveShabadList(shabadList)
        UserDefaults.standard.set(position, forKey: UserDefaultsKey.currentIndexOfShabad)
        UserDefaults.standard.synchronize()
        delegate?.updateShabad(shabad)
    }
    
    func togglePlay() {
        player.togglePlaying()
    }
    
    private func saveCurrentPlayingShabad(_ shabad: Shabad){
        do {
            try UserDefaults.standard.set(PropertyListEncoder().encode(shabad), forKey: UserDefaultsKey.currentShabad)
        } catch {
            print("Error while saving currently playing shabad: \(error.localizedDescription)")
        }
        UserDefaults.standard.synchronize()
    }
    
    private func saveShabadList(_ shabadList: [Shabad]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(shabadList){
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKey.currentShabadList)
            UserDefaults.standard.synchronize()
        }
    }
    
  
    func currentShabadPlaying() -> Shabad? {
        do {
            if let storedObject: Data = UserDefaults.standard.object(forKey: UserDefaultsKey.currentShabad) as? Data {
                let storedShabad: Shabad = try PropertyListDecoder().decode(Shabad.self, from: storedObject)
                return storedShabad
            }
        } catch {
            print("Error while fetching currently playing shabad: \(error.localizedDescription)")
        }
        return nil
    }
    func currentShabadList() -> [Shabad]? {
        if let objects = UserDefaults.standard.value(forKey: UserDefaultsKey.currentShabadList) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [Shabad] {
                return objectsDecoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}

//MARK: - FRadioPlayer Delegates
extension Player: FRadioPlayerDelegate {
    func playbackProgressDidChange(_ player: FRadioPlayer) {
        if let duration = player.playerItem?.currentTime() {
//            print(duration.floatValue)
            UserDefaults.standard.set(duration.floatValue, forKey: UserDefaultsKey.currentShabadDuration)
            UserDefaults.standard.synchronize()
        }
        delegate?.playbackProgressDidChange(player)
    }
    
    //    Called when player changes state
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        if state == .loading {
            AppDelegate.shared().window?.makeToast(PlayingState.loading)
        } else if state == .loadingFinished {
            AppDelegate.shared().window?.makeToast(PlayingState.loadingFinished)
        }
        delegate?.player(player, playerStateDidChange: state)
    }
    //    Called when the playback changes state
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        if let shabad = self.currentShabadPlaying() {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationObserverKey.playerStateDidChange), object: state, userInfo: ["shabadName" : shabad.shabad_english_title, "raagiName": shabad.raagi_name])
        }
       delegate?.player(player, playbackStateDidChange: state)
    }
    
    //    Called when player changes the current player item
    func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
        
    }
    
    //    Called when player item changes the timed metadata value
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?)   {
        
    }
    //    Called when player item changes the timed metadata value
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?)   {
    }
    
    //    Called when the player gets the artwork for the playing song
    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?)   {
    }
}
// MARK: - Remote Controls / Lock screen
extension Player {
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.next()
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.previous()
            return .success
        }
    }
    
    func updateNowPlaying(with shabad: Shabad?) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        
        if let raagi = shabad?.raagi_name {
            nowPlayingInfo[MPMediaItemPropertyArtist] = raagi
        }
        nowPlayingInfo[MPMediaItemPropertyTitle] = shabad?.shabad_english_title ?? shabadList[selectedIndex].shabad_english_title
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
}
}
