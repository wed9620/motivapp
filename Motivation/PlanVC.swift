//
//  PlanVC.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 18/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import CVCalendar
import RealmSwift
import MGSwipeTableCell

class PlanVC: UIViewController, UITableViewDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var toDoTable: UITableView!
    @IBOutlet weak var toBuyTable: UITableView!
    var currentDay = 0
    var currenMonth = 0
    var dateFromSubVC = NSDate()
    let realm = try! Realm()
    var toDoList = Array<Array<NSMutableArray>>()
    var toBuyList = NSMutableArray()
    var sideMenuOpened = Bool()
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initArray()
        
        if currentDay == 0 || currenMonth == 0 {
            let dayFormater = NSDateFormatter()
            dayFormater.dateFormat = "dd"
            let monthFormater = NSDateFormatter()
            monthFormater.dateFormat = "MM"
            let daySTR = dayFormater.stringFromDate(NSDate())
            let monthSTR = monthFormater.stringFromDate(NSDate())
            currentDay = Int(daySTR)! - 1
            currenMonth = Int(monthSTR)! - 1
            toDoTable.rowHeight = UITableViewAutomaticDimension
            toDoTable.estimatedRowHeight = 62
            print(currentDay, currenMonth)
        }
        
        let dateFormater = NSDateFormatter()
        calendarView.toggleViewWithDate(dateFromSubVC)
        
        load()
        tap = UITapGestureRecognizer(target: self, action: #selector(PlanVC.tapped))
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(tap)
    }
    
    func initArray() {
        for i in 0..<12 {
            toDoList.append(Array())
            for _ in 0..<31 {
                toDoList[i].append(NSMutableArray())
            }
        }
    }
    
    
    @IBAction func todayTapped(sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
    
    @IBAction func addToDoThingTapped(sender: AnyObject) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : AddToDoThing = mainStoryboard.instantiateViewControllerWithIdentifier("ATDT") as! AddToDoThing
        vc.currentDay = currentDay
        vc.currentMonth = currenMonth
        navigationController?.showViewController(vc, sender: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        toDoTable.reloadData()
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        currentDay = dayView.date.day - 1
        currenMonth = dayView.date.month - 1
        toDoTable.reloadData()
        print(currentDay,currenMonth)
    }
    
    //    func sideMenuWillOpen() {
    //        if sideMenuOpened == false {
    //            UIView.animateWithDuration(0.5, animations: {
    //                print("asdasdasdas")
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
    
    func tapped() {
        view.endEditing(true)
    }
    
    func load() {
        let toDos = realm.objects(toDo)
        for todo in toDos {
            toDoList[todo.month][todo.day].addObject(["timeHour":todo.timeHour, "timeMin":todo.timeMin, "todo":todo.toDo])
        }
        let toBuys = realm.objects(toBuy)
        for tobuy in toBuys {
            toBuyList.addObject(tobuy.toBuyStr)
        }
        sortArr()
    }
    
    func sortArr() {
        let size = toDoList[currenMonth][currentDay].count
        if size > 0 {
            for i in 0..<size {
                var swapped = false
                let pass = (size - 1) - i
                for j in 0..<pass {
                    let key = Int(toDoList[currenMonth][currentDay][j].valueForKey("timeHour") as! String)
                    if key > Int(toDoList[currenMonth][currentDay][j+1].valueForKey("timeHour") as! String) {
                        let tempDic = NSDictionary(dictionary: ["timeHour":toDoList[currenMonth][currentDay][j].valueForKey("timeHour") as! String, "timeMin":toDoList[currenMonth][currentDay][j].valueForKey("timeMin") as! String, "todo":toDoList[currenMonth][currentDay][j].valueForKey("todo") as! String])
                        let keyDic = NSDictionary(dictionary: ["timeHour":toDoList[currenMonth][currentDay][j+1].valueForKey("timeHour") as! String, "timeMin":toDoList[currenMonth][currentDay][j+1].valueForKey("timeMin") as! String, "todo":toDoList[currenMonth][currentDay][j+1].valueForKey("todo") as! String])
                        toDoList[currenMonth][currentDay].replaceObjectAtIndex(j, withObject: keyDic)
                        toDoList[currenMonth][currentDay].replaceObjectAtIndex(j+1, withObject: tempDic)
                        swapped = true
                    } else if key == Int(toDoList[currenMonth][currentDay][j+1].valueForKey("timeHour") as! String) {
                        for k in 0..<size {
                            var sw = false
                            let pss = (size - 1) - k
                            for j in 0..<pss {
                                let key = Int(toDoList[currenMonth][currentDay][j].valueForKey("timeMin") as! String)
                                if key > Int(toDoList[currenMonth][currentDay][j+1].valueForKey("timeMin") as! String) {
                                    let tempDic = NSDictionary(dictionary: ["timeHour":toDoList[currenMonth][currentDay][j].valueForKey("timeHour") as! String, "timeMin":toDoList[currenMonth][currentDay][j].valueForKey("timeMin") as! String, "todo":toDoList[currenMonth][currentDay][j].valueForKey("todo") as! String])
                                    let keyDic = NSDictionary(dictionary: ["timeHour":toDoList[currenMonth][currentDay][j+1].valueForKey("timeHour") as! String, "timeMin":toDoList[currenMonth][currentDay][j+1].valueForKey("timeMin") as! String, "todo":toDoList[currenMonth][currentDay][j+1].valueForKey("todo") as! String])
                                    toDoList[currenMonth][currentDay].replaceObjectAtIndex(j, withObject: keyDic)
                                    toDoList[currenMonth][currentDay].replaceObjectAtIndex(j+1, withObject: tempDic)
                                    sw = true
                                }
                            }
                            if !sw {
                                continue
                            }
                        }
                    }
                }
                if !swapped {
                    break
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    @IBAction func menu(sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }
    
    @IBAction func addToBuyThing(sender: AnyObject) {
        let addBuy = UIAlertController(title: "Добавить покупку", message: "", preferredStyle: .Alert)
        let addBuyAction = UIAlertAction(title: "Добавить", style: .Default, handler: { (_) in
            let toBuyField = addBuy.textFields![0] as UITextField
            self.toBuyList.addObject(toBuyField.text!)
            let myToBuy = toBuy()
            myToBuy.toBuyStr = toBuyField.text! as String
            try! self.realm.write{
                self.realm.add(myToBuy)
            }
            self.toBuyTable.reloadData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        addBuy.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Например: Хлеб"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                addBuyAction.enabled = textField.text != ""
            }
        }
        
        addBuy.addAction(addBuyAction)
        addBuy.addAction(cancel)
        self.presentViewController(addBuy, animated: true, completion:nil)
    }
    
    func addToDoThing(toDoThing: NSDictionary) {
        let myToDo = toDo()
        myToDo.timeHour = "\(toDoThing.valueForKey("timeHour")!)"
        myToDo.timeMin = "\(toDoThing.valueForKey("timeMin")!)"
        myToDo.toDo = toDoThing.valueForKey("todo") as! String
        myToDo.day = currentDay
        myToDo.month = currenMonth
        try! realm.write {
            realm.add(myToDo)
        }
        initArray()
       // toDoList[currenMonth][currentDay].addObject(toDoThing)
    }
}

extension PlanVC: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.toDoTable {
            return toDoList[currenMonth][currentDay].count
        } else if tableView == self.toBuyTable{
            return toBuyList.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.toDoTable {
            let toDoThing = toDoList[currenMonth][currentDay][indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ToDoCell
            cell.rightButtons = [MGSwipeButton(title: "Удалить", backgroundColor: UIColor.redColor()
                ,callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    
                    self.toDoList[self.currenMonth][self.currentDay].removeObjectAtIndex(indexPath.row)
                    let toDoToDel = self.realm.objects(toDo).filter("toDo = '\(toDoThing.valueForKey("todo") as! String)'")
                    let doing = toDoToDel.first!
                    try! self.realm.write {
                        self.realm.delete(doing)
                    }
                    tableView.reloadData()
                    return true
            })]
            cell.time.text = "\(toDoThing.valueForKey("timeHour")! as! String):\(toDoThing.valueForKey("timeMin")! as! String)"
            cell.toDo.text = toDoThing.valueForKey("todo") as? String
            return cell
            
        } else {
            let toByuThing = toBuyList[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("Buy") as! MGSwipeTableCell
            cell.rightButtons = [MGSwipeButton(title: "Удалить", backgroundColor: UIColor.redColor()
                ,callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    
                    self.toBuyList.removeObjectAtIndex(indexPath.row)
                    let toBuyToDel = self.realm.objects(toBuy).filter("toBuyStr = '\(toByuThing as! String)'")
                    let buing = toBuyToDel.first!
                    try! self.realm.write {
                        self.realm.delete(buing)
                    }
                    tableView.reloadData()
                    return true
            })]
            cell.textLabel?.text = toByuThing as? String
            return cell
        }
    }  
}
