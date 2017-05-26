//
//  PaymentMethod.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 5/25/17.
//
//

import Foundation
import UIKit

///payment method define some func to use all,this protocol not inherient from nsobject,so it must to use for other class ,and must use @objc to let oc use
@objc(SHDRPaymentMethod)//this will be used for oc
public protocol PaymentMethod {
    
    //paymentRequest contains infomation
    var request: PaymentRequest { get }
    
    var isApplicationReponseRequired: Bool { get }
    
    init(paymentRequest: PaymentRequest)
    
    func pay(completeHandler:@escaping((PaymentResponse) -> ()))
    
    func pay(scheme: String, completeHandler:@escaping((PaymentResponse) -> ()))
    
    func application(application: UIApplication, openUrl url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
    @objc optional
    var paymentIcon: UIImage? { get }
}
