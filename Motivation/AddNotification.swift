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
    var deadline: Date
    var UUID: String
    var rep: NSCalendar.Unit
    var isOverdue: Bool {
        return (Date().compare(self.deadline) == ComparisonResult.orderedDescending)
    }
    
    init(deadline: Date, rep: NSCalendar.Unit, title: String, UUID: String) {
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
    var curRep = NSCalendar.Unit.minute
    
    @IBOutlet weak var repPickerContainer: UITableViewCell!
    @IBOutlet weak var repLabelContainer: UITableViewCell!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var repContainer: UITableViewCell!
    
    @IBOutlet weak var rep: UISwitch!
    let repArr = [NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekday, NSCalendar.Unit.year]
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
        
        repLabelContainer.isHidden = true
        repPickerContainer.isHidden = true
        dateCell.isHidden = true
        dateViewer.isHidden = true
        repContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func repSwitched(_ sender: AnyObject) {
        if self.rep.isOn == true {
            repLabelContainer.isHidden = false
            repPickerContainer.isHidden = false
        } else {
            repLabelContainer.isHidden = true
            repPickerContainer.isHidden = true
        }
    }
    
    @IBAction func switched(_ sender: AnyObject) {
        if remind.isOn == true {
            dateCell.isHidden = false
            dateViewer.isHidden = false
            repContainer.isHidden = false
        } else {
            dateCell.isHidden = true
            dateViewer.isHidden = true
            repContainer.isHidden = true
            rep.isOn = false
        }
        repSwitched(self)
    }
    
    @IBAction func dateChanged(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateViewLabel.text = dateFormatter.string(from: date.date)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        
        if remind.isOn == true {
            
            citate.parseJSON()
            let randomNumber = arc4random_uniform(UInt32(citate.itemsArray.count))
            let randCitate = citate.itemsArray[Int(randomNumber)]
            let citTitle = (randCitate as AnyObject).value(forKey: "title") as! String
            print(citTitle)
            
            let todoItem = TodoItem(deadline: date.date, rep: curRep, title: "\(tit.text! + "\nЦитата: " + citTitle)", UUID: UUID().uuidString)
            TodoList.sharedInstance.addItem(todoItem)
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "VC") as! ViewController
        
        navigationController?.popViewController(animated: true)
    }
    
    
    func tapped() {
        view.endEditing(true)
    }
}

extension AddNotification: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reps.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reps[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repLabel.text = reps[row]
        curRep = repArr[row]
    }
}
