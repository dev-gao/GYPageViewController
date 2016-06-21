//
//  UIViewController+ChildController.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/29.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

extension UIViewController {
    func gy_addChildViewController(viewController:UIViewController) {
        self.gy_addChildViewController(viewController,frame: self.view.bounds)
    }
    
    func gy_addChildViewController(viewController:UIViewController,inView:UIView,withFrame:CGRect) {
        self.gy_addChildViewController(viewController) { (superViewController,childViewController) in
            childViewController.view.frame = withFrame;
            
            if inView.subviews.contains(viewController.view) == false {
                inView.addSubview(viewController.view)
            }
        }
    }
    
    func gy_addChildViewController(viewController:UIViewController,frame:CGRect) {
        self.gy_addChildViewController(viewController) { (superViewController,childViewController) in
            childViewController.view.frame = frame;
            
            if superViewController.view.subviews.contains(viewController.view) == false {
                superViewController.view.addSubview(viewController.view)
            }
        }
    }

    func gy_addChildViewController(viewController:UIViewController,
                                   setSubViewAction:((superViewController:UIViewController,childViewController:UIViewController) -> Void)?) {
        if self.childViewControllers.contains(viewController) == false {
            self.addChildViewController(viewController)
        }
        
        setSubViewAction?(superViewController:self,childViewController: viewController)
        
        if self.childViewControllers.contains(viewController) == false {
            viewController.didMoveToParentViewController(self)
        }
    }
    
    func gy_removeFromParentViewControllerOnly() {
        self.willMoveToParentViewController(nil)
        self.removeFromParentViewController()
    }
    
    func gy_removeFromParentViewController() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
