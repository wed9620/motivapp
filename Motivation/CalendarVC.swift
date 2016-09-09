//
//  CalendarVC.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 17/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarVC: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        navItem.title = "\(calendarView.presentedDate.commonDescription)"
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
            let mainSoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : PlanVC = mainSoryboard.instantiateViewControllerWithIdentifier("Plan") as! PlanVC
            vc.dateFromSubVC = dayView.date.convertedDate()!
            navigationController?.showViewController(vc, sender: nil)
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
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
        
        sideMenuViewController?._presentLeftMenuViewController()
    }
    
    @IBAction func today(sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
}
