//
//  ViewController.swift
//  DevPaySDKSample
//
//  Created by DevPay 
//

import UIKit
import DevpaySDK

class ViewController: UIViewController {
    
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet var payBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func payAction(button: UIButton){
        
        let config = Config(accountId: "ACCOUNT_ID",
                            accessKey: "SECRET",
                            sandbox: true)

        let payClient = DevpayClient(config: config)
        
        let devPayVC = DevpayPaymentVC.instance()
        let amountNumber = self.amountTf!.text;
        devPayVC.amount = Int(amountNumber ?? "")
        
        devPayVC.onPayAction = { pd in
            
            payClient.confirmPayment(details: pd) { success, err in
                
                if err != nil {
                    print("Error \(String(describing: err))")
                }else {
                    print("Payment successful")
                }
            }
        }
        
        let navigation = UINavigationController(rootViewController: devPayVC)

        devPayVC.closeAction = {
            navigation.dismiss(animated: true, completion: nil)
        }
        
        self.present(navigation, animated: true, completion: nil)
    }
    
}

