

//
//  AddShabadCell.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 11/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

class AddShabadCell: UITableViewCell {
    
    @IBOutlet weak var lblShabadName: UILabel!
    @IBOutlet weak var lblShabadLength: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgSelected.isHidden = !selected
    }
    func setUpContent(_ shabad: Shabad) {
        lblShabadName.text = shabad.shabad_english_title
        lblShabadLength.text = shabad.shabad_length
    }
}
