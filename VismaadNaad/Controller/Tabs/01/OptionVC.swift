//
//  OptionVC.swift
//  SehajBani
//
//  Created by B2BConnect on 08/05/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
import SDWebImage

class OptionVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var raagiImageView: UIImageView!
    @IBOutlet weak var raagiNameLabel: UILabel!

    var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

     func addLinearGradientToView(view: UIView, colour: UIColor, transparntToOpaque: Bool, vertical: Bool) {
        let gradient = CAGradientLayer()
        
        let gradientFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        gradient.frame = gradientFrame
        
        var colours = [
            colour.cgColor,
            colour.withAlphaComponent(1.0).cgColor,
            colour.withAlphaComponent(1.0).cgColor,
            colour.withAlphaComponent(1.0).cgColor,
            colour.withAlphaComponent(1.0).cgColor,
            colour.withAlphaComponent(0.9).cgColor,
            colour.withAlphaComponent(0.6).cgColor,
            colour.withAlphaComponent(0.3).cgColor,
            colour.withAlphaComponent(0.2).cgColor,
            colour.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        
        if transparntToOpaque == true {
            colours = colours.reversed()
        }
        
        if vertical == true {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x:1, y:0.5)
        }
        gradient.colors = colours
        view.layer.insertSublayer(gradient, at: 0)
    }
    func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTap(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        addLinearGradientToView(view: view, colour: Colors.tabColor, transparntToOpaque: true, vertical: false)
        
        // Load options data
        if let album = album {
            raagiNameLabel.text = album.raagi_name
            raagiImageView.sd_setShowActivityIndicatorView(true)
            raagiImageView.sd_setIndicatorStyle(.white)
            let urlString = album.raagi_image_url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            raagiImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    @objc func didRecognizeTap(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Gesture Delegate

extension OptionVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isKind(of: UIControl.classForCoder()) == true {
            return false
        }
        return true
    }
}

// MARK: - TableView Datasource, Delegates
extension OptionVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionCell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) 
        optionCell.selectionStyle = .none
        optionCell.textLabel?.text = "Option \(indexPath.row + 1)"
        optionCell.textLabel?.textAlignment = .center
        optionCell.textLabel?.textColor = .white
        return optionCell
    }
}
