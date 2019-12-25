//
//  QRScanHistoryViewController.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/20.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit

class QRScanHistoryViewController: UIViewController {

    @IBOutlet weak var tbListHistory: UITableView!


   var detailItemDatas = [DetailInfoItemData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tbListHistory.register(UINib(nibName: "CellHistoryScanTableViewCell", bundle: nil), forCellReuseIdentifier: "CellHistoryScanTableViewCell")
        self.tbListHistory.dataSource = self
        self.tbListHistory.delegate = self
        tbListHistory.estimatedRowHeight = 80.0
        tbListHistory.rowHeight = UITableViewAutomaticDimension
        self.tbListHistory.separatorStyle = .none
        let paddingBottom: CGFloat = 0
        tbListHistory.contentInset = UIEdgeInsetsMake(0, 0, paddingBottom, 0)
        detailItemDatas = DetailInfoItemData.getAll()
        tbListHistory.reloadData()
    }


    @IBAction func onBack(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension QRScanHistoryViewController: UITableViewDelegate {

}

extension QRScanHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return  100.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailItemDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbListHistory.dequeueReusableCell(withIdentifier: "CellHistoryScanTableViewCell") as! CellHistoryScanTableViewCell
        cell.selectionStyle = .none
        
        cell.lbFrom.text = "Tên người nhận : " + detailItemDatas[indexPath.row].from_name
        cell.lbPhone.text = "Số điện thoại :" + detailItemDatas[indexPath.row].from_tel
        cell.lbTo.text = "Người nhận : " + detailItemDatas[indexPath.row].to_name

        return cell
    }


}

