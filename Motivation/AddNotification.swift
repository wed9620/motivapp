//
//  AddNotification.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 06/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import EventKit
import ENSwiftSideMenu

class AddNotification: UITableViewController,  ENSideMenuDelegate{
    
    let citate = Citates()
    var importance = Int()
    var curRep = NSCalendarUnit()
    let repArr = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.Weekday, NSCalendarUnit.Year]
    let reps = ["Каждую минуту", "Каждый час", "Каждый день" , "Каждую неделю", "Каждый год"]
    var tap = UITapGestureRecognizer()
    
    var titStr = String()
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var tit: UITextView!
    @IBOutlet weak var repeats: UIPickerView!
    var appDelegate: AppDelegate?
    var sideMenuOpened = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        tit.text = titStr
        tap = UITapGestureRecognizer(target: self, action: #selector(AddNotification.tapped))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
        self.sideMenuController()?.sideMenu?.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
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
//    func sideMenuDidOpen() {
//        sideMenuOpened = true
//    }
//    
//    func sideMenuDidClose() {
//        sideMenuOpened = false
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                importance = 2
                break
            case 1:
                importance = 1
                break
            case 2:
                importance = 0
                break
            default:
                importance = 1
                break
            }
        }
        
    }
    @IBAction func dateChanged(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
    }
    
    @IBAction func save(sender: AnyObject) {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: { (success, accessError) -> Void in
        })
        let event:EKEvent = EKEvent(eventStore: eventStore)
        
        citate.parseJSON()
        let randomNumber = arc4random_uniform(UInt32(citate.itemsArray.count))
        let randCitate = citate.itemsArray[Int(randomNumber)]
        let citTitle = randCitate.valueForKey("title") as! String
        print(citTitle)
//        
//        let notification = UILocalNotification()
//        notification.fireDate = date.date
//        notification.alertBody = "\(tit.text! + "\nЦитата: " + citTitle)"
//        notification.soundName = UILocalNotificationDefaultSoundName
//        notification.userInfo = ["CustomField1": "w00t"]
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        event.title = "\(tit.text! + "\nЦитата: " + citTitle)"
        event.startDate = date.date.dateByAddingTimeInterval(-3600)
        event.endDate = date.date
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        try! eventStore.saveEvent(event, span: .ThisEvent)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tapped() {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
        view.endEditing(true)
    }
}

extension AddNotification: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repArr.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reps[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        curRep = repArr[row]
    }
}
