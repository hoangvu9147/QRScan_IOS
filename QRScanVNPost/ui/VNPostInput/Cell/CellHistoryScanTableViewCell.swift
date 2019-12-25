//
//  CellHistoryScanTableViewCell.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/20.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit

class CellHistoryScanTableViewCell: UITableViewCell {

    @IBOutlet weak var lbFrom: UILabel!
    @IBOutlet weak var lbTo: UILabel!
    @IBOutlet weak var lbPhone: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
