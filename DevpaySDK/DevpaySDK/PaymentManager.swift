//
//  PaymentManager.swift
//  DevPaySDK
//
//  Created by DevPay 
//

import Foundation


class PaymentManager {
    
    let ERRO_MSG = "Failed to confirm the payment"
    var restClient: RestClient!
    var config: Config!
    public var paymentIntentSecret: String!

    init(restClient: RestClient, config: Config) {
        self.restClient = restClient
        self.config = config
    }
    
    typealias CompletionBlock = (Bool?, Error?)->()
    typealias IntentCreationCompletionBlock = (String?, Error?)->()
    
    public func confirmPayment(details : PaymentDetail,
                        completion: @escaping CompletionBlock) -> Void {
        
        self.createIntent(details: details) { token, err in
            
            if (token != nil && token!.count > 0) {
                self.confirmIntent(token: token!, details: details) { result, err in
                    completion(result, err)
                }
            }else{
                completion(false, err)
            }   
        }
    }
    
    private func confirmIntent(token: String,
                              details : PaymentDetail,
                              completion: @escaping CompletionBlock) -> Void {
        
        // Card
        var cardDict = [String:Any]()
        cardDict["Number"] = details.card?.cardNum
        cardDict["ExpMonth"] = details.card?.expiryMonth
        cardDict["ExpYear"] = details.card?.expiryYear
        cardDict["Cvc"] = details.card?.cvv
        cardDict["token"] = token

        var payload = [String:Any]()
        var chargeDetails = [String:Any]()
        chargeDetails["amount"] = details.amount
        chargeDetails["fee_amount"] = 0
        chargeDetails["description"] = details.description
        chargeDetails["account_id"] = config.accountId
        chargeDetails["secreate_key"] = config.accessKey
        
        if config.sandbox {
            chargeDetails["environment"] = "sandbox"
        }
        
        payload["CardDetails"] = cardDict
        payload["ChargeDetails"] = chargeDetails
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            
            restClient.post(path: "/v1/charge/confirm_charge",
                            data: jsonData) { data, err in
                
                guard let data = data else {
                    let error = self.errorWithMSG(msg: self.ERRO_MSG, metaData: data)
                    completion(nil,error)
                    return
                }
                
                if let reponseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    
                    guard let result = reponseDict["status"] as? Bool else {
                        let error = self.errorWithMSG(msg: self.ERRO_MSG, metaData: data)
                        completion(nil,error)
                        return
                    }
                    completion(result,nil)
                }
            }
        }
    }

    private func createIntent(details : PaymentDetail,
                              completion: @escaping IntentCreationCompletionBlock) -> Void {

        // Card
        var cardDict = [String:Any]()
        cardDict["Number"] = details.card?.cardNum
        cardDict["ExpMonth"] = details.card?.expiryMonth
        cardDict["ExpYear"] = details.card?.expiryYear
        cardDict["Cvc"] = details.card?.cvv

        var payload = [String:Any]()
        var chargeDetails = [String:Any]()
        chargeDetails["amount"] = details.amount
        chargeDetails["fee_amount"] = 0
        chargeDetails["description"] = details.description
        chargeDetails["account_id"] = config.accountId
        chargeDetails["secreate_key"] = config.accessKey
        
        if config.sandbox {
            chargeDetails["environment"] = "sandbox"
        }

        payload["CardDetails"] = cardDict
        payload["ChargeDetails"] = chargeDetails

        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) {

            restClient.post(path: "/v1/charge/create_Intend",
                            data: jsonData) { data, err in
                
                guard let data = data else {
                    let error = self.errorWithMSG(msg: self.ERRO_MSG, metaData: data)
                    completion(nil,error)
                    return
                }

                if let reponseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    
                    guard let token = reponseDict["token"] as? String else {
                        let error = self.errorWithMSG(msg: self.ERRO_MSG, metaData: data)
                        completion(nil,error)
                        return
                    }
                    completion(token,nil)
                }
            }
        }
    }
    
    func errorWithMSG(msg : String, metaData: Data?) -> NSError {
        var userInfo = [String:Any]()
        userInfo[NSLocalizedDescriptionKey] = msg
        userInfo[NSDebugDescriptionErrorKey] = String(data: metaData ?? Data(), encoding: .utf8) ?? ""
        let error = NSError(domain:"DevPaySDK", code:111, userInfo:userInfo)
        return error
    }

}
