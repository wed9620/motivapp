//
//  SideBar.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 25/03/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit

class SideBar: UITableViewController {
    var selectedMenuItem : Int = 0
    let itemsMS = ["Цели", "План", "Календарь", "Цитаты"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRow(at: IndexPath(row: selectedMenuItem, section: 0), animated: false, scrollPosition: .middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return itemsMS.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.white
            let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = itemsMS[(indexPath as NSIndexPath).row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("did select row: \((indexPath as NSIndexPath).row)")
        
        if ((indexPath as NSIndexPath).row == selectedMenuItem) {
            return
        }
        
        selectedMenuItem = (indexPath as NSIndexPath).row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        var destViewController : UIViewController
        switch ((indexPath as NSIndexPath).row) {
        case 0:
            destViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC")
            break
        case 1:
            destViewController = mainStoryboard.instantiateViewController(withIdentifier: "Plan")
            break
        case 2:
            destViewController = mainStoryboard.instantiateViewController(withIdentifier: "Calendar")
            break
        case 3:
            destViewController = mainStoryboard.instantiateViewController(withIdentifier: "Citates")
            break

        default:
            destViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC")
            break
        }

        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: destViewController)
        sideMenuViewController?.contentViewController?.viewDidLoad()
        sideMenuViewController?.hideMenuViewController()
    }
}
