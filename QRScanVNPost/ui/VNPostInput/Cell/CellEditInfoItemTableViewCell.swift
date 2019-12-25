//
//  CellEditInfoItemTableViewCell.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/22.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CellEditInfoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitleEdit: UILabel!
    @IBOutlet weak var tfEdit : UITextField!
    var onSetTextEditNumber:((String)->())?


    override func awakeFromNib() {
        super.awakeFromNib()
        self.tfEdit.delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension CellEditInfoItemTableViewCell:UITextFieldDelegate{

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("--111--- textField ---- \(String(describing: textField.text))")
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("-4444---- textField ---- \(String(describing: textField.text))")
    }




    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

//        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
//            return false
//        }
        if let textFieldString = textField.text, let swtRange = Range(range, in: textFieldString) {
            let fullString = textFieldString.replacingCharacters(in: swtRange, with: string)

            print("FullString: \(fullString)")
            onSetTextEditNumber?(fullString)
        }
//         onSetTextEditNumber?(string)
        return true
    }

}
