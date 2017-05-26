//
//  WDPRTableHeaderView.swift
//  DLR
//
//  Created by german stabile on 10/5/15.
//  Copyright © 2015 WDPRO. All rights reserved.
//

import Foundation

open class WDPRTableHeaderFooterView: UITableViewHeaderFooterView
{
    fileprivate static let defaultHorizontalMargin = CGFloat(16)
    fileprivate static let defaultVerticalMargin = CGFloat(14)
    fileprivate static let defaultBottomMargin = CGFloat(14)
    fileprivate static let defaultSeparatorsHorizontalMargin = CGFloat(16)
    fileprivate static let defaultTopSeparatorVerticalMargin = CGFloat(0)
    fileprivate static let defaultBottomSeparatorVerticalMargin = CGFloat(0)
    
    open var horizontalMargin: CGFloat {
        get { return horizontalMarginConstraints.first?.constant ?? WDPRTableHeaderFooterView.defaultHorizontalMargin }
        set(value) { horizontalMarginConstraints.forEach { $0.constant = value } }
    }
    open var verticalMargin: CGFloat {
        get { return verticalMarginConstraints.first?.constant ?? WDPRTableHeaderFooterView.defaultVerticalMargin }
        set(value) { verticalMarginConstraints.forEach { $0.constant = value } }
    }
    open var bottomMargin: CGFloat {
        get { return bottomVerticalMarginConstraints.first?.constant ?? WDPRTableHeaderFooterView.defaultBottomMargin }
        set(value) { bottomVerticalMarginConstraints.forEach { $0.constant = value } }
    }
    open var separatorsHorizontalMargin: CGFloat {
        get { return separatorsHorizontalMarginConstraints.first?.constant ??
            WDPRTableHeaderFooterView.defaultSeparatorsHorizontalMargin }
        set(value) { separatorsHorizontalMarginConstraints.forEach { $0.constant = value } }
    }
    open var topSeparatorVerticalMargin: CGFloat {
        get { return topSeparatorVerticalMarginConstraints.first?.constant ??
            WDPRTableHeaderFooterView.defaultTopSeparatorVerticalMargin }
        set(value) { topSeparatorVerticalMarginConstraints.forEach { $0.constant = value } }
    }
    open var bottomSeparatorVerticalMargin : CGFloat {
        get { return topSeparatorVerticalMarginConstraints.first?.constant ??
            WDPRTableHeaderFooterView.defaultBottomSeparatorVerticalMargin }
        set(value) { topSeparatorVerticalMarginConstraints.forEach { $0.constant = value } }
    }
    open var title: String? {
        get { return titleLabel.text }
        set(text) {
            titleLabel.text = text
            accessibilityLabel = text
        }
    }
    open var textStyle: WDPRTextStyle = .B2D {
        didSet { titleLabel?.apply(textStyle) }
    }
    open var labelAlignment: NSTextAlignment = .left {
        didSet { titleLabel.textAlignment = labelAlignment }
    }
    open var bottomSeparatorLineColor: UIColor? {
        get { return bottomSeparator.backgroundColor }
        set(color) { bottomSeparator.backgroundColor = color }
    }
    open var topSeparatorLineColor: UIColor? {
        get { return topSeparator.backgroundColor }
        set(color) { topSeparator.backgroundColor = color }
    }
    
    @IBOutlet fileprivate weak var topSeparator: UIView!
    @IBOutlet fileprivate weak var bottomSeparator: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var rootView: UIView!
    @IBOutlet fileprivate var horizontalMarginConstraints: [NSLayoutConstraint] = []
    @IBOutlet fileprivate var verticalMarginConstraints: [NSLayoutConstraint] = []
    @IBOutlet fileprivate var separatorsHorizontalMarginConstraints: [NSLayoutConstraint] = []
    @IBOutlet fileprivate var bottomVerticalMarginConstraints: [NSLayoutConstraint] = []
    @IBOutlet fileprivate var topSeparatorVerticalMarginConstraints: [NSLayoutConstraint] = []
    @IBOutlet fileprivate var bottomSeparatorVerticalMarginConstraints: [NSLayoutConstraint] = []
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureViews()
        configureDefaultMargins()
        configureAccessibility()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func preferredHeight() -> CGFloat {
        let calculatedLabelSize = titleLabel.sizeThatFits(CGSize(width: bounds.width - horizontalMargin * 2, height: CGFloat.greatestFiniteMagnitude))
        return calculatedLabelSize.height + verticalMargin + bottomMargin
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.preferredMaxLayoutWidth = bounds.width - horizontalMargin * 2
    }
}

private extension WDPRTableHeaderFooterView
{
    func configureViews() {
        let bundle = WDPRFoundation.wdprCoreResourceBundle()
        UINib(nibName: "WDPRTableHeaderFooterView", bundle: bundle).instantiate(withOwner: self, options: nil)
        rootView.translatesAutoresizingMaskIntoConstraints = true
        rootView.frame = contentView.bounds
        rootView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.addSubview(rootView)
        
        titleLabel?.apply(textStyle)
        bottomSeparatorLineColor = UIColor.wdprMutedGray()
        topSeparatorLineColor = UIColor.wdprMutedGray()
    }
    
    func configureDefaultMargins() {
        let selfClass = type(of: self)
        
        horizontalMargin = selfClass.defaultHorizontalMargin
        verticalMargin = selfClass.defaultVerticalMargin
        bottomMargin = selfClass.defaultBottomMargin
        separatorsHorizontalMargin = selfClass.defaultSeparatorsHorizontalMargin
        topSeparatorVerticalMargin = selfClass.defaultTopSeparatorVerticalMargin
        bottomSeparatorVerticalMargin = selfClass.defaultBottomSeparatorVerticalMargin
    }
    
    func configureAccessibility() {
        isAccessibilityElement = true
    }
}
