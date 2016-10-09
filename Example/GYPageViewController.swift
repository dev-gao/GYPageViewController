//
//  GYPageViewController.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/27.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


enum GYPageScrollDirection {
    case left
    case right
}

@objc protocol GYPageViewControllerDataSource {
    func gy_pageViewController(_:GYPageViewController,
                               controllerAtIndex index:Int) -> UIViewController!
    
    func numberOfControllers(_:GYPageViewController) -> Int
}

@objc protocol GYPageViewControllerDelegate {
    
    // Sent when a gesture-initiated transition begins.
    @objc optional func gy_pageViewController(_ pageViewController: GYPageViewController,
                                              willTransitonFrom fromVC:UIViewController,
                                              toViewController toVC:UIViewController)
    
    // Sent when a gesture-initiated transition ends.
    @objc optional func gy_pageViewController(_ pageViewController: GYPageViewController,
                                              didTransitonFrom fromVC:UIViewController,
                                              toViewController toVC:UIViewController)
    
    
    // Sent when method(func showPageAtIndex(index:Int,animated:Bool)) begin to be called.
    @objc optional func gy_pageViewController(_ pageViewController: GYPageViewController,
                                              willLeaveViewController fromVC:UIViewController,
                                              toViewController toVC:UIViewController,
                                              animated:Bool)
    
    // Sent after method(func showPageAtIndex(index:Int,animated:Bool)) finished.
    @objc optional func gy_pageViewController(_ pageViewController: GYPageViewController,
                                              didLeaveViewController fromVC:UIViewController,
                                              toViewController toVC:UIViewController,
                                              finished:Bool)
}

class GYPageViewController: UIViewController, UIScrollViewDelegate, NSCacheDelegate {
    weak var delegate:GYPageViewControllerDelegate?
    weak var dataSource:GYPageViewControllerDataSource?
    
    fileprivate(set) var scrollView:UIScrollView! = UIScrollView()
    var pageCount:Int {
        get {
            return self.dataSource!.numberOfControllers(self)
        }
    }
    fileprivate(set) var currentPageIndex = 0
    var contentEdgeInsets = UIEdgeInsets.zero
    fileprivate lazy var memCache:NSCache<NSNumber, UIViewController> = {
        let cache = NSCache<NSNumber, UIViewController>()
        cache.countLimit = 3
        return cache
    }()
    
    var cacheLimit:Int {
        get {
            return self.memCache.countLimit
        }
        set {
            self.memCache.countLimit = newValue;
        }
    }
    
    fileprivate var childsToClean = Set<UIViewController>()
    
    fileprivate var originOffset = 0.0                  //用于手势拖动scrollView时，判断方向
    fileprivate var guessToIndex = -1                   //用于手势拖动scrollView时，判断要去的页面
    fileprivate var lastSelectedIndex = 0               //用于记录上次选择的index
    fileprivate var firstWillAppear = true              //用于界定页面首次WillAppear。
    fileprivate var firstDidAppear = true               //用于界定页面首次DidAppear。
    fileprivate var firstDidLayoutSubViews = true       //用于界定页面首次DidLayoutsubviews。
    fileprivate var firstWillLayoutSubViews = true      //用于界定页面首次WillLayoutsubviews。
    fileprivate var isDecelerating = false              //正在减速操作
    
    //MARK: - Lift Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.memCache.delegate = self
        
        self.configScrollView(self.scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.firstWillAppear {
            //Config init page
            self.gy_pageViewControllerWillShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, animated: false)
            self.delegate?.gy_pageViewController?(self, willLeaveViewController: self.controllerAtIndex(self.lastSelectedIndex), toViewController: self.controllerAtIndex(self.currentPageIndex), animated: false)
            //            print("viewWillAppear beginAppearanceTransition  self.currentPageIndex  \(self.currentPageIndex)")
            self.firstWillAppear = false
        }
        self.controllerAtIndex(self.currentPageIndex).beginAppearanceTransition(true, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.firstDidLayoutSubViews {
            //Solve scrollView bug: can scroll to negative offset when pushing a UIViewController containing a UIScrollView using a UINavigationController.
            if let navigationController = self.navigationController {
                if navigationController.viewControllers[navigationController.viewControllers.count - 1] == self{
                    self.scrollView.contentOffset = CGPoint.zero;
                    self.scrollView.contentInset = UIEdgeInsets.zero;
                }
            }
            
            // Solve iOS7 crash: scrollView setContentOffset will trigger layout subviews methods. Use GCD dispatch_after to update scrollView contentOffset.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.0 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.updateScrollViewLayoutIfNeeded()
                self.updateScrollViewDisplayIndexIfNeeded()
            })
            self.firstDidLayoutSubViews = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.0 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.updateScrollViewLayoutIfNeeded()
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstDidAppear {
            //            print("viewDidAppear endAppearanceTransition  self.currentPageIndex  \(self.currentPageIndex)")
            //Config init page did appear
            self.gy_pageViewControllerDidShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, finished: true)
            self.delegate?.gy_pageViewController?(self, didLeaveViewController: self.controllerAtIndex(self.lastSelectedIndex), toViewController: self.controllerAtIndex(self.currentPageIndex), finished: true)
            
            self.firstDidAppear = false
        }
        self.controllerAtIndex(self.currentPageIndex).endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.controllerAtIndex(self.currentPageIndex).beginAppearanceTransition(false, animated: true)
        //        print("viewWillDisappear beginAppearanceTransition  self.currentPageIndex  \(self.currentPageIndex)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.controllerAtIndex(self.currentPageIndex).endAppearanceTransition()
        //        print("viewDidDisappear endAppearanceTransition  self.currentPageIndex  \(self.currentPageIndex)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.memCache.removeAllObjects()
    }
    
    //MARK: - Update controllers & views
    
    /**
     Change index through tabbar or mannually invoking
     
     Simulate an scroll animation instead of scroll view setContentOffset animation.
     Because of the scroll native animation during two not neighbouring views is an unelegant, scroll view will tour all the views between the source index and destination index.
     
     The simulated animation will bring source view and dest view to front and scroll the two view like neighbouring views.After animation move them back to origin index.
     
     - parameter index:    change to index
     - parameter animated: animation bool. true to animate, false not animate
     */
    @objc func showPageAtIndex(_ index:Int,animated:Bool) {
        if index < 0 || index >= self.pageCount {
            return
        }
        
        // Synchronize the indexs and store old select index
        let oldSelectedIndex = self.lastSelectedIndex
        self.lastSelectedIndex = self.currentPageIndex
        self.currentPageIndex = index
        
        // Prepare to scroll if scrollView is initialized and displayed correctly
        if self.scrollView.frame.size.width > 0.0 &&
            self.scrollView.contentSize.width > 0.0{
            
            self.gy_pageViewControllerWillShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, animated: animated)
            self.delegate?.gy_pageViewController?(self, willLeaveViewController: self.controllerAtIndex(self.lastSelectedIndex),
                                                  toViewController: self.controllerAtIndex(self.currentPageIndex), animated: animated)
            
            self.addVisibleViewContorllerWith(index)
        }
        
        // Scroll to current index if scrollView is initialized and displayed correctly
        if self.scrollView.frame.size.width > 0.0 &&
            self.scrollView.contentSize.width > 0.0{
            
            // Aciton closure before simulated scroll animation
            let scrollBeginAnimation = { () -> Void in
                self.controllerAtIndex(self.currentPageIndex).beginAppearanceTransition(true, animated: animated)
                if self.currentPageIndex != self.lastSelectedIndex {
                    self.controllerAtIndex(self.lastSelectedIndex).beginAppearanceTransition(false, animated: animated)
                }
            }
            
            /* Scroll closure invoke setContentOffset with animation false. Because the scroll animation is customed.
             *
             * Simulate scroll animation among oldSelectView, lastView and currentView.
             * After simulated animation the scrollAnimation closure is invoked
             */
            let scrollAnimation = { () -> Void in
                self.scrollView.setContentOffset(self.calcOffsetWithIndex(
                    self.currentPageIndex,
                    width:Float(self.scrollView.frame.size.width),
                    maxWidth:Float(self.scrollView.contentSize.width)), animated: false)
            }
            
            // Action closure after simulated scroll animation
            let scrollEndAnimation = { () -> Void in
                self.controllerAtIndex(self.currentPageIndex).endAppearanceTransition()
                if self.currentPageIndex != self.lastSelectedIndex {
                    self.controllerAtIndex(self.lastSelectedIndex).endAppearanceTransition()
                }
                
                self.gy_pageViewControllerDidShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, finished: animated)
                self.delegate?.gy_pageViewController?(self, didLeaveViewController: self.controllerAtIndex(self.lastSelectedIndex),
                                                      toViewController: self.controllerAtIndex(self.currentPageIndex),
                                                      finished:animated)
                self.cleanCacheToClean()
            }
            
            scrollBeginAnimation()
            
            if animated {
                if self.lastSelectedIndex != self.currentPageIndex {
                    // Define variables
                    let pageSize = self.scrollView.frame.size
                    let direction = (self.lastSelectedIndex < self.currentPageIndex) ? GYPageScrollDirection.right : GYPageScrollDirection.left
                    let lastView:UIView = self.controllerAtIndex(self.lastSelectedIndex).view
                    let currentView:UIView = self.controllerAtIndex(self.currentPageIndex).view
                    let oldSelectView:UIView = self.controllerAtIndex(oldSelectedIndex).view
                    let duration = 0.3
                    let backgroundIndex = self.calcIndexWithOffset(Float(self.scrollView.contentOffset.x),
                                                                   width: Float(self.scrollView.frame.size.width))
                    var backgroundView:UIView?
                    
                    /*
                     *  To solve the problem: when multiple animations were fired, there is an extra unuseful view appeared under the scrollview's two subviews(used to simulate animation: lastView, currentView).
                     *
                     *  Hide the extra view, and after the animation is finished set its hidden property false.
                     */
                    if oldSelectView.layer.animationKeys()?.count > 0 &&
                        lastView.layer.animationKeys()?.count > 0
                    {
                        let tmpView = self.controllerAtIndex(backgroundIndex).view
                        if tmpView != currentView &&
                            tmpView != lastView
                        {
                            backgroundView = tmpView
                            backgroundView?.isHidden = true
                        }
                    }
                    
                    // Cancel animations is not completed when multiple animations are fired
                    self.scrollView.layer.removeAllAnimations()
                    oldSelectView.layer.removeAllAnimations()
                    lastView.layer.removeAllAnimations()
                    currentView.layer.removeAllAnimations()
                    
                    // oldSelectView is not useful for simulating animation, move it to origin position.
                    self.moveBackToOriginPositionIfNeeded(oldSelectView, index: oldSelectedIndex)
                    
                    // Bring the views for simulating scroll animation to front and make them visible
                    self.scrollView.bringSubview(toFront: lastView)
                    self.scrollView.bringSubview(toFront: currentView)
                    lastView.isHidden = false
                    currentView.isHidden = false
                    
                    // Calculate start positions , animate to positions , end positions for simulating animation views(lastView, currentView)
                    let lastView_StartOrigin = lastView.frame.origin
                    var currentView_StartOrigin = lastView.frame.origin
                    if direction == .right {
                        currentView_StartOrigin.x += self.scrollView.frame.size.width
                    } else {
                        currentView_StartOrigin.x -= self.scrollView.frame.size.width
                    }
                    
                    var lastView_AnimateToOrigin = lastView.frame.origin
                    if direction == .right {
                        lastView_AnimateToOrigin.x -= self.scrollView.frame.size.width
                    } else {
                        lastView_AnimateToOrigin.x += self.scrollView.frame.size.width
                    }
                    let currentView_AnimateToOrigin = lastView.frame.origin
                    
                    let lastView_EndOrigin = lastView.frame.origin
                    let currentView_EndOrigin = currentView.frame.origin
                    
                    /*
                     *  Simulate scroll animation
                     *  Bring two views(lastView, currentView) to front and simulate scroll in neighbouring position.
                     */
                    lastView.frame = CGRect(x: lastView_StartOrigin.x, y: lastView_StartOrigin.y, width: pageSize.width, height: pageSize.height)
                    currentView.frame = CGRect(x: currentView_StartOrigin.x, y: currentView_StartOrigin.y, width: pageSize.width, height: pageSize.height)
                    
                    UIView.animate(withDuration: duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations:
                        {
                            lastView.frame = CGRect(x: lastView_AnimateToOrigin.x, y: lastView_AnimateToOrigin.y, width: pageSize.width, height: pageSize.height)
                            currentView.frame = CGRect(x: currentView_AnimateToOrigin.x, y: currentView_AnimateToOrigin.y, width: pageSize.width, height: pageSize.height)
                        },
                                   completion:
                        { [weak self] (finished) in
                            if finished {
                                lastView.frame = CGRect(x: lastView_EndOrigin.x, y: lastView_EndOrigin.y, width: pageSize.width, height: pageSize.height)
                                currentView.frame = CGRect(x: currentView_EndOrigin.x, y: currentView_EndOrigin.y, width: pageSize.width, height: pageSize.height)
                                backgroundView?.isHidden = false
                                if let weakSelf = self {
                                    weakSelf.moveBackToOriginPositionIfNeeded(currentView, index: weakSelf.currentPageIndex)
                                    weakSelf.moveBackToOriginPositionIfNeeded(lastView, index: weakSelf.lastSelectedIndex)
                                }
                                scrollAnimation()
                                scrollEndAnimation()
                            }
                        }
                    )
                } else {
                    // Scroll without animation if current page is the same with last page
                    scrollAnimation()
                    scrollEndAnimation()
                }
            } else {
                // Scroll without animation if animated is false
                scrollAnimation()
                scrollEndAnimation()
            }
        }
    }
    
    @objc fileprivate func moveBackToOriginPositionIfNeeded(_ view:UIView?,index:Int)
    {
        if index < 0 || index >= self.pageCount {
            return
        }
        
        guard let destView = view else { print("moveBackToOriginPositionIfNeeded view nil"); return;}
        
        
        let originPosition = self.calcOffsetWithIndex(index,
                                                      width: Float(self.scrollView.frame.size.width),
                                                      maxWidth: Float(self.scrollView.contentSize.width))
        if destView.frame.origin.x != originPosition.x {
            var newFrame = destView.frame
            newFrame.origin = originPosition
            destView.frame = newFrame
        }
    }
    
    @objc fileprivate func calcVisibleViewControllerFrameWith(_ index:Int) -> CGRect {
        var offsetX = 0.0
        offsetX = Double(index) * Double(self.scrollView.frame.size.width)
        return CGRect(x: CGFloat(offsetX), y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
    }
    
    @objc fileprivate func addVisibleViewContorllerWith(_ index:Int) {
        if index < 0 || index > self.pageCount {
            return
        }
        
        var vc:UIViewController? = self.memCache.object(forKey: NSNumber(value: index))
        if vc == nil {
            vc = self.controllerAtIndex(index)
        }
        
        let childViewFrame = self.calcVisibleViewControllerFrameWith(index)
        self.gy_addChildViewController(vc!,
                                       inView: self.scrollView,
                                       withFrame: childViewFrame)
        //        print("------------------------t1- add \(index)")
        self.memCache.setObject(self.controllerAtIndex(index), forKey: NSNumber(value: index))
        
        //        print("------------------------t2- add \(index)")
    }
    
    @objc fileprivate func updateScrollViewDisplayIndexIfNeeded() {
        if self.scrollView.frame.size.width > 0.0 {
            self.addVisibleViewContorllerWith(self.currentPageIndex)
            let newOffset = self.calcOffsetWithIndex(
                self.currentPageIndex,
                width:Float(self.scrollView.frame.size.width),
                maxWidth:Float(self.scrollView.contentSize.width))
            
            if newOffset.x != self.scrollView.contentOffset.x ||
                newOffset.y != self.scrollView.contentOffset.y
            {
                self.scrollView.contentOffset = newOffset
            }
            self.controllerAtIndex(self.currentPageIndex).view.frame = self.calcVisibleViewControllerFrameWith(self.currentPageIndex)
        }
    }
    
    // Do not use it in viewDidLayoutSubviews on ios 7 device.
    @objc fileprivate func updateScrollViewLayoutIfNeeded() {
        if self.scrollView.frame.size.width > 0.0 {
            let width = CGFloat(self.pageCount) * self.scrollView.frame.size.width
            let height = self.scrollView.frame.size.height
            let oldContentSize = self.scrollView.contentSize
            if width != oldContentSize.width ||
                height != oldContentSize.height
            {
                self.scrollView.contentSize = CGSize(width: width, height: height)
            }
        }
    }
    
    //MARK: - Helper methods
    @objc fileprivate func calcOffsetWithIndex(_ index:Int,width:Float,maxWidth:Float) -> CGPoint {
        var offsetX = Float(Float(index) * width)
        
        if offsetX < 0 {
            offsetX = 0
        }
        
        if maxWidth > 0.0 &&
            offsetX > maxWidth - width
        {
            offsetX = maxWidth - width
        }
        
        return CGPoint(x: CGFloat(offsetX),y: 0)
    }
    
    @objc fileprivate func calcIndexWithOffset(_ offset:Float,width:Float) -> Int {
        var startIndex = Int(offset/width)
        
        if startIndex < 0 {
            startIndex = 0
        }
        
        return startIndex
    }
    
    @objc fileprivate func controllerAtIndex(_ index:NSInteger) -> UIViewController
    {
        return self.dataSource!.gy_pageViewController(self, controllerAtIndex:index);
    }
    
    @objc fileprivate func cleanCacheToClean() {
        let currentPage = self.controllerAtIndex(self.currentPageIndex)
        if self.childsToClean.contains(currentPage) {
            if let removeIndex = self.childsToClean.index(of: currentPage) {
                self.childsToClean.remove(at: removeIndex)
                self.memCache.setObject(currentPage, forKey: NSNumber(value: self.currentPageIndex))
            }
        }
        
        for vc in self.childsToClean {
            //            print("-21-  clean cache index \((vc as! TestChildViewController).pageIndex)")
            vc.gy_removeFromParentViewController()
        }
        self.childsToClean.removeAll()
        
        //        print("-31- remain111 ==============================>")
        //        for vcc in self.childViewControllers {
        //            print("remain \((vcc as! TestChildViewController).pageIndex)")
        //        }
        //        print("-31- remain111 ==============================>")
    }
    
    //MARK: - Subviews Configuration
    @objc fileprivate func configScrollView(_ scrollView:UIScrollView) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.scrollsToTop = false
        
        self.view.addSubview(scrollView)
        
        var constraints = Array<NSLayoutConstraint>()
        let constraintAttributesDic:Dictionary<NSLayoutAttribute,CGFloat> = [.leading:self.contentEdgeInsets.left,
                                                                             .trailing:self.contentEdgeInsets.right]
        
        for attribute in constraintAttributesDic.keys {
            let constraint = NSLayoutConstraint(item: scrollView,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: self.view,
                                                attribute: attribute,
                                                multiplier: 1.0,
                                                constant: constraintAttributesDic[attribute] ?? 0 )
            constraints.append(constraint)
        }
        
        let topConstraint = NSLayoutConstraint(item: scrollView,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self.topLayoutGuide,
                                               attribute: .bottom,
                                               multiplier: 1.0,
                                               constant: self.contentEdgeInsets.top)
        constraints.append(topConstraint)
        
        let bottomConstraint = NSLayoutConstraint(item: scrollView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self.bottomLayoutGuide,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: self.contentEdgeInsets.bottom)
        constraints.append(bottomConstraint)
        
        self.view.addConstraints(constraints)
    }
    
    //MARK: - NSCacheDelegate
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if (obj as AnyObject).isKind(of: UIViewController.self) {
            let vc = obj as! UIViewController
            //            print("-1- to remove from cache \((vc as! TestChildViewController).pageIndex)")
            if self.childViewControllers.contains(vc) {
                //                print("============================tracking \(scrollView.tracking)  dragging \(scrollView.dragging) decelerating \(scrollView.decelerating)")
                
                let AddCacheToCleanIfNeed = { (midIndex:Int) -> Void in
                    //Modify memCache through showPageAtIndex.
                    var leftIndex = midIndex - 1;
                    var rightIndex = midIndex + 1;
                    if leftIndex < 0 {
                        leftIndex = midIndex
                    }
                    if rightIndex > self.pageCount - 1 {
                        rightIndex = midIndex
                    }
                    
                    let leftNeighbour = self.dataSource!.gy_pageViewController(self, controllerAtIndex: leftIndex)
                    let midPage = self.dataSource!.gy_pageViewController(self, controllerAtIndex: midIndex)
                    let rightNeighbour = self.dataSource!.gy_pageViewController(self, controllerAtIndex: rightIndex)
                    
                    if leftNeighbour == vc || rightNeighbour == vc || midPage == vc
                    {
                        self.childsToClean.insert(vc)
                    }
                }
                
                // When scrollView's dragging, tracking and decelerating are all false.At least it means the cache eviction is not triggered by continuous interaction page changing.
                if self.scrollView.isDragging == false &&
                    self.scrollView.isTracking == false &&
                    self.scrollView.isDecelerating == false
                {
                    let lastPage = self.controllerAtIndex(self.lastSelectedIndex)
                    let currentPage = self.controllerAtIndex(self.currentPageIndex)
                    if lastPage == vc || currentPage == vc {
                        self.childsToClean.insert(vc)
                    }
                    //                    print("self.currentPageIndex  \(self.currentPageIndex)")
                } else if self.scrollView.isDragging == true
                {
                    AddCacheToCleanIfNeed(self.guessToIndex)
                    //                    print("self.guessToIndex  \(self.guessToIndex)")
                }
                
                if self.childsToClean.count > 0 {
                    return
                }
                
                //                print("-2- remove index : \((vc as! TestChildViewController).pageIndex)")
                vc.gy_removeFromParentViewController()
                //                print("-3- remain ==============================>")
                //                for vcc in self.childViewControllers {
                //                    print("remain \((vcc as! TestChildViewController).pageIndex)")
                //                }
                //                print("-3- remain ==============================>")
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    // any offset changes
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print("tracking \(scrollView.tracking)  dragging \(scrollView.dragging) decelerating \(scrollView.decelerating)")
        if scrollView.isTracking == true &&
            scrollView.isDecelerating == true
        {
            //            print("     guessToIndex  \(guessToIndex)   self.currentPageIndex  \(self.currentPageIndex)")
        }
        
        if scrollView.isDragging == true && scrollView == self.scrollView {
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.width
            let lastGuessIndex = self.guessToIndex < 0 ? self.currentPageIndex : self.guessToIndex
            if self.originOffset < Double(offset) {
                self.guessToIndex = Int(ceil((offset)/width))
            } else if (self.originOffset > Double(offset)) {
                self.guessToIndex = Int(floor((offset)/width))
            } else {}
            let maxCount = self.pageCount
            
            
            // 1.Decelerating is false when first drag during discontinuous interaction.
            // 2.Decelerating is true when drag during continuous interaction.
            if (guessToIndex != self.currentPageIndex &&
                self.scrollView.isDecelerating == false) ||
                self.scrollView.isDecelerating == true
            {
                if lastGuessIndex != self.guessToIndex &&
                    self.guessToIndex >= 0 &&
                    self.guessToIndex < maxCount
                {
                    self.gy_pageViewControllerWillShow(self.guessToIndex, toIndex: self.currentPageIndex, animated: true)
                    self.delegate?.gy_pageViewController?(self, willTransitonFrom: self.controllerAtIndex(self.guessToIndex),
                                                          toViewController: self.controllerAtIndex(self.currentPageIndex))
                    
                    self.addVisibleViewContorllerWith(self.guessToIndex)
                    self.controllerAtIndex(self.guessToIndex).beginAppearanceTransition(true, animated: true)
                    //                print("scrollViewDidScroll beginAppearanceTransition  self.guessToIndex  \(self.guessToIndex)")
                    /**
                     *  Solve problem: When scroll with interaction, scroll page from one direction to the other for more than one time, the beginAppearanceTransition() method will invoke more than once but only one time endAppearanceTransition() invoked, so that the life cycle methods not correct.
                     *  When lastGuessIndex = self.currentPageIndex is the first time which need to invoke beginAppearanceTransition().
                     */
                    if lastGuessIndex == self.currentPageIndex {
                        self.controllerAtIndex(self.currentPageIndex).beginAppearanceTransition(false, animated: true)
                        //                    print("scrollViewDidScroll beginAppearanceTransition  self.currentPageIndex \(self.currentPageIndex)")
                    }
                    
                    if lastGuessIndex != self.currentPageIndex &&
                        lastGuessIndex >= 0 &&
                        lastGuessIndex < maxCount{
                        self.controllerAtIndex(lastGuessIndex).beginAppearanceTransition(false, animated: true)
                        //                    print("scrollViewDidScroll beginAppearanceTransition  lastGuessIndex \(lastGuessIndex)")
                        self.controllerAtIndex(lastGuessIndex).endAppearanceTransition()
                        //                    print("scrollViewDidScroll endAppearanceTransition  lastGuessIndex \(lastGuessIndex)")
                    }
                }
            }
        }
        //        print("====  DidScroll dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
    }
    
    // called on finger up as we are moving
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //        print("====  BeginDecelerating dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
        self.isDecelerating = true
    }
    
    // called when scroll view grinds to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newIndex = self.calcIndexWithOffset(Float(scrollView.contentOffset.x),
                                                width: Float(scrollView.frame.size.width))
        let oldIndex = self.currentPageIndex
        self.currentPageIndex = newIndex
        
        if newIndex == oldIndex {//最终确定的位置与开始位置相同时，需要重新显示开始位置的视图，以及消失最近一次猜测的位置的视图。
            if self.guessToIndex >= 0 && self.guessToIndex < self.pageCount {
                self.controllerAtIndex(oldIndex).beginAppearanceTransition(true, animated: true)
                //                print("EndDecelerating same beginAppearanceTransition  oldIndex  \(oldIndex)")
                self.controllerAtIndex(oldIndex).endAppearanceTransition()
                //                print("EndDecelerating same endAppearanceTransition  oldIndex  \(oldIndex)")
                self.controllerAtIndex(self.guessToIndex).beginAppearanceTransition(false, animated: true)
                //                print("EndDecelerating same beginAppearanceTransition  self.guessToIndex  \(self.guessToIndex)")
                self.controllerAtIndex(self.guessToIndex).endAppearanceTransition()
                //                print("EndDecelerating same endAppearanceTransition  self.guessToIndex  \(self.guessToIndex)")
            }
        } else {
            self.controllerAtIndex(newIndex).endAppearanceTransition()
            //            print("EndDecelerating endAppearanceTransition  newIndex  \(newIndex)")
            self.controllerAtIndex(oldIndex).endAppearanceTransition()
            //            print("EndDecelerating endAppearanceTransition  oldIndex  \(oldIndex)")
        }
        
        //归位，用于计算比较
        self.originOffset = Double(scrollView.contentOffset.x)
        self.guessToIndex = self.currentPageIndex
        
        self.gy_pageViewControllerDidShow(self.guessToIndex, toIndex: self.currentPageIndex, finished:true)
        self.delegate?.gy_pageViewController?(self, didTransitonFrom: self.controllerAtIndex(self.guessToIndex),
                                              toViewController: self.controllerAtIndex(self.currentPageIndex))
        //        print("====  DidEndDecelerating  dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
        self.isDecelerating = false
        
        self.cleanCacheToClean()
    }
    
    // called on start of dragging (may require some time and or distance to move)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating == false {
            self.originOffset = Double(scrollView.contentOffset.x)
            self.guessToIndex = self.currentPageIndex
        }
        //        print("====  WillBeginDragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //                print("====  WillEndDragging: \(velocity)  targetContentOffset: \(targetContentOffset.memory)  dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)  velocity  \(velocity)")
        
        if scrollView.isDecelerating == true {
            // Update originOffset for calculating new guessIndex to add controller.
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.width
            if velocity.x > 0 { // to right page
                self.originOffset = Double(floor(offset/width)) * Double(width)
            } else if velocity.x < 0 {// to left page
                self.originOffset = Double(ceil(offset/width)) * Double(width)
            }
        }
    }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        print("====  DidEndDragging: \(decelerate)  dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
    }
    
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //        print("====  DidEndScrollingAnimation: dragging:  \(scrollView.dragging)  decelorating: \(scrollView.decelerating)  offset:\(scrollView.contentOffset)")
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    //MARK: - Method to be override in subclass
    
    // Sent when a gesture-initiated transition begins.
    func gy_pageViewControllerWillTransitonFrom(_ fromIndex:Int, toIndex:Int) { }
    
    // Sent when a gesture-initiated transition ends.
    func gy_pageViewControllerDidTransitonFrom(_ fromIndex:Int, toIndex:Int) { }
    
    // Sent when method(func showPageAtIndex(index:Int,animated:Bool)) begin to be called.
    func gy_pageViewControllerWillShow(_ fromIndex:Int, toIndex:Int, animated:Bool) { }
    
    // Sent after method(func showPageAtIndex(index:Int,animated:Bool)) finished.
    func gy_pageViewControllerDidShow(_ fromIndex:Int, toIndex:Int, finished:Bool) { }
}
