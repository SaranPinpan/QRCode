//
//  ViewController.swift
//  QR Code
//
//  Created by Saran Pinpan on 15/2/18.
//  Copyright © 2018 Saran Pinpan. All rights reserved.
//

import UIKit
import CryptoSwift
import EFQRCode

class ViewController: UIViewController {
    
    @IBOutlet var PhoneOrCitizen: UITextField!
    @IBOutlet var Amount: UITextField!
    @IBOutlet var QRImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
    }
    
    @IBAction func Generate(_ sender: Any) {
        let qr = GenPromptPayQR.genPromptpay(target: PhoneOrCitizen.text!, amount: Amount.text!)
        print("QR: \(qr)")
//        let bp = GenPromptPayQR.genBillpay(amount: Amount.text!,
//                                           billerId: "000598611536591",
//                                           ref1: "18021310512750437779",
//                                           ref2: "",
//                                           ref3: "MNATH001000000000010")

//        print(GenPromptPayQR.isStandardThaiQr(qrValue: qr))
        print(GenPromptPayQR.decode(value: qr))
        
        if let tryImage = EFQRCode.generate(content: qr) {
            QRImage.image = UIImage(cgImage: tryImage)
        } else {
            // print("Create QRCode image failed!")
        }
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
