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
    
    override func viewDidAppear(_ animated: Bool) {
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        navItem.title = "\(calendarView.presentedDate.commonDescription)"
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        let mainSoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : PlanVC = mainSoryboard.instantiateViewController(withIdentifier: "Plan") as! PlanVC
        vc.dateFromSubVC = dayView.date.convertedDate()!
        
        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    @IBAction func menu(_ sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }
    
    @IBAction func today(_ sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
}
