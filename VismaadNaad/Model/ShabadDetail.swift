

//
//  ShabadDetail.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 01/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SwiftyJSON


class ShabadDetail: NSObject, Codable {
    var akIndex: String = ""
    var ang: Int = 0
    var author: String = ""
    var bani: String = ""
    var baniId: String = ""
    var english: String = ""
    var englishInitials: String = ""
    var gurmukhi: String = ""
    var gurmukhiInitials: String = ""
    var id: Int = 0
    var kirtan: String = ""
    var kirtanId: Int = 0
    var punjabi: String = ""
    var raag: String = ""
    var teekaArth: String = ""
    var teekaPadArth: String = ""
 
    func setContent(_ contentJson: JSON) {
        akIndex = contentJson["AK_Index"].stringValue
        ang = contentJson["Ang"].intValue
        author = contentJson["Author"].stringValue
        bani = contentJson["Bani"].stringValue
        baniId = contentJson["Bani_ID"].stringValue
        english = contentJson["English"].stringValue
        englishInitials = contentJson["English_Initials"].stringValue
        gurmukhi = contentJson["Gurmukhi"].stringValue
        gurmukhiInitials = contentJson["Gurmukhi_Initials"].stringValue
        id = contentJson["ID"].intValue
        kirtan = contentJson["Kirtan"].stringValue
        kirtanId = contentJson["Kirtan_ID"].intValue
        punjabi = contentJson["Punjabi"].stringValue
        raag = contentJson["Raag"].stringValue
        teekaArth = contentJson["Teeka_Arth"].stringValue
        teekaPadArth = contentJson["Teeka_Pad_Arth"].stringValue
  }
}
