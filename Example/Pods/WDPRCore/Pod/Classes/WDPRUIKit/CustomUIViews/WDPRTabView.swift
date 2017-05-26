//
//  WDPRTabView.swift
//  DLR
//
//  Created by german stabile on 9/9/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

import UIKit

/**
 A WDPRTabView object is a control for selecting between different subtasks, views, or modes in the screen.
 
 Normally, you use tab view in conjunction with a WDPRTabViewController object, but you can also use them as
 standalone controls in your app. Tab Views usually appear across the top edge of the screen and display the titles
 on the items property. A tab view's appearance can be customized with a background color, a color for the selected
 tab, a color for the indicator view, and a text style for the tab's titles to suit the needs of your interface.
 Tapping a tab selects that tab, and you use the selection of the tab to enable the corresponding mode for your
 current screen.
 */
open class WDPRTabView : UIView
{
    /// The items displayed by the tab view.
    open var items = [String]() {
        didSet { update() }
    }
    /**
     The currently selected tab index on the tab view.
     
     Use this property to get the currently selected tab index. If you change the value of this property, the tab
     view selects the corresponding tab and updates the tab view's appearance accordingly.
     When an tab is selected, the tab view displays the selected tab according to the properties
     selectedTabBackgroundColor, selectedIndicatorViewColor and selectedTabTextStyle.
     The default value for this property is 0.
     */
    open var selectedTabIndex = Int(0) {
        didSet { selectTabAtIndex(selectedTabIndex) }
    }
    
    /**
     Closure property called when the user selects a tab.
     */
    open var didTapTabAtIndex:((_ index: Int) -> ())?
    
    /// The background color used on each tab.
    open var tabsBackgroundColor: UIColor? = UIColor.white
    
    /// The background color used on the selected tab.
    open var selectedTabBackgroundColor: UIColor? = UIColor.white
    
    /// The color used on the indicator view which appears below each tab.
    open var unselectedIndicatorViewColor: UIColor? = UIColor.wdprPaleGray()
    
    /// The color of the indicator view, which appears below each tab, when the tab is selected.
    open var selectedIndicatorViewColor: UIColor? = UIColor.wdprBlue()
    
    /// The WDPRTextStyle to use on the selected tab.
    open var selectedTabTextStyle: WDPRTextStyle = .B1D
    
    /// The WDPRTextStyle to use on each tab when they are not selected.
    open var unselectedTabTextStyle: WDPRTextStyle = .B2B
    
    /// The space in points between each tab
    open var tabSeparator: CGFloat = 16 {
        didSet { configureViews() }
    }
    
    fileprivate lazy var collectionView : UICollectionView = self.initializeCollectionView()
    fileprivate lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = self.initializeFlowLayout()
    fileprivate var shouldScroll: Bool = true
    fileprivate var itemsWidth: [CGFloat] = []
    fileprivate var selectedIndexPath: IndexPath? { return collectionView.indexPathsForSelectedItems?.first }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        calculateItemsWidth()
        
        let index = selectedTabIndex
        collectionView.reloadData()
        
        selectTabAtIndex(index)
    }
}

//MARK: UICollectionViewDelegateFlowLayout

extension WDPRTabView : UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (indexPath as NSIndexPath).row == selectedTabIndex {
            return
        }
        
        if let previousSelectedCell = collectionView.cellForItem(at: IndexPath(item: selectedTabIndex, section: 0)) {
            updateAccessiblity(cell: previousSelectedCell, selected: false, index: selectedTabIndex)
        }
        
        if let nextCell = collectionView.cellForItem(at: indexPath) {
            updateAccessiblity(cell: nextCell, selected: true, index: indexPath.row)
        }
        
        selectedTabIndex = (indexPath as NSIndexPath).row
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        
        didTapTabAtIndex?((indexPath as NSIndexPath).row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let defaultWidth = frame.width / CGFloat(items.count)
        
        // IREF-6452: If item's size is bigger than default one we must use item's size.
        let itemWidth = (shouldScroll || itemsWidth[indexPath.row] > defaultWidth) ?
            itemsWidth[indexPath.row] :
            defaultWidth
        
        return CGSize(width: itemWidth, height: frame.height)
    }
}

//MARK: UICollectionViewDataSource

extension WDPRTabView : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WDPRTabCollectionViewCell.cellReuseIdentifier,
                                                      for: indexPath) as! WDPRTabCollectionViewCell
        
        cell.selectedBackgroundColor = selectedTabBackgroundColor
        cell.unselectedBackgroundColor = tabsBackgroundColor
        cell.selectedIndicatorViewColor = selectedIndicatorViewColor
        cell.unselectedIndicatorViewColor = unselectedIndicatorViewColor
        cell.selectedTextStyle = selectedTabTextStyle
        cell.unselectedTextStyle = unselectedTabTextStyle
        
        cell.setTitle(items[(indexPath as NSIndexPath).row])
        cell.isAccessibilityElement = false
        cell.contentView.isAccessibilityElement = true
        let selected = indexPath.row == selectedTabIndex
        updateAccessiblity(cell: cell, selected: selected, index: indexPath.row)
        
        return cell
    }
}

//MARK: Private

private extension WDPRTabView
{
    //MARK: Views Configuration
    
    func configureViews() {
        calculateItemsWidth()
        
        let views = ["collectionView" : collectionView]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", metrics:nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", metrics:nil, views: views))
    }
    
    func update() {
        configureViews()
        collectionView.reloadData()
        selectTabAtIndex(0)
    }
    
    //MARK: Initializers
    
    func initializeFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.zero
        
        return flowLayout
    }
    
    func initializeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(WDPRTabCollectionViewCell.self, forCellWithReuseIdentifier: WDPRTabCollectionViewCell.cellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        return collectionView
    }
    
    //MARK: Helpers
    
    func selectTabAtIndex(_ index: Int) {
        let indexPath = IndexPath(row: min(items.count - 1, max(0, index)), section: 0)
        
        if (indexPath != selectedIndexPath) && items.count > 0 {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func calculateItemsWidth() {
        itemsWidth = [CGFloat]()
        
        if items.count > 0 {
            let label = UILabel()
            let neededWidth: CGFloat = items.reduce(0) {
                label.text = $1
                label.apply(unselectedTabTextStyle)
                label.sizeToFit()
                itemsWidth.append(label.frame.width + tabSeparator * 2)
                return $0 + label.frame.width + tabSeparator * 2
            }
            
            shouldScroll = neededWidth > frame.width
        }
    }
    
    func updateAccessiblity(cell: UICollectionViewCell?, selected: Bool, index: Int) {
        
        let selectedString = WDPRLocalization.localizedString(forKey: "com.wdprcore.tabview.selected", fromTableName: nil, inBundle: WDPRCoreResourceBundleName) ?? ""
        let selectedText = selected ? "," + selectedString : ""
        
        //This forms an accessibility label with this format: [Tab Title], Tab [tab index] of [total of tabs], Selected (if applies)
        // Selected example: Profile, Tab 1 of 2, Selected
        // Unselected example: Friends and Family, Tab 2 of 2
        cell?.contentView.accessibilityLabel = ("\(items[index]), Tab \(index + 1) of \(items.count)") + selectedText
    }
}

extension WDPRTabView
{
    
    public func updateAccessibilityStatus(_ status : Bool, atIndex : Int) {
        
        let cells = collectionView.visibleCells as NSArray
        cells.enumerateObjects({ (object : Any, index : Int, stop : UnsafeMutablePointer<ObjCBool>) in
            
            if let cell = object as? WDPRTabCollectionViewCell {
                
                if status {
                    if cell.accessibilityIdentifier != String(atIndex) {
                        cell.accessibilityElementsHidden = status
                    }
                }
                else {
                    cell.accessibilityElementsHidden = status
                }
            }
        })
    }
}
