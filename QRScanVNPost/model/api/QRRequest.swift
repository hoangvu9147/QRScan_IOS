//
//  QRRequest.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class QRRequest {
    var mParameters: Dictionary = Dictionary<String,Any>()
    var mHeader: HTTPHeaders? = nil
    var mMethod: HTTPMethod = .get
    var mResponseType: QRResponseType?

    var mRequestName: String
    
    init(requestName:String,responseType:QRResponseType? = nil) {
        self.mRequestName = requestName;
        if responseType == nil {
            self.mResponseType = .json
        } else {
            self.mResponseType = responseType!
        }
    }

    func getDomain() -> String {
        return "";
    }
    func getVersion() -> String {
        return "";
    }
    func getPath() -> String? {
        return nil;
    }

    func makeUrl() -> String {
        print("mRequestName : \(mRequestName)")
        let url = "\(getDomain())\(getVersion())\(mRequestName)"
        return url
    }




    func getBodyPost() -> String {
        return ""
    }
    func get() -> QRRequest {
        self.mMethod = .get
        return self
    }

    func post() -> QRRequest {
        self.mMethod = .post
        return self
    }

    func delete() -> QRRequest {
        self.mMethod = .delete
        return self
    }

    func addHeaders(key: String, value: String) {
        if mHeader == nil {
            mHeader = HTTPHeaders()
        }
        mHeader?.updateValue(value, forKey: key)
    }
    func addParam(key:String, value : Any) {
        mParameters.updateValue(value, forKey: key)
    }

    func setParams(params: Dictionary<String,Any>) {
        mParameters = params
    }

    func execute(mfResponse:@escaping (QRRequest,QRResponse?,Error?)-> Void) {
        print(" execute --- Api url: \(makeUrl())")
        do{
            let jsonHeader = try JSONSerialization.data(withJSONObject: mHeader as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonStringHeader = NSString(data: jsonHeader, encoding: String.Encoding.utf8.rawValue)! as String
            print("Api Header: \(jsonStringHeader)")
        }catch {
            print("Api param:  error")
        }
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: mParameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            print("-00000-jsonString --Api param: \(jsonString)")
        }catch {
            print("---00000---Api param:  error")
        }

        if mResponseType == .json {
            var encode: ParameterEncoding = URLEncoding.default

            if mMethod == .post {
                encode = JSONEncoding.default
            }

            Alamofire.request(makeUrl(), method: mMethod, parameters: mParameters, encoding: encode, headers:mHeader)
                .responseJSON{ response in
                    switch response.result {
                    case .success:
                        do{
                            let result:JSON = try JSON(data: response.data!);
                            mfResponse(self,QRResponse(responseData:result, responseType: QRResponseType.json),nil)

                            print("-----11111---Api response:\((result as AnyObject))")

                        } catch {
                            debugPrint("Api response: convert json error")
                        }

                    case .failure(let error):
                        mfResponse(self,nil,error)
                    }
            }
        } else {
            var encode: ParameterEncoding = URLEncoding.default
            if mMethod == .post {
                encode = JSONEncoding.default
            }
            Alamofire.request(makeUrl(), method: mMethod, parameters: mParameters, encoding: encode, headers:mHeader)
                .responseString(completionHandler:{ response in
                    switch response.result {
                    case .success:
                        let result:String = response.result.value!
                        mfResponse(self,QRResponse(responseData:result, responseType: QRResponseType.text),nil)
                    case .failure(let error):
                        mfResponse(self,nil,error)
                    }
                }
            )
        }
    }

}

