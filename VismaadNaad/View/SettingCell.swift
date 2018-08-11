//
//  SettingCell.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 11/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown
class SettingCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


protocol SettingCellOneDelegate {
    func didChangeZoom(_ level: Double)
}

class SettingCellOne: SettingCell {
    
    @IBOutlet weak var stepper: UIStepper!
    
    var delegate: SettingCellOneDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func stepperDidClicked(_ sender: UIStepper) {
        delegate?.didChangeZoom(sender.value)
    }
    
}

protocol SettingCellTwoDelegate {
    func didSelectedColor(_ color: UIColor)
}

class SettingCellTwo: SettingCell {
    
    @IBOutlet weak var colorOptionButton: UIButton!
    
    var dropDown = DropDown()
    
    var delegate: SettingCellTwoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func btnOptionDidClicked(_ sender: Any) {
        dropDown.dataSource = [ColorNames.white, ColorNames.black, ColorNames.sepia, ColorNames.green]
        dropDown.anchorView = colorOptionButton
        dropDown.width = colorOptionButton.frame.size.width
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.colorOptionButton.setTitle(item, for: .normal)
            self.colorOptionButton.setTitle(item, for: .selected)
            if index == 0 {
                self.delegate?.didSelectedColor(.white)
            }
            else if index == 1 {
                self.delegate?.didSelectedColor(.black)
            }
            else if index == 2 {
                self.delegate?.didSelectedColor(Colors.sepia)
            }
            else if index == 3 {
                self.delegate?.didSelectedColor(Colors.green)
            }
            self.dropDown.hide()
        }
        dropDown.dismissMode = .automatic
        dropDown.show()
    }
}

protocol SettingCellThreeDelegate {
    func languagesSelected(_ languages:[String])
}
class SettingCellThree: SettingCell {
    
    @IBOutlet weak var teekaButton: UIButton!
    @IBOutlet weak var punjabiButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    var delegate: SettingCellThreeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnTeekaClicked(_ sender: UIButton) {
        teekaButton.isSelected = !teekaButton.isSelected
        delegate?.languagesSelected(languageSelection())
    }
    @IBAction func btnPunjabiClicked(_ sender: UIButton) {
        punjabiButton.isSelected = !punjabiButton.isSelected
        delegate?.languagesSelected(languageSelection())
    }
    @IBAction func btnEnglishClicked(_ sender: UIButton) {
        englishButton.isSelected = !englishButton.isSelected
        delegate?.languagesSelected(languageSelection())
    }
    
    func languageSelection() -> [String] {
        var languages = [String]()
        for view in stackView.subviews {
            if view.isKind(of: UIButton.classForCoder()) {
                if let btn = view as? UIButton {
                    if btn.isSelected == true {
                        languages.append(btn.title(for: .normal)!)
                    }
                }
            }
        }
        return languages
    }
    func setSelectedLanguage(_ languages:[String]) {
        for view in stackView.subviews {
            if view.isKind(of: UIButton.classForCoder()) {
                if let btn = view as? UIButton {
                    if (languages.contains(btn.title(for: .normal)!)) {
                        btn.isSelected = true
                    } else {
                        btn.isSelected = false
                    }
                }
            }
        }
    }
}
