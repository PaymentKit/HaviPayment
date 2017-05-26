//
//  PaymentResponse.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 5/26/17.
//
//

import Foundation

@objc(SHPaymentResponse)
public protocol PaymentResponse {
    var error: Error? { get }
    var result: Any? { get }
    init(result: Any?)
}
