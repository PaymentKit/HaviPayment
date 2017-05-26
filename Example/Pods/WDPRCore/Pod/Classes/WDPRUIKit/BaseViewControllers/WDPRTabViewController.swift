//
//  WDPRTabViewController.swift
//  DLR
//
//  Created by german stabile on 9/16/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

import UIKit

/**
 The WDPRTabViewController class implements a specialized view container controller that manages a tab selection
 interface. This tab view interface displays tabs at the top of the window for selecting between the different
 child view controllers.
 
 Each tab of a tab view controller interface is associated with a custom view controller. When the user selects a
 specific tab, the tab view controller displays the the corresponding child view controller with an animated sliding
 animation.
 
 To configure the tabs of a tab view controller, you return the child view controllers to use in each tab
 index in the viewControllerAtIndex closure property. When setting this property, the first tab will be selected.
 */
open class WDPRTabViewController: WDPRViewController
{
    static fileprivate let transitionAnimationDuration = abs(0.4)
    
    open var tabBarHidden: Bool
    {
        get {
            guard let tabViewHeightConstraint = self.tabViewHeightConstraint else {return false}
            
            return !(tabViewHeightConstraint.constant > 0)
        }
        set(hidden) {
            tabViewHeightConstraint?.constant = hidden ? 0.0 : tabViewHeight
            view!.setNeedsLayout()
        }
    }
    
    /// The title to use on each tab.
    open var tabTitles: [String] {
        get { return tabView.items }
        set(tabTitles) { tabView.items = tabTitles; configureViews() }
    }
    
    /**
     Closure property called every time the selected tab changes to provide the view controller to use
     on the next tab.
     */
    open var viewControllerAtIndex:((_ index: Int) -> (UIViewController?))? {
        didSet { onDidSelectTabAtIndex(selectedTabIndex) }
    }
    
    /// Variable used to set the initialIndex of the WDPRTabViewController
    open var selectedTabIndex = Int(0) {
        didSet { tabView.selectedTabIndex = selectedTabIndex }
    }
    
    fileprivate var tabViewHeight: CGFloat = 50
    fileprivate var selectedViewController: UIViewController?
    fileprivate var tabViewHeightConstraint: NSLayoutConstraint?
    fileprivate lazy var tabView: WDPRTabView! = self.initTabView()
    fileprivate lazy var containerView: UIView! = self.initContainerView()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}

//MARK: - Private

private extension WDPRTabViewController
{
    override open func loadView() {
        super.loadView()
        configureViews()
        
        onDidSelectTabAtIndex(selectedTabIndex)
        
        tabView.didTapTabAtIndex = // now everything is configured
            { [weak self] index in self?.onDidSelectTabAtIndex(index) }
    }
    
    func configureViews() {
        if !isViewLoaded { return }
        
        view.addSubview(tabView)
        view.addSubview(containerView)
            
        automaticallyAdjustsScrollViewInsets = false
        
        let views: [String : AnyObject] = ["containerView"  : containerView,
                                           "tabView"        : tabView,
                                           "topLayoutGuide" : topLayoutGuide]
        
        tabViewHeightConstraint = NSLayoutConstraint(item:tabView, attribute:.height, relatedBy:.equal, toItem:nil, 
                                                     attribute:.notAnAttribute, multiplier:1, constant:tabViewHeight)
        
        view.addConstraint(tabViewHeightConstraint!)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tabView]|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLayoutGuide][tabView][containerView]|", metrics: nil, views: views))
    }
    
    //MARK: - Lazy initializers
    
    func initTabView() -> WDPRTabView {
        let tabView = WDPRTabView()
        tabView.translatesAutoresizingMaskIntoConstraints = false
        return tabView
    }
    
    func initContainerView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.red
        
        return containerView
    }
    
    func animateTransition(_ newIndex: Int, newChildViewController: UIViewController) {
        prepareLayoutForAnimations(tabIndex: newIndex, newChildViewController: newChildViewController)
        
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: WDPRTabViewController.transitionAnimationDuration,
                       animations:containerView.layoutIfNeeded, completion: { [weak self] _ in
                        self?.onDidCompleteAnimation(newChildViewController, newIndex: newIndex)
            })
    }
    
    func prepareLayoutForAnimations(tabIndex: Int, newChildViewController : UIViewController) {
        let metrics = ["containerWidth" : containerView.frame.width]
        
        let views: [String : UIView] = ["newChildView" : newChildViewController.view,
                                        "oldChildView" : (selectedViewController?.view)!]
        
        let newChildAppearsFromRight = tabIndex > tabView.selectedTabIndex
        
        //remove previous constraints
        containerView.removeConstraints(containerView.constraints)
        
        newChildViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newChildViewController.view)
        
        //first we add the constraints for the views initial position
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[newChildView]|", metrics: metrics, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[oldChildView]|", metrics: metrics, views: views))
        
        let beforeHFormat = newChildAppearsFromRight ?
            "H:|[oldChildView(==containerWidth)][newChildView(==containerWidth)]" :
        "H:[newChildView(==containerWidth)][oldChildView(==containerWidth)]|"
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: beforeHFormat, metrics: metrics, views: views)
        
        //once set we remove them and add constraints for the views final position
        containerView.removeConstraints(constraints)
        
        let afterHFormat = newChildAppearsFromRight ?
            "H:[oldChildView(==containerWidth)][newChildView(==containerWidth)]|" :
        "H:|[newChildView(==containerWidth)][oldChildView(==containerWidth)]"
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: afterHFormat, metrics: metrics, views: views))
        containerView.layoutIfNeeded()
    }
    
    func addChildViewControllerToContainer(_ childViewController: UIViewController) {
        addChildViewController(childViewController)
        
        let views: [String : UIView] = ["childView" : childViewController.view]
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|", metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|", metrics: nil, views: views))
        
        childViewController.didMove(toParentViewController: self)
    }
    
    func removeChildViewControllerFromContainer(_ childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.removeFromParentViewController()
        childViewController.view.removeFromSuperview()
    }
    
    func onDidSelectTabAtIndex(_ index: NSInteger) {
        guard isViewLoaded, let childViewController = viewControllerAtIndex?(index) else {
            return
        }
        
        if selectedViewController != nil {
            animateTransition(index, newChildViewController: childViewController)
        } else {
            containerView.addSubview(childViewController.view)
            addChildViewControllerToContainer(childViewController)
            
            selectedViewController = childViewController
        }
    }
    
    func onDidCompleteAnimation(_ newChildViewController: UIViewController, newIndex:Int) {
        removeChildViewControllerFromContainer(selectedViewController!)
        
        containerView.removeConstraints(containerView.constraints)
        
        addChildViewControllerToContainer(newChildViewController)
        
        containerView.layoutIfNeeded()
        
        selectedViewController = newChildViewController
        
        view.isUserInteractionEnabled = true
    }
}
