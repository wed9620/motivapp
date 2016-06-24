//
//  AddToDoThing.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 12/05/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class AddToDoThing: UIViewController, ENSideMenuDelegate {

    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var toDo: UITextView!
    var sideMenuOpened = Bool()
    var currentDay : Int!
    var currentMonth : Int!
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(AddToDoThing.tapped))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
    
    override func awakeFromNib() {
        
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
        self.sideMenuController()?.sideMenu?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func sideMenuDidOpen() {
//        sideMenuOpened = true
//    }
//    
//    func sideMenuDidClose() {
//        sideMenuOpened = false
//    }
//    
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
    
    func tapped() {
        view.endEditing(true)
    }
    
    @IBAction func add(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        if toDo.text == "" {
            let alert = UIAlertController(title: "Пусто",
                                          message: "Вы ничего не ввели",
                                          preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .Default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {

            let formaterForHour = NSDateFormatter()
            let formaterForMinute = NSDateFormatter()
            let formaterForDate = NSDateFormatter()
            formaterForDate.dateFormat = "dd.MM-HH:mm"
            formaterForHour.dateFormat = "HH"
            formaterForMinute.dateFormat = "mm"
            let timeStrHour = formaterForHour.stringFromDate(time.date)
            let timeStrMin = formaterForMinute.stringFromDate(time.date)
            
            let finalDate = formaterForDate.dateFromString("\(currentDay+1).\(currentMonth+1)-\(timeStrHour):\(timeStrMin)")
            
            print(formaterForDate.stringFromDate(finalDate!))
            
            let toDoDict: [String:String] = ["timeHour" : timeStrHour, "timeMin" : timeStrMin, "todo" : toDo.text!]
            
            let notification = UILocalNotification()
            notification.fireDate = finalDate!.dateByAddingTimeInterval(-300)
            notification.alertBody = "Через 5 минут:\(toDo.text!)"
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["CustomField1": "w00t"]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            let notification1 = UILocalNotification()
            notification1.fireDate = finalDate!
            notification1.alertBody = "\(toDo.text!)"
            notification1.soundName = UILocalNotificationDefaultSoundName
            notification1.userInfo = ["CustomField1": "w01t"]
            UIApplication.sharedApplication().scheduleLocalNotification(notification1)
            
            let planVC : PlanVC = mainStoryboard.instantiateViewControllerWithIdentifier("Plan") as! PlanVC
            planVC.currentDay = currentDay
            planVC.currenMonth = currentMonth
            planVC.dateFromSubVC = finalDate!
            planVC.addToDoThing(toDoDict)
            navigationController?.showViewController(planVC, sender: nil)
        }
    }
}
