//
//  SettingsVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 01/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import DropDown

protocol SettingDelegate {
    func didChangeZoomLevel(_ level: Double)
    func didChangeColor(_ color: UIColor)
    func didChangeLanguages(_ languages: [String])
}

class SettingsVC: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var delegate: SettingDelegate?
    
    var languagesSelected: [String]?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTap(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @objc func didRecognizeTap(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Gesture Delegate
extension SettingsVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UIControl.classForCoder()) == true {
            return false
        }
        return true
    }
}

 // MARK: - TableView Datasource, Delegates
extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath .row == 0 {
        let settingCellOne = tableView.dequeueReusableCell(withIdentifier: SettingCellOne.className, for: indexPath) as! SettingCellOne
            settingCellOne.selectionStyle = .none
            settingCellOne.delegate = self
             let level = UserDefaults.standard.double(forKey: UserDefaultsKey.zoomLevel)
            settingCellOne.stepper.value = level
            return settingCellOne
        } else if indexPath.row == 1{
            let settingCellTwo = tableView.dequeueReusableCell(withIdentifier: SettingCellTwo.className, for: indexPath) as! SettingCellTwo
            settingCellTwo.selectionStyle = .none
            settingCellTwo.delegate = self
            if let color = UserDefaults.standard.string(forKey: UserDefaultsKey.color) {
                settingCellTwo.colorOptionButton.setTitle(color, for: .normal)
                settingCellTwo.colorOptionButton.setTitle(color, for: .selected)
                settingCellTwo.colorOptionButton.isSelected = true
            }
            return settingCellTwo
        }
        let settingCellThree = tableView.dequeueReusableCell(withIdentifier: SettingCellThree.className, for: indexPath) as! SettingCellThree
        settingCellThree.selectionStyle = .none
        settingCellThree.delegate = self
        if let languages = languagesSelected {
            settingCellThree.setSelectedLanguage(languages)
        }
        return settingCellThree
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 130
        }
        return 70
    }
    
}

//MARK: - Settings Cells Delegates
extension SettingsVC: SettingCellOneDelegate, SettingCellTwoDelegate, SettingCellThreeDelegate {
    func didChangeZoom(_ level: Double) {
        UserDefaults.standard.set(level, forKey: UserDefaultsKey.zoomLevel)
        UserDefaults.standard.synchronize()
        delegate?.didChangeZoomLevel(level)
    }
    func didSelectedColor(_ color: UIColor) {
        var colorName = ""
        if color == .white {
            colorName = ColorNames.white
            
        } else if color == .black {
            colorName = ColorNames.black
        }
        else if color == Colors.sepia {
            colorName = ColorNames.sepia
        }
        else if color == Colors.green {
            colorName = ColorNames.green
        }
        UserDefaults.standard.set(colorName, forKey: UserDefaultsKey.color)
        UserDefaults.standard.synchronize()
        delegate?.didChangeColor(color)
    }
    
    func languagesSelected(_ languages: [String]) {
        UserDefaults.standard.set(languages, forKey: UserDefaultsKey.language)
        UserDefaults.standard.synchronize()
        delegate?.didChangeLanguages(languages)
    }
}

