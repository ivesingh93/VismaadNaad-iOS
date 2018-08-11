//
//  Album.swift
//  Player
//
//  Created by B2BConnect on 21/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SwiftyJSON

class Album: NSObject, Codable {
    
    var raagi_id: Int = 0
    var raagi_name: String = ""
    var shabads_count: Int = 0
    var raagi_image_url: String = ""
    var minutes_of_shabads: Int = 0
    
    func setContent(_ contentJson: JSON) {
        raagi_id = contentJson["raagi_id"].intValue
        raagi_name = contentJson["raagi_name"].stringValue
        shabads_count = contentJson["shabads_count"].intValue
        raagi_image_url = contentJson["raagi_image_url"].stringValue
        minutes_of_shabads = contentJson["minutes_of_shabads"].intValue
    }
}
