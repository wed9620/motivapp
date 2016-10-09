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
        toDo.textColor = UIColor.lightGray
 
        NotificationCenter.default.addObserver(self, selector: #selector(AddToDoThing.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddToDoThing.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите описание"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    override func awakeFromNib() {
        
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
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
    
    @IBAction func add(_ sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        if toDo.text == "" {
            let alert = UIAlertController(title: "Пусто",
                                          message: "Вы ничего не ввели",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else if toDo.text.lengthOfBytes(using: String.Encoding.utf8) > 200 {
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Введено недопустимое число символов",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)

        }
        else {

            let formaterForHour = DateFormatter()
            let formaterForMinute = DateFormatter()
            let formaterForDate = DateFormatter()
            let formaterYear = DateFormatter()
            let year = Date()
            formaterYear.dateFormat = "yyyy"
            formaterForDate.dateFormat = "dd.MM.yyyy-HH:mm"
            formaterForHour.dateFormat = "HH"
            formaterForMinute.dateFormat = "mm"
            let timeStrHour = formaterForHour.string(from: time.date)
            let timeStrMin = formaterForMinute.string(from: time.date)
            let yearStr = formaterYear.string(from: year)
            
            let finalDate = formaterForDate.date(from: "\(currentDay+1).\(currentMonth+1).\(yearStr)-\(timeStrHour):\(timeStrMin)")
            
            print("date:::::::::>>>>>", formaterForDate.string(from: finalDate!))
            
            let toDoDict: [String:String] = ["timeHour" : timeStrHour, "timeMin" : timeStrMin, "todo" : toDo.text!]
            
            let notification = UILocalNotification()
            notification.timeZone = TimeZone.current
            notification.fireDate = finalDate!.addingTimeInterval(-300)
            notification.alertBody = "Через 5 минут:\(toDo.text!)"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            
            let notification1 = UILocalNotification()
            notification1.timeZone = TimeZone.current
            notification1.fireDate = finalDate!
            notification1.alertBody = "\(toDo.text!)"
            notification1.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification1)
            
            let planVC : PlanVC = mainStoryboard.instantiateViewController(withIdentifier: "Plan") as! PlanVC
            planVC.currentDay = currentDay
            planVC.currenMonth = currentMonth
            planVC.addToDoThing(toDoDict)
            navigationController?.pushViewController(planVC, animated: true)
        }
    }
}
