//
//  AlipayRequest.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 5/26/17.
//
//

import Foundation
import SHPaymentMethod

public class AlipayRequest: NSObject, PaymentRequest{
    public var payAmount: String
    public var payDescription: String
    public var order: String
    
    public required init(amount: String, paymentDescription: String, order: String) {
        self.payAmount = amount
        self.payDescription = paymentDescription
        self.order = order
        super.init()
    }
}
