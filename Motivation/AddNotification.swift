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

struct TodoItem {
    var title: String
    var deadline: NSDate
    var UUID: String
    var isOverdue: Bool {
        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending)
    }
    
    init(deadline: NSDate, title: String, UUID: String) {
        self.deadline = deadline
        self.title = title
        self.UUID = UUID
    }
}

class AddNotification: UITableViewController,  ENSideMenuDelegate{
    
    let citate = Citates()
    var importance = Int()
    var curRep = NSCalendarUnit()
    let repArr = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.Weekday, NSCalendarUnit.Year]
    let reps = ["Никогда", "Каждую минуту", "Каждый час", "Каждый день" , "Каждую неделю", "Каждый год"]
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var remind: UISwitch!
    
    @IBOutlet weak var remindDate: UILabel!
    
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
        
        if remind.on == true {
            
            citate.parseJSON()
            let randomNumber = arc4random_uniform(UInt32(citate.itemsArray.count))
            let randCitate = citate.itemsArray[Int(randomNumber)]
            let citTitle = randCitate.valueForKey("title") as! String
            print(citTitle)
            
            let todoItem = TodoItem(deadline: date.date, title: "\(tit.text! + "\nЦитата: " + citTitle)", UUID: NSUUID().UUIDString)
            TodoList.sharedInstance.addItem(todoItem)
        }
        
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
