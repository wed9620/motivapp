//
//  CalendarVC.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 17/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import CVCalendar
import ENSwiftSideMenu

class CalendarVC: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, ENSideMenuDelegate{

    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var navItem: UINavigationItem!
    var sideMenuOpened = Bool()
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(CalendarVC.tapped))
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
        self.sideMenuController()?.sideMenu?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        navItem.title = "\(calendarView.presentedDate.commonDescription)"
    }
    
//    func sideMenuWillOpen() {
//        if sideMenuOpened == false {
//            UIView.animateWithDuration(0.5, animations: {
//                self.view.frame = CGRectMake(self.view.frame.origin.x + 200, 0 , self.view.frame.width, self.view.frame.height)
//            })
//        }
//    }
//    
//    func sideMenuWillClose() {
//        if sideMenuOpened {
//            UIView.animateWithDuration(0.5, animations: {
//                self.view.frame = CGRectMake(self.view.frame.origin.x - 200, 0 , self.view.frame.width, self.view.frame.height)
//            })
//        }
//    }
//
    func tapped() {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
//
//    func sideMenuDidOpen() {
//        sideMenuOpened = true
//    }
//    
//    func sideMenuDidClose() {
//        sideMenuOpened = false
//    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        let mainSoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : PlanVC = mainSoryboard.instantiateViewControllerWithIdentifier("Plan") as! PlanVC
        vc.dateFromSubVC = dayView.date.convertedDate()!
        navigationController?.showViewController(vc, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    @IBAction func menu(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    @IBAction func today(sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
}
