//
//  PaymentRequest.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 5/25/17.
//
//

import Foundation
//this protocol cantain some request information
//this place use public because if this framework used for oc,this method must public or it can't be use.

@objc(SHDRPaymentRequest)
public protocol PaymentRequest {
    //pay amount
    var payAmount: String { get }
    //
    var payDescription: String { get }
    // 
    var order: String { get }
    //
    init(amount: String, paymentDescription: String, order: String)
    //
    @objc optional
    static func requestBy(amount: String, description: String, completeHandler: @escaping((PaymentRequest?,Error?)->()))
}
