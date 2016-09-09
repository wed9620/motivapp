//
//  AddToDoThing.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 12/05/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit

class AddToDoThing: UIViewController, UITextViewDelegate {

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
        
        toDo.text = "Введите описание"
        toDo.textColor = UIColor.lightGrayColor()
 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddToDoThing.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddToDoThing.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите описание"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    override func awakeFromNib() {
        
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
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
        } else if toDo.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 200 {
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Введено недопустимое число символов",
                                          preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .Default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)

        }
        else {

            let formaterForHour = NSDateFormatter()
            let formaterForMinute = NSDateFormatter()
            let formaterForDate = NSDateFormatter()
            let formaterYear = NSDateFormatter()
            let year = NSDate()
            formaterYear.dateFormat = "yyyy"
            formaterForDate.dateFormat = "dd.MM.yyyy-HH:mm"
            formaterForHour.dateFormat = "HH"
            formaterForMinute.dateFormat = "mm"
            let timeStrHour = formaterForHour.stringFromDate(time.date)
            let timeStrMin = formaterForMinute.stringFromDate(time.date)
            let yearStr = formaterYear.stringFromDate(year)
            
            let finalDate = formaterForDate.dateFromString("\(currentDay+1).\(currentMonth+1).\(yearStr)-\(timeStrHour):\(timeStrMin)")
            
            print("date:::::::::>>>>>", formaterForDate.stringFromDate(finalDate!))
            
            let toDoDict: [String:String] = ["timeHour" : timeStrHour, "timeMin" : timeStrMin, "todo" : toDo.text!]
            
            let notification = UILocalNotification()
            notification.timeZone = NSTimeZone.systemTimeZone()
            notification.fireDate = finalDate!.dateByAddingTimeInterval(-300)
            notification.alertBody = "Через 5 минут:\(toDo.text!)"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            let notification1 = UILocalNotification()
            notification1.timeZone = NSTimeZone.systemTimeZone()
            notification1.fireDate = finalDate!
            notification1.alertBody = "\(toDo.text!)"
            notification1.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification1)
            
            let planVC : PlanVC = mainStoryboard.instantiateViewControllerWithIdentifier("Plan") as! PlanVC
            planVC.currentDay = currentDay
            planVC.currenMonth = currentMonth
            planVC.addToDoThing(toDoDict)
            navigationController?.pushViewController(planVC, animated: true)
        }
    }
}
