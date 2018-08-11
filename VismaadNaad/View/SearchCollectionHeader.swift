//
//  SearchCollectionHeader.swift
//  VismaadNaad
//
//  Created by Jasmeet Singh on 12/07/18.
//  Copyright © 2018 Jasmeet. All rights reserved.
//

import UIKit

protocol SearchCollectionHeaderDelegate {
    func searchFieldTextChange(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    func searchFieldDidReturn(_ textField: UITextField)
    func reload()
}
class SearchCollectionHeader: UICollectionReusableView {
        
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var lcSearchButtonLeading: NSLayoutConstraint!
    var delegate: SearchCollectionHeaderDelegate?
    
    override func prepareForReuse() {
        searchField.delegate = self
        lcSearchButtonLeading.constant = UIScreen.main.bounds.size.width / 2 - 90

    }
    @IBAction func btnSearchClicked(_ sender: Any) {
        lcSearchButtonLeading.constant = 10
        searchField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
            self.closeButton.isHidden = false
        }
    }
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.lcSearchButtonLeading.constant = UIScreen.main.bounds.size.width / 2 - 80
        self.endEditing(true)
        delegate?.reload()
        searchField.text = nil
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
            self.closeButton.isHidden = true
        }
    }
}

extension SearchCollectionHeader: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.btnSearchClicked(searchButton)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchFieldDidReturn(textField)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.searchFieldTextChange(textField, shouldChangeCharactersIn: range, replacementString: string)
        return true
    }
}
