//
//  GYTabPageViewController.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/27.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

@objc protocol GYTabPageViewControllerDelegate {
    optional func pageViewDidSelectedIndex(index:Int)
}

class GYTabPageViewController: GYPageViewController {
    var segmentedControl:HMSegmentedControl?
    var pageTitles:Array<String>!
    var segmentHeight = 44.0
    
    //MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(pageTitles:Array<String>,pageControllers:Array<UIViewController>) {
        super.init(pageControllers: pageControllers)
        
        assert((pageTitles.count == pageControllers.count), "title count is not equal controllers count")
        
        self.pageTitles = pageTitles
        if self.pageTitles.count > 1 {
            self.segmentedControl = HMSegmentedControl(sectionTitles: self.pageTitles)
            self.setupSegmentedControl(self.segmentedControl)
        }
    }
    
    //MARK: - Lift Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.pageTitles.count > 1 {
            self.layoutSegmentedControl(self.segmentedControl)
        }
        
        self.resetScrollViewLayoutConstraints(self.scrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Target & Action
    @objc private func segmentValueChanged(sender:AnyObject) {
        if let segControl = self.segmentedControl {
            self.showPageAtIndex(segControl.selectedSegmentIndex, animated: true)
        }
    }
    
    //MARK: - Subviews Configuration
    @objc private func resetScrollViewLayoutConstraints(scrollView:UIScrollView) {
        scrollView.gy_removeConstraintsAffectingView()
        var constraints = Array<NSLayoutConstraint>()
        let constraintAttributes = Array<NSLayoutAttribute>(arrayLiteral: .Bottom,.Leading,.Trailing)
        
        let topConstraint = NSLayoutConstraint(item: scrollView,
                                               attribute: .Top,
                                               relatedBy: .Equal,
                                               toItem: self.segmentedControl,
                                               attribute: .Bottom,
                                               multiplier: 1,
                                               constant: 0)
        constraints.append(topConstraint)
        
        for attribute in constraintAttributes {
            let constraint = NSLayoutConstraint(item: scrollView,
                                                attribute: attribute,
                                                relatedBy: .Equal,
                                                toItem: self.view,
                                                attribute: attribute,
                                                multiplier: 1.0,
                                                constant: 0)
            constraints.append(constraint)
        }
        self.view.addConstraints(constraints)
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
            segControl.addTarget(self, action: #selector(GYTabPageViewController.segmentValueChanged), forControlEvents: .ValueChanged)
        }
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
    
    //MARK: - Override super class methods
    
    // Sent when a gesture-initiated transition ends.
    @objc override func gy_pageViewControllerDidTransitonFrom(fromIndex:Int, toIndex:Int)
    {
        super.gy_pageViewControllerDidTransitonFrom(fromIndex, toIndex: toIndex)
        self.segmentedControl?.setSelectedSegmentIndex(UInt(toIndex), animated: true)
    }
    
    // Sent after method(func showPageAtIndex(index:Int,animated:Bool)) finished.
    @objc override func gy_pageViewControllerDidShow(fromIndex:Int, toIndex:Int, finished:Bool)
    {
        super.gy_pageViewControllerDidShow(fromIndex, toIndex:toIndex, finished:finished)
        self.segmentedControl?.setSelectedSegmentIndex(UInt(toIndex), animated: true )
    }
}
