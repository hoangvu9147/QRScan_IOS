//
//  QREditInfoItemViewController.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/22.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift


class QREditInfoItemViewController: UIViewController {

    @IBOutlet weak var tbListEdit: UITableView!
    var arrTopicProducted  = ["from_name :", "to_name :","from_address :","to_address :","from_tel :","to_tel :"]
    var arrEdit  = ["", ""," "," "," "," " ]
    var idBarcode = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        hideKeyboardWhenTappedAround()

        self.navigationController?.isNavigationBarHidden = true
        self.tbListEdit.register(UINib(nibName: "CellEditInfoItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CellEditInfoItemTableViewCell")
        self.tbListEdit.dataSource = self
        self.tbListEdit.delegate = self
        tbListEdit.estimatedRowHeight = 80.0
        tbListEdit.rowHeight = UITableViewAutomaticDimension
        self.tbListEdit.separatorStyle = .none
        let paddingBottom: CGFloat = 0
        tbListEdit.contentInset = UIEdgeInsetsMake(0, 0, paddingBottom, 0)

        let  detailItemData = DetailInfoItemData.getDetailById(id: idBarcode)!
        arrEdit.removeAll()
        //        setDataDetailItemInfo(itemInfo: detailItemData)
        arrEdit = [
            detailItemData.from_name,
            detailItemData.to_name,
            detailItemData.from_address,
            detailItemData.to_address,
            detailItemData.from_tel,
            detailItemData.to_tel
        ]

        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onBack(_ sender : Any){
//        let viewControllers = self.navigationController!.viewControllers as! [UIViewController];
//        for aViewController:UIViewController in viewControllers {
//            if aViewController.isKind(of: QRScanInfoProductedViewController.self) {
//                if let vc =   aViewController as? QRScanInfoProductedViewController{
//
//                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
//                }
//            }
//        }

        self.navigationController?.popViewController(animated: true)
    }


    //MARK: Call Api
    func postEditItem(from_name: String,to_name: String,from_address: String,to_address: String,from_tel: String,to_tel: String) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let api : DetailInfoRequest = DetailInfoRequest(requestName:  String(format: QRRequestName.POST_EDIT.rawValue, idBarcode.description), responseType: QRResponseType.json)
        api.postEdittem(from_name: from_name,to_name: to_name,from_address: from_address,to_address: to_address,from_tel: from_tel,to_tel: to_tel,product_type: 0).execute(mfResponse: {
            (api,response,error) in
            if response?.result_code != 10 {
                DetailInfoItemData.deleteBy(id: self.idBarcode)

                print("---- result dataResponse -- \(String(describing: response?.dataResponse))")
                _ = response?.toResponse(clazz: QRDetailInfoPostRespone.self)
                MBProgressHUD.hide(for: self.view, animated: true)
                 self.navigationController?.popViewController(animated: true)

//                let viewControllers = self.navigationController!.viewControllers as! [UIViewController];
//                for aViewController:UIViewController in viewControllers {
//                    if aViewController.isKind(of: QRScanViewController.self) {
//                        if let vc =   aViewController as? QRScanViewController{
//                            vc.isStartCamera = true
//                            _ = self.navigationController?.popToViewController(aViewController, animated: true)
//                        }
//                    }
//                }
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        })
    }

    @IBAction func onEdit(_ sender : Any){
        postEditItem(from_name: arrEdit[0], to_name: arrEdit[1], from_address: arrEdit[2], to_address: arrEdit[3], from_tel: arrEdit[4], to_tel: arrEdit[5])
    }


    
}
extension QREditInfoItemViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}


extension QREditInfoItemViewController: UITableViewDelegate {

}

extension QREditInfoItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  100.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTopicProducted.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbListEdit.dequeueReusableCell(withIdentifier: "CellEditInfoItemTableViewCell") as! CellEditInfoItemTableViewCell
        cell.selectionStyle = .none
        cell.lbTitleEdit.text = arrTopicProducted[indexPath.row]
        cell.onSetTextEditNumber = {
            print( "----- tf edit inventory \($0)")
            self.arrEdit[indexPath.row] = $0
        }
        cell.tfEdit.text = arrEdit[indexPath.row]

        return cell
    }


}

