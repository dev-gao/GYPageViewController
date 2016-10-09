//
//  ViewController.swift
//  GYPageViewController
//
//  Created by GaoYu on 16/6/12.
//  Copyright © 2016年 GaoYu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController ,GYPageViewControllerDataSource, GYPageViewControllerDelegate {
    
    @objc var pageControllers:Array<UIViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Demo"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomCell")
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath as IndexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "GYTapPageViewController"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "GYPageViewController"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "UIPageViewController"
        }
        
        cell.setSelected(false, animated: false)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var titlesArray:Array<String> = Array<String>()
            var pageControllers:Array<TestChildViewController> = Array<TestChildViewController>()
            let colorStep:CGFloat = 1/4
            for i in 0...20 {
                titlesArray.append("tab \(i)")
                let tabVc = TestChildViewController()
                tabVc.pageIndex = i
                tabVc.view.backgroundColor = UIColor(red: colorStep * CGFloat((i + 1) % 2), green: colorStep * CGFloat((i + 1)  % 3), blue: colorStep * CGFloat((i + 1)  % 5), alpha: 1)
                
                let label = UILabel(frame: CGRect(x:100,y:100,width:100,height:100))
                label.backgroundColor = UIColor.gray
                label.text = "tab \(i)"
                label.textAlignment = .center
                tabVc.view.addSubview(label)
                
                pageControllers.append(tabVc)
            }
            self.pageControllers = pageControllers
            let vc = GYTabPageViewController(pageTitles: titlesArray)
            vc.delegate = self
            vc.dataSource = self
            vc.showPageAtIndex(2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            
        } else if indexPath.row == 2 {
            var titlesArray:Array<String> = Array<String>()
            var pageControllers:Array<TestChildViewController> = Array<TestChildViewController>()
            let colorStep:CGFloat = 1/4
            for i in 0...20 {
                titlesArray.append("tab \(i)")
                let tabVc = TestChildViewController()
                tabVc.pageIndex = i
                tabVc.view.backgroundColor = UIColor(red: colorStep * CGFloat((i + 1) % 2), green: colorStep * CGFloat((i + 1)  % 3), blue: colorStep * CGFloat((i + 1)  % 5), alpha: 1)
                
                let label = UILabel(frame: CGRect(x:100,y:100,width:100,height:100))
                label.backgroundColor = UIColor.gray
                label.text = "tab \(i)"
                label.textAlignment = .center
                tabVc.view.addSubview(label)
                
                pageControllers.append(tabVc)
            }
            self.pageControllers = pageControllers
            let vc = TestPageViewController(pageTitles: titlesArray, pageControllers: pageControllers)
            vc.showPageAtIndex(index: 2, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - GYPageViewControllerDataSource & GYPageViewControllerDelegate
    @objc func gy_pageViewController(_: GYPageViewController, controllerAtIndex index: Int) -> UIViewController! {
        return self.pageControllers[index]
    }
    
    @objc func numberOfControllers(_: GYPageViewController) -> Int {
        return self.pageControllers.count
    }
    
}

