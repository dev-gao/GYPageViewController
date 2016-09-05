//
//  TestChildViewController.swift
//  GYPageViewController
//
//  Created by GaoYu on 16/6/12.
//  Copyright © 2016年 GaoYu. All rights reserved.
//

import UIKit

class TestChildViewController: UIViewController {

    var pageIndex = 0
    
    //MARK: - Life cycles
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.5
    }
    
    @objc override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        print("Will Appear :    \(pageIndex)")
    }
    
    @objc override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("Did Appear :    \(pageIndex)")
    }
    
    @objc override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Will Disappear :    \(pageIndex)")
    }
    
    @objc override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("Did Disappear :    \(pageIndex)")
    }

}
