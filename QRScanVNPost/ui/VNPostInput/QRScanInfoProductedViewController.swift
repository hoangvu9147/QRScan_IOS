//
//  QRScanInfoProductedViewController.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/20.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import MBProgressHUD


class QRScanInfoProductedViewController: UIViewController {

    @IBOutlet weak var tbListInfo: UITableView!

    var arrTopicProducted  = ["order_code :", "from_name :","to_name :","from_address :","to_address :","from_tel :","to_tel :","Id người nhận :","số nhà :" ]
    var arrDetailItemProducted  =  [""]

//    var detailItemData = DetailInfoItemData()
    var idBarcode = 0

    //    var presenterQuantity:DetailInfoRequest!


    override func viewDidLoad() {
        super.viewDidLoad()
        print("idBarcode  --- \(idBarcode)");
        
        self.navigationController?.isNavigationBarHidden = true
        self.tbListInfo.register(UINib(nibName: "CellDetailInfoProductTableViewCell", bundle: nil), forCellReuseIdentifier: "CellDetailInfoProductTableViewCell")
        self.tbListInfo.dataSource = self
        self.tbListInfo.delegate = self
        tbListInfo.estimatedRowHeight = 80.0
        tbListInfo.rowHeight = UITableViewAutomaticDimension
        self.tbListInfo.separatorStyle = .none
        let paddingBottom: CGFloat = 0
        tbListInfo.contentInset = UIEdgeInsetsMake(0, 0, paddingBottom, 0)

        let  detailItemData = DetailInfoItemData.getDetailById(id: idBarcode)!
        //        setDataDetailItemInfo(itemInfo: detailItemData)
        arrDetailItemProducted.removeAll()
        arrDetailItemProducted = [
            detailItemData.order_code,
            detailItemData.from_name,
            detailItemData.to_name,
            detailItemData.from_address,
            detailItemData.to_address,
            detailItemData.from_tel,
            detailItemData.to_tel,
            detailItemData.user_id.description,
            detailItemData.warehouse_id.description
        ]
        tbListInfo.reloadData()

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let  detailItemData = DetailInfoItemData.getDetailById(id: idBarcode)!
        arrDetailItemProducted.removeAll()
        //        setDataDetailItemInfo(itemInfo: detailItemData)
        arrDetailItemProducted = [
            detailItemData.order_code,
            detailItemData.from_name,
            detailItemData.to_name,
            detailItemData.from_address,
            detailItemData.to_address,
            detailItemData.from_tel,
            detailItemData.to_tel,
            detailItemData.user_id.description,
            detailItemData.warehouse_id.description
        ]
        tbListInfo.reloadData()
    }


    @IBAction func onBack(_ sender : Any){

        let viewControllers = self.navigationController!.viewControllers as! [UIViewController];
        for aViewController:UIViewController in viewControllers {
            if aViewController.isKind(of: QRScanViewController.self) {
                if let vc =   aViewController as? QRScanViewController{
                    vc.isStartCamera = true
                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)

    }


    //MARK: Call Api
    func postStatusInfoItem(order_id: String,status: String) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let api : DetailInfoRequest = DetailInfoRequest(requestName:  String(format: QRRequestName.POST_ITEM_INFO_DETAIL.rawValue), responseType: QRResponseType.json)
        api.postStatusInfoItem(order_id: order_id, status: status).execute(mfResponse: {
            (api,response,error) in
            if response?.result_code != 10 {
                DetailInfoItemData.deleteBy(id: self.idBarcode)

                print("---- result dataResponse -- \(String(describing: response?.dataResponse))")
                _ = response?.toResponse(clazz: QRDetailInfoPostRespone.self)
                MBProgressHUD.hide(for: self.view, animated: true)
                let viewControllers = self.navigationController!.viewControllers as! [UIViewController];
                for aViewController:UIViewController in viewControllers {
                    if aViewController.isKind(of: QRScanViewController.self) {
                        if let vc =   aViewController as? QRScanViewController{
                            vc.isStartCamera = true
                            _ = self.navigationController?.popToViewController(aViewController, animated: true)
                        }
                    }
                }
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        })
    }



    //MARK : Action
    @IBAction func onApprove(_ sender : Any){
        postStatusInfoItem(order_id: idBarcode.description, status: "1")
    }

    @IBAction func onEdit(_ sender : Any){
        let newViewController = QREditInfoItemViewController()
        newViewController.idBarcode = idBarcode
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    @IBAction func onReject(_ sender : Any){
        postStatusInfoItem(order_id: idBarcode.description, status: "3")
    }


    
}

extension QRScanInfoProductedViewController: UITableViewDelegate {
    
}

extension QRScanInfoProductedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  42
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTopicProducted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbListInfo.dequeueReusableCell(withIdentifier: "CellDetailInfoProductTableViewCell") as! CellDetailInfoProductTableViewCell
        cell.selectionStyle = .none
        cell.lbTopic.text = arrTopicProducted[indexPath.row]
        cell.lbDetailInfo.text = arrDetailItemProducted[indexPath.row]

        return cell
    }
    
}
