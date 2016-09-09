//
//  AddNotification.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 06/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import EventKit

struct TodoItem {
    var title: String
    var deadline: NSDate
    var UUID: String
    var rep: NSCalendarUnit
    var isOverdue: Bool {
        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending)
    }
    
    init(deadline: NSDate, rep: NSCalendarUnit, title: String, UUID: String) {
        self.deadline = deadline
        self.title = title
        self.UUID = UUID
        self.rep = rep
    }
}

class AddNotification: UITableViewController {
    
    let citate = Citates()
    var importance = Int()
  
    @IBOutlet weak var dateViewLabel: UILabel!
    @IBOutlet weak var dateViewer: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    var curRep = NSCalendarUnit.Minute
    
    @IBOutlet weak var repPickerContainer: UITableViewCell!
    @IBOutlet weak var repLabelContainer: UITableViewCell!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var repContainer: UITableViewCell!
    
    @IBOutlet weak var rep: UISwitch!
    let repArr = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.Weekday, NSCalendarUnit.Year]
    let reps = ["Никогда", "Каждый час", "Каждый день" , "Каждую неделю", "Каждый год"]
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var remind: UISwitch!
    
    var titStr = String()
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var tit: UITextView!
    var appDelegate: AppDelegate?
    var sideMenuOpened = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        date.frame = CGRect(x: self.date.frame.origin.x, y: self.date.frame.origin.y, width: self.date.frame.width, height: 0)
        tit.text = titStr
        tap = UITapGestureRecognizer(target: self, action: #selector(AddNotification.tapped))
        view.addGestureRecognizer(tap)
        
        repLabelContainer.hidden = true
        repPickerContainer.hidden = true
        dateCell.hidden = true
        dateViewer.hidden = true
        repContainer.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func repSwitched(sender: AnyObject) {
        if self.rep.on == true {
            repLabelContainer.hidden = false
            repPickerContainer.hidden = false
        } else {
            repLabelContainer.hidden = true
            repPickerContainer.hidden = true
        }
    }
    
    @IBAction func switched(sender: AnyObject) {
        if remind.on == true {
            dateCell.hidden = false
            dateViewer.hidden = false
            repContainer.hidden = false
        } else {
            dateCell.hidden = true
            dateViewer.hidden = true
            repContainer.hidden = true
            rep.on = false
        }
        repSwitched(self)
    }
    
    @IBAction func dateChanged(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateViewLabel.text = dateFormatter.stringFromDate(date.date)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        if remind.on == true {
            
            citate.parseJSON()
            let randomNumber = arc4random_uniform(UInt32(citate.itemsArray.count))
            let randCitate = citate.itemsArray[Int(randomNumber)]
            let citTitle = randCitate.valueForKey("title") as! String
            print(citTitle)
            
            let todoItem = TodoItem(deadline: date.date, rep: curRep, title: "\(tit.text! + "\nЦитата: " + citTitle)", UUID: NSUUID().UUIDString)
            TodoList.sharedInstance.addItem(todoItem)
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let vc : ViewController = mainStoryboard.instantiateViewControllerWithIdentifier("VC") as! ViewController
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func tapped() {
        view.endEditing(true)
    }
}

extension AddNotification: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reps.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reps[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repLabel.text = reps[row]
        curRep = repArr[row]
    }
}
