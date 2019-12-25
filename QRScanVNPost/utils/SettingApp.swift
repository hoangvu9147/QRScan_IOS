//
//  SettingApp.swift
//  Monistor
//
//  Created by TruongHieuNghia on 2/8/18.
//  Copyright © 2018 MoonFactory. All rights reserved.
//

import Foundation
class SettingApp {
    
    static let SETTING_APP_IS_ONLINE_MODE = "SETTING_APP_IS_ONLINE_MODE"
    static let instance = SettingApp()
    private init(){
        
    }

    // --- SET VALUE  ID NAME OF READER ZEBAR
    func setIDValueDeviceZebra(id: Int){
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: Constants.ID_VALUE_DEVICE_ZEBRA)
    }

    func getIDValueDeviceZebra() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.ID_VALUE_DEVICE_ZEBRA)
    }


    func setNameValueDeviceZebra(name: String){
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: Constants.REF_DEVICE_NAME_CURRENT)
    }

    func getNameValueDeviceZebra() -> String {
        if let value = UserDefaults.standard.string(forKey: Constants.REF_DEVICE_NAME_CURRENT) {
            return value
        } else {
            return ""
        }
    }


}













