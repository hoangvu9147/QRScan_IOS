//
//  CellDetailInfoProductTableViewCell.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/20.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit

class CellDetailInfoProductTableViewCell: UITableViewCell {

      @IBOutlet weak var lbTopic: UILabel!
      @IBOutlet weak var lbDetailInfo: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
