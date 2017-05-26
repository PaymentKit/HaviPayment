//
//  WDPRNotificationBannerManager.swift
//  Pods
//
//  Manager classed used to display the notification banners based on priority.
//  This class also let's the WDPRNotification class know if there is an existing
//  banner so the existing banner can be dismissed before the next one is displayed.
//
//  Created by Nguyen, Kevin on 7/19/16.
//
//

import UIKit

open class WDPRNotificationBannerManager: NSObject
{
    /// The shared instance of the manager.
    open static let sharedInstance = WDPRNotificationBannerManager()
    
    /// The current banner being displayed.
    open var currentBanner: WDPRNotificationBanner?
    
    /// The next (queued) banner to be displayed.
    open var nextBanner: WDPRNotificationBanner?
    
    /** 
     The ID provided by the WDPRNotificationBanner class for the banner that needs to be 
     dismissed after animations.
    */
    open var bannerIdToDismiss: String?
    
    fileprivate override init() {} // Prevents others from using the default initializer for this class.
    
    /**
     Queues up next banner.
     
     - Parameters:
     - banner: The banner to be queued.
     
     - Returns: A bool indicating if the banner was successfully queued or not.
     */
    open func queueNextBanner(_ banner: WDPRNotificationBanner!) -> Bool
    {
        guard let existingBanner = currentBanner else
        {
            nextBanner = banner
            return true
        }
        
        // Check if the proposed banner is higher priority than the current banner
        if showNextBannerWithExistingBannerType(existingBanner.type, nextBannerType: banner.type)
        {
            guard let queuedBanner = nextBanner else
            {
                nextBanner = banner
                return true
            }
            
            // Check if the proposed banner is higher priority than the queued banner
            if showNextBannerWithExistingBannerType(queuedBanner.type, nextBannerType: banner.type)
            {
                nextBanner = banner
                return true
            }
        }
        
        return false
    }
    
    /**
     Determines if the next banner can be shown based on banner priority set via the order of the banner type enum.
     
     - Parameters:
     - existingBannerType: The type of the existing banner.
     - nextBannerType: The type of the next banner.
     
     - Returns: A bool indicating if the next banner has a higher priority than the existing banner.
     */
    func showNextBannerWithExistingBannerType(_ existingBannerType: WDPRNotificationBannerType!, nextBannerType: WDPRNotificationBannerType!) -> Bool
    {
        return nextBannerType.rawValue > existingBannerType.rawValue
    }
}
