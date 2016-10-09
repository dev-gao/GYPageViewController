//
//  UIViewController+ChildController.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/29.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

extension UIViewController {
    func gy_addChildViewController(_ viewController:UIViewController) {
        self.gy_addChildViewController(viewController,frame: self.view.bounds)
    }
    
    func gy_addChildViewController(_ viewController:UIViewController,inView:UIView,withFrame:CGRect) {
        self.gy_addChildViewController(viewController) { (superViewController,childViewController) in
            childViewController.view.frame = withFrame;
            
            if inView.subviews.contains(viewController.view) == false {
                inView.addSubview(viewController.view)
            }
        }
    }
    
    func gy_addChildViewController(_ viewController:UIViewController,frame:CGRect) {
        self.gy_addChildViewController(viewController) { (superViewController,childViewController) in
            childViewController.view.frame = frame;
            
            if superViewController.view.subviews.contains(viewController.view) == false {
                superViewController.view.addSubview(viewController.view)
            }
        }
    }
    
    func gy_addChildViewController(_ viewController:UIViewController,
                                   setSubViewAction:((_ superViewController:UIViewController,_ childViewController:UIViewController) -> Void)?) {
        
        let containsVC = self.childViewControllers.contains(viewController)
        
        if containsVC == false {
            self.addChildViewController(viewController)
        }
        
        setSubViewAction?(self,viewController)
        
        if containsVC == false {
            viewController.didMove(toParentViewController: self)
        }
    }
    
    func gy_removeFromParentViewControllerOnly() {
        self.willMove(toParentViewController: nil)
        self.removeFromParentViewController()
    }
    
    func gy_removeFromParentViewController() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
