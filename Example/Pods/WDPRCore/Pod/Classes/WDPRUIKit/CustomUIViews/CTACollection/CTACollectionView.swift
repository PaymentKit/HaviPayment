//
//  CTACollectionView.swift
//  Pods
//
//  Created by Martin Di Bella on 9/6/16.
//
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


@objc(WDPRCTACollectionViewDataSource) public protocol CTACollectionViewDataSource {
    func numberOfItems(_ collection: CTACollectionView) -> Int
    func buttonIconImage(_ collection: CTACollectionView, index: Int, size: CGSize) -> UIImage?
    func buttonDisplayName(_ collection: CTACollectionView, index: Int) -> String?
    @objc optional func buttonAccessibilityLabel(_ collection: CTACollectionView, index: Int) -> String?
}

@objc(WDPRCTACollectionViewDelegate) public protocol CTACollectionViewDelegate {
    @objc optional func buttonSelected(_ carrusel: CTACollectionView, index: Int) -> Void
}

@objc(WDPRCTACollectionView)
open class CTACollectionView : UIView {
    @IBOutlet open weak var dataSource: CTACollectionViewDataSource!
    @IBOutlet open weak var delegate: CTACollectionViewDelegate!
    fileprivate var collectionView: UICollectionView!
    fileprivate var itemNib: UINib!
    fileprivate var separatorView: UIView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.itemNib = self.collectionViewItemNib()
        self.createSubViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.itemNib = self.collectionViewItemNib()
        self.createSubViews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open lazy var prototypeCell: CTACollectionViewItem = {
        let nib = self.itemNib
        guard let cell = nib?.instantiate(withOwner: nil, options: nil)[0] as? CTACollectionViewItem else {
            assert(false, "Cell is not from the expected type")
            return CTACollectionViewItem()
        }
        return cell
    }()
    
    open var bottomSeparatorVisible : Bool {
        set {
            separatorView.isHidden = !newValue
        }
        get {
            return !separatorView.isHidden
        }
    }
    
    /**
     Scrolls the collection to the specified item.  The position will be left aligned.  Animation is optional,
     by default is false.
     IMPORTANT: This method don't take into account the padding, so if you need the collection to start at the padding,
     use _resetScrolling_ instead.
     
     - Parameter index: Index of the item to scroll to.
     - Parameter animated: The scroll is performed animatedly or not.  By defalut it's not animated.
     */
    open func scrollToItemAt(_ index: Int, animated: Bool = false) {
        guard index < dataSource?.numberOfItems(self) else {
            return
        }
        collectionView.scrollToItem(at: IndexPath(row: index, section:0),
                                    at: UICollectionViewScrollPosition.left,
                                    animated: animated)
    }
    
    /**
     Resets the scrolling, leaving the collection at the original position.  This method takes into account the padding.
     
     - Parameter animated: The scroll is performed animatedly or not.  By defalut it's not animated.
     */
    open func resetScrolling(animated: Bool = false) {
        var contentOffset = collectionView.contentOffset
        contentOffset.x = 0
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
}

// MARK: Overridable methods
public extension CTACollectionView {
    
    public func registerCollectionViewItem() {
        collectionView.register(itemNib, forCellWithReuseIdentifier: CTACollectionViewItem.reuseIdentifier())
    }
    
    public func collectionViewItemNib() -> UINib {
        return UINib(nibName: Constants.collectionViewItemNibName, bundle: WDPRFoundation.wdprCoreResourceBundle())
    }
    
    public func minimumWidthForCurrentItemCount() -> CGFloat {
        guard let numberOfItems = dataSource?.numberOfItems(self) , numberOfItems > 0 else {
            return 0
        }
        let count = min(numberOfItems, Constants.numberOfItemsThreshold)
        var minWidth = (collectionView.bounds.width - (2 * Constants.margin)) / CGFloat(count)
        if numberOfItems > Constants.numberOfItemsThreshold {
            minWidth -= Constants.oneSnowballUnit
        }
        
        return minWidth
    }
    
    /*
     Method to return the minimum width the item should have based on its content.  Can be overriden by subclasses
     if special calculations should be done.
     - Parameter at Index of the item to calculate the min width
     - Returns CGFloat with the minumum width
     */
    public func minimumWidthForItem(at index: Int) -> CGFloat {
        // IMPORTANT: To calculate size, we just need to set the text.  The image already has a fixed size
        let cell = prototypeCell
        cell.nameLabel.text = dataSource.buttonDisplayName(self, index: index)
        var targetSize = UILayoutFittingCompressedSize
        targetSize.height = collectionView.bounds.size.height
        let minSize = cell.systemLayoutSizeFitting(targetSize)
        
        return minSize.width
    }
}

// MARK: Private methods
private extension CTACollectionView {
    
    struct Constants {
        static let collectionViewItemNibName = "CTACollectionViewItem"
        static let itemSpacing: CGFloat = 0
        static let margin: CGFloat = 16
        static let moreThanThresholdEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
        static let thresholdOrLessItemsEdgeInsets = UIEdgeInsetsMake(0, margin, 0, margin)
        static let numberOfItemsThreshold = 3
        static let oneSnowballUnit: CGFloat = 8
    }
    
    func createSubViews() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionViewLayout.minimumLineSpacing = Constants.itemSpacing
        collectionViewLayout.minimumInteritemSpacing = Constants.itemSpacing
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        registerCollectionViewItem()
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.wdprMutedGray()
        addSubviews(["collectionView" : collectionView, "separator": separatorView], withVisualConstraints: [
            "H:|[collectionView]|",
            "H:|[separator]|",
            "V:|[collectionView][separator(1)]|"
            ])
    }
}

// MARK: Collection View related methods
extension CTACollectionView : UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        
        let numberOfItems = dataSource.numberOfItems(self)
        collectionView.isScrollEnabled = (numberOfItems > Constants.numberOfItemsThreshold)
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            guard let dataSource = dataSource else {
                return CTACollectionViewItem()
            }
            let item : CTACollectionViewItem =
                collectionView.dequeueReusableCell(withReuseIdentifier: CTACollectionViewItem.reuseIdentifier(),
                                                   for: indexPath) as! CTACollectionViewItem
            item.nameLabel.text = dataSource.buttonDisplayName(self, index: (indexPath as NSIndexPath).row)
            item.iconView.image = dataSource.buttonIconImage(self, index: (indexPath as NSIndexPath).row, size: item.iconSize())
            item.accessibilityLabel = dataSource.buttonAccessibilityLabel?(self, index: indexPath.row) ??
                item.nameLabel.text?.replacingOccurrences(of: "\n", with: " ")


            let lastItem = ((indexPath as NSIndexPath).row == (dataSource.numberOfItems(self) - 1))
            item.separatorVisible = !lastItem
            
            return item
    }
}

extension CTACollectionView : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minWidth = minimumWidthForCurrentItemCount()
        let minItemWidth = minimumWidthForItem(at: (indexPath as NSIndexPath).row)
        return CGSize(width:ceil(max(minWidth, minItemWidth)), height: collectionView.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let dataSource = self.dataSource else {
            return UIEdgeInsets.zero
        }
        if dataSource.numberOfItems(self) > Constants.numberOfItemsThreshold {
            return Constants.moreThanThresholdEdgeInsets
        } else {
            return Constants.thresholdOrLessItemsEdgeInsets
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.buttonSelected?(self, index: (indexPath as NSIndexPath).row)
    }
}
