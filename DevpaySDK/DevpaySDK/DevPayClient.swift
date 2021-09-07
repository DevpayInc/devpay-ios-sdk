//
//  DevPayClient.swift
//  DevPaySDK
//
//  Created by DevPay 
//

import Foundation

public class DevpayClient {
     
    var config:Config!
    var paymentManager:PaymentManager!
    
    public init(config: Config) {
        self.config = config
        let restClient = restClientDevPay()
        paymentManager = PaymentManager(restClient: restClient, config: config)
        paymentManager.paymentIntentSecret = config.accessKey
    }
    
    public typealias PaymentConfirmationCompletion = (Bool?,Error?)->()
    
    public func confirmPayment(details: PaymentDetail,
                               completion: @escaping  PaymentConfirmationCompletion) -> Void {
        
        self.paymentManager.confirmPayment(details: details) { result, err in
            completion(result, err)
        }
    }
    
    private func restClientDevPay() -> RestClient {
        let headers = ["Content-Type":"application/json"]

        let baseURL = "https://api.devpay.io"
        let restClient = RestClient(baseURL: baseURL,
                                    headers: headers)
        restClient.debug = self.config.debug
        return restClient
    }
}
