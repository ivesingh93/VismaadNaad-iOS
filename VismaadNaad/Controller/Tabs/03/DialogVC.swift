//
//  DialogVC.swift
//  SehajBani
//
//  Created by Jasmeet Singh on 08/06/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit
protocol DialogDelegate {
    func didClickedOk()
    func didClickedCancel()
}
class DialogVC: UIViewController {
    
    var delegate: DialogDelegate?
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    var buttonOkTitle: String = ""
    var buttonCancelTitle: String = ""
    var message: String = ""

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnOk.setTitle(buttonOkTitle, for: .normal)
        btnCancel.setTitle(buttonCancelTitle, for: .normal)
        lblMessage.text = message

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func set(message: String, delegate: DialogDelegate?, cancelButtonTitle: String, okButtonTitle: String  ) {
        self.buttonOkTitle = okButtonTitle
        self.buttonCancelTitle = cancelButtonTitle
        self.message = message
    }
    
    // MARK: - Actions
    @IBAction func btnOkClicked(_ sender: UIButton?) {
            self.delegate?.didClickedOk()
    }
    @IBAction func btnCancelClicked(_ sender: UIButton?) {
            self.delegate?.didClickedCancel()
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
