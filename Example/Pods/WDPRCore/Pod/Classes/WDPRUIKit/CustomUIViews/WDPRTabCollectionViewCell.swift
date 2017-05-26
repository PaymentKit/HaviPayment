//
//  WDPRTabCollectionViewCell.swift
//  DLR
//
//  Created by german stabile on 9/9/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

import UIKit

final class WDPRTabCollectionViewCell: UICollectionViewCell
{
    static let cellReuseIdentifier: String = "TabCell"
    
    var unselectedBackgroundColor: UIColor? {
        didSet { update(if: !isSelected, view: self, withColor: unselectedBackgroundColor) }
    }
    var selectedBackgroundColor: UIColor? {
        didSet { update(if: isSelected, view: self, withColor: selectedBackgroundColor) }
    }
    var unselectedIndicatorViewColor: UIColor? {
        didSet { update(if: !isSelected, view: selectedIndicatorView, withColor: unselectedIndicatorViewColor) }
    }
    var selectedIndicatorViewColor: UIColor? {
        didSet { update(if: isSelected, view: selectedIndicatorView, withColor: selectedIndicatorViewColor) }
    }
    var selectedTextStyle: WDPRTextStyle = .B1D {
        didSet { update(if: isSelected, label: titleLabel, withStyle: selectedTextStyle) }
    }
    var unselectedTextStyle: WDPRTextStyle = .B1B {
        didSet { update(if: !isSelected, label: titleLabel, withStyle: unselectedTextStyle) }
    }
    
    fileprivate var selectedIndicatorViewHeight : CGFloat = 4
    fileprivate lazy var titleLabel: UILabel = self.initializeTitleLabel()
    fileprivate lazy var selectedIndicatorView : UIView = self.initializeSelectedIndicatorView()
    
    //MARK: View Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        isAccessibilityElement = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    //MARK: Collection View Cell Methods
    
    override var isSelected : Bool {
        didSet {
            selectedIndicatorView.backgroundColor = isSelected ?
                selectedIndicatorViewColor :
            unselectedIndicatorViewColor
            
            titleLabel.apply(isSelected ? selectedTextStyle : unselectedTextStyle)
            
            self.backgroundColor = isSelected ?
                selectedBackgroundColor :
            unselectedBackgroundColor
        }
    }
    
    //MARK: Setters
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}

//MARK: Private
private extension WDPRTabCollectionViewCell
{
    //MARK: Lazy Initializers
    
    func initializeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        contentView.addSubview(label)
        
        return label
    }
    
    func initializeSelectedIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = unselectedIndicatorViewColor
        contentView.addSubview(view)
        
        return view
    }
    
    //MARK: Views Configuration
    
    func configureViews() {
        backgroundColor = unselectedBackgroundColor
        
        let views = ["titleLabel"            : titleLabel,
                     "selectedIndicatorView" : selectedIndicatorView]
        
        let metrics = ["indicatorViewHeight" : selectedIndicatorViewHeight]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[selectedIndicatorView]|", metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel][selectedIndicatorView(==indicatorViewHeight)]|", metrics: metrics, views: views))
    }
    
    func update(if needsUpdate: Bool, view: UIView!, withColor color: UIColor?) {
        if needsUpdate {
            view.backgroundColor = color
        }
    }
    
    func update(if needsUpdate: Bool, label: UILabel!, withStyle style: WDPRTextStyle) {
        if needsUpdate {
            label.apply(style)
        }
    }
}
