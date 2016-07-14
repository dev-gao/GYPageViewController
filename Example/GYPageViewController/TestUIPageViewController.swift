//
//  TestUIPageViewController.swift
//  GYPageViewController
//
//  Created by GaoYu on 16/7/3.
//  Copyright © 2016年 GaoYu. All rights reserved.
//

import UIKit
import HMSegmentedControl

class TestPageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var segmentedControl:HMSegmentedControl?
    var pageTitles:Array<String>!
    var segmentHeight = 44.0
    var selectedIndex:Int = 0
    
    lazy var pageViewController:UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pvc.delegate = self
        pvc.dataSource = self
        return pvc
    }()
    
    private(set) var pageControllers:Array<UIViewController>!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pageTitles:Array<String>,pageControllers:Array<UIViewController>) {
        super.init(nibName: nil, bundle: nil)
        
        self.pageControllers = pageControllers
        assert((pageTitles.count == pageControllers.count), "title count is not equal controllers count")
        
        self.pageTitles = pageTitles
        if self.pageTitles.count > 1 {
            self.segmentedControl = HMSegmentedControl(sectionTitles: self.pageTitles)
            self.setupSegmentedControl(self.segmentedControl)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.layoutSegmentedControl(self.segmentedControl)
        
        self.addChildViewController(self.pageViewController)
        var newFrame = self.view.frame
        newFrame.size.height -= 44
        newFrame.origin.y = 108
        self.pageViewController.view.frame = newFrame
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
//        var constraints = Array<NSLayoutConstraint>()
//        let constraintAttributes = Array<NSLayoutAttribute>(arrayLiteral: .Bottom,.Leading,.Trailing)
//        
//        let topConstraint = NSLayoutConstraint(item: self.pageViewController.view,
//                                               attribute: .Top,
//                                               relatedBy: .Equal,
//                                               toItem: self.segmentedControl,
//                                               attribute: .Bottom,
//                                               multiplier: 1,
//                                               constant: 500)
//        constraints.append(topConstraint)
//        
//        for attribute in constraintAttributes {
//            let constraint = NSLayoutConstraint(item: self.pageViewController.view,
//                                                attribute: attribute,
//                                                relatedBy: .Equal,
//                                                toItem: self.view,
//                                                attribute: attribute,
//                                                multiplier: 1.0,
//                                                constant: 0)
//            constraints.append(constraint)
//        }
//        self.view.addConstraints(constraints)
    }
    
    @objc private func layoutSegmentedControl(segmentedControl:HMSegmentedControl?) {
        if let segControl = segmentedControl {
            self.view.addSubview(segControl)
            
            var constraints = Array<NSLayoutConstraint>()
            let constraintAttributes = Array<NSLayoutAttribute>(arrayLiteral:.Leading,.Trailing)
            for attribute in constraintAttributes {
                let constraint = NSLayoutConstraint(item: segControl,
                                                    attribute: attribute,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: attribute,
                                                    multiplier: 1.0,
                                                    constant: 0)
                constraints.append(constraint)
            }
            
            let topConstraint = NSLayoutConstraint(item: segControl,
                                                   attribute: .Top,
                                                   relatedBy: .Equal,
                                                   toItem: self.topLayoutGuide,
                                                   attribute: .Bottom,
                                                   multiplier: 1.0,
                                                   constant: 0)
            constraints.append(topConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: segControl,
                                                      attribute: .Height,
                                                      relatedBy: .Equal,
                                                      toItem: nil,
                                                      attribute: .NotAnAttribute,
                                                      multiplier: 0.0,
                                                      constant: CGFloat(segmentHeight))
            constraints.append(heightConstraint)
            self.view.addConstraints(constraints)
        }
    }
    
    @objc private func setupSegmentedControl(segmentedControl:HMSegmentedControl?) {
        if let segControl = segmentedControl {
            segControl.translatesAutoresizingMaskIntoConstraints = false
            segControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
            segControl.selectionIndicatorColor = UIColor(red: 0xdc/0xff, green: 0xb6/0xff, blue: 0x65/0xff, alpha: 1.0)
            segControl.selectionIndicatorHeight = 3.0
            segControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 0xdc/0xff, green: 0xb6/0xff, blue: 0x65/0xff, alpha: 1.0),NSFontAttributeName:UIFont.systemFontOfSize(22)]
            segControl.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 0x84/0xff, green: 0xb0/0xff, blue: 0xdf/0xff, alpha: 1.0),NSFontAttributeName:UIFont.systemFontOfSize(18)]
            segControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
            segControl.backgroundColor = UIColor.blueColor()
            segControl.addTarget(self, action: #selector(TestPageViewController.segmentValueChanged), forControlEvents: .ValueChanged)
        }
    }
    
    @objc private func segmentValueChanged(sender:AnyObject) {
        if let segControl = self.segmentedControl {
            self.showPageAtIndex(segControl.selectedSegmentIndex, animated: true)
        }
    }
    
    @objc func showPageAtIndex(index:Int,animated:Bool) {
        var direction:UIPageViewControllerNavigationDirection = .Reverse
        if let vcs = self.pageViewController.viewControllers {
            if let last = vcs.last {
                if let index = self.pageControllers.indexOf(last) {
                    direction = self.selectedIndex > index ? .Forward : .Reverse
                }
            }
        }
        
        self.pageViewController.setViewControllers([self.pageControllers[index]], direction: direction, animated: true) { (finished) in
            dispatch_async(dispatch_get_main_queue(), {
                self.pageViewController.setViewControllers([self.pageControllers[index]], direction: direction, animated: false) { (finished) in
                    
                }
            })
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.pageControllers.indexOf(viewController)
        if index == NSNotFound || index == 0 {
            return nil
        }
        
        index = index! - 1
        return self.pageControllers[index!]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.pageControllers.indexOf(viewController)
        if index! == NSNotFound {
            return nil
        }
        
        if index! + 1 >= self.pageControllers.count {
            return nil
        }
        
        index = index! + 1
        return self.pageControllers[index!]
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.selectedIndex = self.pageControllers.indexOf((pageViewController.viewControllers?.last)!)!
        self.segmentedControl?.setSelectedSegmentIndex(UInt(self.selectedIndex), animated: true)
    }
}