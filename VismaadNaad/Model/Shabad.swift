
//
//  Shabad.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 26/04/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SwiftyJSON

class Shabad: NSObject, Codable {
    
    var ending_id: Int = 0
    var raagi_name: String = ""
    var sathaayi_id: Int = 0
    var shabad_english_title: String = ""
    var shabad_length: String = ""
    var shabad_url: String = ""
    var starting_id: Int = 0
    var recording_title: String = ""
    var id: Int = 0
    var listeners: Int = 0
    /*[6/12, 4:50 PM] Ivkaran Singh: https://s3.amazonaws.com/vismaadbani/vismaaddev/Raagis/<raagi_name>/<shabad_title>.mp3
     [6/12, 4:51 PM] Ivkaran Singh: Example: https://s3.amazonaws.com/vismaadbani/vismaaddev/Raagis/Bhai Dalbir Singh Jee/Gur Paaras Hum Loh.mp3
     */
    func setContent(_ contentJson: JSON) {
        ending_id = contentJson["ending_id"].intValue
        raagi_name = contentJson["raagi_name"].stringValue
        sathaayi_id = contentJson["sathaayi_id"].intValue
        shabad_english_title = contentJson["shabad_english_title"].stringValue
        shabad_length = contentJson["shabad_length"].stringValue
        starting_id = contentJson["starting_id"].intValue
        recording_title = contentJson["recording_title"].stringValue
        shabad_url = contentJson["shabad_url"].stringValue
        id = contentJson["id"].intValue
        listeners = contentJson["listeners"].intValue
       

    }
    
}
