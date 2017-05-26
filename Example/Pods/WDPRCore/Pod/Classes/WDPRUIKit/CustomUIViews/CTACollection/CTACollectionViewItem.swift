//
//  CTACollectionViewItem.swift
//  Pods
//
//  Created by Martin Di Bella on 9/9/16.
//
//

import Foundation

@objc(WDPRCTACollectionViewItem)
open class CTACollectionViewItem : UICollectionViewCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconSizeConstraint: NSLayoutConstraint!
    @IBOutlet var separatorView: UIView!
    
    var separatorVisible : Bool {
        set {
            separatorView.isHidden = !newValue
        }
        get {
            return !separatorView.isHidden
        }
    }
    
    override open func awakeFromNib() {
        nameLabel.apply(WDPRTextStyle.C1D)
        configureAccessibility()
    }
    
    open static func reuseIdentifier() -> String {
        return "CTACollectionViewItem"
    }
    
    open func iconSize() -> CGSize {
        return CGSize(width: iconSizeConstraint.constant, height: iconSizeConstraint.constant)
    }
    
    // MARK: - Accessibility
    
    private func configureAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraitButton
    }    
}
