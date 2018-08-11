

//
//  Playlist.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 06/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SwiftyJSON

class Playlist: NSObject, Codable {
    
    var shabads_count: String = ""
    var playlist_name: String = ""
    
    func setContent(_ contentJson: JSON) {
        shabads_count = contentJson["shabads_count"].stringValue
        playlist_name = contentJson["name"].stringValue
    }
    
}
