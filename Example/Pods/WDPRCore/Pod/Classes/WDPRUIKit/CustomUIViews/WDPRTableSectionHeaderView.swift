//
//  WDPRTableSectionHeaderView.swift
//  WDPRUIKit
//
//  Created by J.Rodden on 2/2/17.
//
//

import UIKit
import Foundation

/// WDPRTableSectionHeaderView provides a "sticky header" with shadowing
/// default text styling, and standard metrics. To override text styling,
/// customize the textLabel's style attributes, or use the attributedText
/// property to set a pre-styled text string

@objc public class WDPRTableSectionHeaderView : UITableViewHeaderFooterView
{
    var label = UILabel()
    var border = CALayer()
    
    static let inset = 16
    static let shadowOpacity = 0.35
    
    static public let minimumHeight = 22 + 2*inset
    
    override public var frame : CGRect 
    {
        get { return super.frame }
        
        set(frame)
        {
            if (frame.width != 0)
            {
                super.frame = frame
                
                border.frame = bounds.insetBy(dx: -1, dy: 0)
                label.preferredMaxLayoutWidth = bounds.width - 
                    CGFloat(2 * WDPRTableSectionHeaderView.inset)
                
                if let tableView = superview as? UITableView
                {
                    layer.shadowOpacity = 
                        Float(((tableView.contentOffset.y > 0) &&
                            ((frame.minY - tableView.contentOffset.y - 
                                tableView.contentInset.top) <= 0)) ? 
                                    WDPRTableSectionHeaderView.shadowOpacity : 0.0)
                }
            }
        }
    }
    
    class public var reuseID: String { return "WDPRTableSectionHeaderView" }
    
    override public var textLabel: UILabel? 
    { 
        get { return !(label.attributedText != nil) ? label : nil } 
    }
        
    public var attributedText: NSAttributedString?
    {
        get
        {
            return label.attributedText
        }
        
        set(attributedText)
        {
            label.attributedText = attributedText
        }
    }
    
    // MARK:
    
    required public init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() 
    { 
        super.layoutSubviews(); 
        contentView.frame = bounds
    }
    
    override public func prepareForReuse() 
    {
        attributedText = nil
        super.prepareForReuse()
    }
    
    override init(reuseIdentifier: String?)
    {
        label.numberOfLines = 0
        label.apply(WDPRTextStyle.B1G)
        label.lineBreakMode = .byTruncatingTail
        
        border.borderColor = 
            UIColor(hexValue:0xc8c7cc).cgColor
        border.borderWidth = 1/UIScreen.main.scale
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = 
            UIColor(hexValue:0x253b56).cgColor
        
        contentView.layer.addSublayer(border) 
        contentView.backgroundColor = UIColor.white
        
        translatesAutoresizingMaskIntoConstraints = false

        // add the label with autolayout constraints
        let labelConstraint = String(format:"|-%d-[label]-%d-|", 
                                     WDPRTableSectionHeaderView.inset, 
                                     WDPRTableSectionHeaderView.inset)
        contentView.addSubviews([ "label" : label ], 
                                withVisualConstraints:["V:" + labelConstraint, 
                                                       "H:" + labelConstraint])
    }
}

