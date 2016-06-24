//
//  SideBarNav.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 26/03/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class SideBarNav: ENSideMenuNavigationController, ENSideMenuDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: SideBar(), menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 204.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
        //sideMenu?.animationDuration = 0.5
        //sideMenu?.allowPanGesture = false
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggled() -> Void {
        toggleSideMenuView()
    }
}
