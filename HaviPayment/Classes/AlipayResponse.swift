//
//  AlipayResponse.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 6/1/17.
//
//

import Foundation
import SHPaymentMethod

@objc(SHDRAlipayResponse)
public class AlipayResponse:NSObject, PaymentResponse{
    public private(set) var error: Error?
    public private(set) var result: Any?
    
    public required init(result: Any?) {
        self.result = result
    }
}
