//
//  AlipayRequest.swift
//  Pods
//
//  Created by Li, Havi X. -ND on 5/26/17.
//
//
import Foundation
import WDPRAliPayWrapper.APayAuthInfo
import SHPaymentMethod

@objc(SHDRAlipayPayment)
public class AlipayPayment: NSObject, PaymentMethod{
    
    private let kAlipaySafepay = "safepay"
    private let kkAlipayPlatformAPI = "platformapi"
    public private(set) var request: PaymentRequest
    
    public required init(paymentRequest: PaymentRequest) {
        self.request = paymentRequest
        super.init()
    }
    
    public var isApplicationReponseRequired: Bool{
        get {
            return ["alipay://"].reduce(false){ (result, scheme) -> Bool in
                let instagramUrl = URL(string:scheme)
                return UIApplication.shared.canOpenURL(instagramUrl!) || result
            }
        }
    }
    
    public func pay(completeHandler: @escaping ((PaymentResponse) -> ())) {
        pay(scheme: "", completeHandler: completeHandler)
    }
    
    public func pay(scheme: String, completeHandler: @escaping ((PaymentResponse) -> ())) {
        AlipaySDK.defaultService().payOrder(request.order, fromScheme: scheme) { (result) -> Void in
            print("result \(result)")
            let response = AlipayResponse(result: result)
            completeHandler(response)
        }
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return true
    }
    
    public func application(application: UIApplication, openUrl url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true
    }
    
    private func progressApplicationResponseBy(url: URL) -> Bool {
        
        if url.host == kAlipaySafepay {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (result) in
                print("SHDRAppDelegate:safepay:result = \(result)")
            })
            return true
        }
        
        if url.host == kkAlipayPlatformAPI {
            AlipaySDK.defaultService().processAuthResult(url as URL!, standbyCallback: { (result) in
                print("SHDRAppDelegate:platformapi:result = \(result)")
            })
            return true
        }
        return false
    }
}
