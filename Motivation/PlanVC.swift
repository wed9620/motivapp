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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PlanVC: UIViewController, UITableViewDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var toDoTable: UITableView!
    @IBOutlet weak var toBuyTable: UITableView!
    var currentDay = 0
    var currenMonth = 0
    var dateFromSubVC = Foundation.Date()
    let realm = try! Realm()
    var toDoList = Array<Array<NSMutableArray>>()
    var toBuyList = NSMutableArray()
    var sideMenuOpened = Bool()
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initArray()
        
        if currentDay == 0 || currenMonth == 0 {
            let dayFormater = DateFormatter()
            dayFormater.dateFormat = "dd"
            let monthFormater = DateFormatter()
            monthFormater.dateFormat = "MM"
            let daySTR = dayFormater.string(from: Foundation.Date())
            let monthSTR = monthFormater.string(from: Foundation.Date())
            currentDay = Int(daySTR)! - 1
            currenMonth = Int(monthSTR)! - 1
            toDoTable.rowHeight = UITableViewAutomaticDimension
            toDoTable.estimatedRowHeight = 62
            print(currentDay, currenMonth)
        }
        
        let dateFormater = DateFormatter()
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
    
    
    @IBAction func todayTapped(_ sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
    
    @IBAction func addToDoThingTapped(_ sender: AnyObject) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : AddToDoThing = mainStoryboard.instantiateViewController(withIdentifier: "ATDT") as! AddToDoThing
        vc.currentDay = currentDay
        vc.currentMonth = currenMonth
        navigationController?.show(vc, sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        toDoTable.reloadData()
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
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
            toDoList[todo.month][todo.day].add(["timeHour":todo.timeHour, "timeMin":todo.timeMin, "todo":todo.toDo])
        }
        let toBuys = realm.objects(toBuy)
        for tobuy in toBuys {
            toBuyList.add(tobuy.toBuyStr)
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
                    let key = Int((toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeHour") as! String)
                    if key > Int((toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeHour") as! String) {
                        let tempDic = NSDictionary(dictionary: ["timeHour":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeHour") as! String, "timeMin":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeMin") as! String, "todo":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "todo") as! String])
                        let keyDic = NSDictionary(dictionary: ["timeHour":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeHour") as! String, "timeMin":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeMin") as! String, "todo":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "todo") as! String])
                        toDoList[currenMonth][currentDay].replaceObject(at: j, with: keyDic)
                        toDoList[currenMonth][currentDay].replaceObject(at: j+1, with: tempDic)
                        swapped = true
                    } else if key == Int((toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeHour") as! String) {
                        for k in 0..<size {
                            var sw = false
                            let pss = (size - 1) - k
                            for j in 0..<pss {
                                let key = Int((toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeMin") as! String)
                                if key > Int((toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeMin") as! String) {
                                    let tempDic = NSDictionary(dictionary: ["timeHour":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeHour") as! String, "timeMin":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "timeMin") as! String, "todo":(toDoList[currenMonth][currentDay][j] as AnyObject).value(forKey: "todo") as! String])
                                    let keyDic = NSDictionary(dictionary: ["timeHour":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeHour") as! String, "timeMin":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "timeMin") as! String, "todo":(toDoList[currenMonth][currentDay][j+1] as AnyObject).value(forKey: "todo") as! String])
                                    toDoList[currenMonth][currentDay].replaceObject(at: j, with: keyDic)
                                    toDoList[currenMonth][currentDay].replaceObject(at: j+1, with: tempDic)
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
        return .monday
    }
    func presentationMode() -> CalendarMode {
        return .weekView
    }
    @IBAction func menu(_ sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }
    
    @IBAction func addToBuyThing(_ sender: AnyObject) {
        let addBuy = UIAlertController(title: "Добавить покупку", message: "", preferredStyle: .alert)
        let addBuyAction = UIAlertAction(title: "Добавить", style: .default, handler: { (_) in
            let toBuyField = addBuy.textFields![0] as UITextField
            self.toBuyList.add(toBuyField.text!)
            let myToBuy = toBuy()
            myToBuy.toBuyStr = toBuyField.text! as String
            try! self.realm.write{
                self.realm.add(myToBuy)
            }
            self.toBuyTable.reloadData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addBuy.addTextField { (textField) in
            textField.placeholder = "Например: Хлеб"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                addBuyAction.isEnabled = textField.text != ""
            }
        }
        
        addBuy.addAction(addBuyAction)
        addBuy.addAction(cancel)
        self.present(addBuy, animated: true, completion:nil)
    }
    
    func addToDoThing(_ toDoThing: NSDictionary) {
        let myToDo = toDo()
        myToDo.timeHour = "\(toDoThing.value(forKey: "timeHour")!)"
        myToDo.timeMin = "\(toDoThing.value(forKey: "timeMin")!)"
        myToDo.toDo = toDoThing.value(forKey: "todo") as! String
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.toDoTable {
            return toDoList[currenMonth][currentDay].count
        } else if tableView == self.toBuyTable{
            return toBuyList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.toDoTable {
            let toDoThing = toDoList[currenMonth][currentDay][(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ToDoCell
            cell.rightButtons = [MGSwipeButton(title: "Удалить", backgroundColor: UIColor.red
                ,callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    
                    self.toDoList[self.currenMonth][self.currentDay].removeObject(at: (indexPath as NSIndexPath).row)
                    let toDoToDel = self.realm.objects(toDo).filter("toDo = '\(toDoThing.value(forKey: "todo") as! String)'")
                    let doing = toDoToDel.first!
                    try! self.realm.write {
                        self.realm.delete(doing)
                    }
                    tableView.reloadData()
                    return true
            })]
            cell.time.text = "\((toDoThing as AnyObject).value(forKey: "timeHour")! as! String):\((toDoThing as AnyObject).value(forKey: "timeMin")! as! String)"
            cell.toDo.text = (toDoThing as AnyObject).value(forKey: "todo") as? String
            return cell
            
        } else {
            let toByuThing = toBuyList[(indexPath as NSIndexPath).row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Buy") as! MGSwipeTableCell
            cell.rightButtons = [MGSwipeButton(title: "Удалить", backgroundColor: UIColor.red
                ,callback: {
                    (sender: MGSwipeTableCell!) -> Bool in
                    
                    self.toBuyList.removeObject(at: (indexPath as NSIndexPath).row)
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
