//
//  ViewController.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 25/03/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import ENSwiftSideMenu
import RealmSwift
import MGSwipeTableCell
import Social

class TodoList {
    private let ITEMS_KEY = "todoItems"
    class var sharedInstance : TodoList {
        struct Static {
            static let instance : TodoList = TodoList()
        }
        return Static.instance
    }
    func addItem(item: TodoItem) {
        var todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        todoDictionary[item.UUID] = ["deadline": item.deadline, "title": item.title, "UUID": item.UUID] // store NSData representation of todo item in dictionary with UUID as key
        NSUserDefaults.standardUserDefaults().setObject(todoDictionary, forKey: ITEMS_KEY) // save/overwrite todo item list
        let notification = UILocalNotification()
        notification.alertBody = "Время вышло:\(item.title)"
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.fireDate = item.deadline
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["title":item.title, "UUID":item.UUID]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    func allItems() -> [TodoItem] {
        let todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({TodoItem(deadline: $0["deadline"] as! NSDate, title: $0["title"] as! String, UUID: $0["UUID"] as! String!)}).sort({(left: TodoItem, right:TodoItem) -> Bool in
            (left.deadline.compare(right.deadline) == .OrderedAscending)
        })
    }
        func removeItem(item: TodoItem) {
            let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
            guard scheduledNotifications != nil else {return} // Nothing to remove, so return
            
            for notification in scheduledNotifications! { // loop through notifications...
                if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                    UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                    break
                }
            }
            
            if var todoItems = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
                todoItems.removeValueForKey(item.UUID)
                NSUserDefaults.standardUserDefaults().setObject(todoItems, forKey: ITEMS_KEY) // save/overwrite todo item list
            }
        }
}

class ViewController: UIViewController, ENSideMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tap = UITapGestureRecognizer()
    var todoItems = TodoList.sharedInstance.allItems()

    @IBOutlet weak var noObjects: UILabel!
    var deletedOne = false
    let addedNote = AddNote()
    var curTitle = String()
    let realm = try! Realm()
    var notesArr = NSMutableArray()
    var sideMenuOpened = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        load()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        if tableView.numberOfRowsInSection(0) == 0 {
            tableView.hidden = true
        } else {
            noObjects.hidden = true
        }
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapped))
        self.tableView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        reload()
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
        self.sideMenuController()?.sideMenu?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
    
    func removeItem(item: TodoItem) {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        
        if var todoItems = NSUserDefaults.standardUserDefaults().dictionaryForKey("todoItems") {
            todoItems.removeValueForKey(item.UUID)
            NSUserDefaults.standardUserDefaults().setObject(todoItems, forKey: "todoItems") // save/overwrite todo item list
        }
    }
    
    func tapped() {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }

    @IBAction func toggled(sender: AnyObject) {
        toggleSideMenuView()
    }
    func load() {
        let notes = realm.objects(Notes)
        for note in notes {
            notesArr.addObject(["description":note.desc])
        }
    }
    @IBAction func addItem(sender: AnyObject) {
        navigationController?.pushViewController(addedNote, animated: true)
    }
    func addItemToCollection(desc:String){
        let myNote = Notes()
        myNote.desc = desc
        notesArr.addObject(["description":myNote.desc])
        
        try! self.realm.write {
            self.realm.add(myNote)
        }
    }
    func reload() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notesArr.count == 0 {
            noObjects.hidden = false
            return 0
        } else {
            noObjects.hidden = true
        }
        return notesArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CustomCell
        let note = notesArr[indexPath.row]
        if todoItems.count > indexPath.row {
            
            let item = todoItems[indexPath.row]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "До dd.MM.YYYY HH:mm"
            cell.fireDate.text = dateFormatter.stringFromDate(item.deadline)
            if (item.isOverdue) {
                cell.fireDate.textColor = UIColor.redColor()
            } else {
                cell.fireDate.textColor = UIColor.blackColor()
            }
        }
        
        cell.desc.text = note.valueForKey("description") as! String
        
        
        
        cell.rightButtons = [MGSwipeButton(title: "Выполнено", backgroundColor: UIColor.redColor()
            ,callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                
                self.notesArr.removeObjectAtIndex(indexPath.row)
                let goalToDel = self.realm.objects(Notes).filter("desc = '\(note.valueForKey("description") as! String)'")
                let goal = goalToDel.first!
                try! self.realm.write {
                    self.realm.delete(goal)
                }
                if self.todoItems.count > indexPath.row {
                    let item = self.todoItems[indexPath.row]
                    TodoList.sharedInstance.removeItem(item)
                }
                tableView.reloadData()
                if tableView.numberOfRowsInSection(0) == 0 {
                    tableView.hidden = true
                    self.noObjects.hidden = false
                }
                return true
            })]
        cell.leftButtons = [MGSwipeButton(title: "Твит", backgroundColor: UIColor(colorLiteralRed: 66/255, green: 152/255, blue: 237/255, alpha: 1)
            ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                    let tweetController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    tweetController.setInitialText("У меня новая цель: \(cell.textLabel!.text!) !!!\n @motivationAPP")
                    self.presentViewController(tweetController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Аккаунт", message: "Пожалуйста, авторизируйтесь", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Настройки", style: .Default, handler: { (UIAlertAction) in
                        
                        let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                        if let url = settingsURL {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            return true
        }), MGSwipeButton(title: "Уведомить", backgroundColor: UIColor.blueColor(), callback: {
             (sender: MGSwipeTableCell!) -> Bool in
            let note = self.notesArr[indexPath.row]
            self.curTitle = note.valueForKey("description")! as! String
            self.performSegueWithIdentifier("addNotification", sender: self)
            return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let note = notesArr[indexPath.row]
        curTitle = note.valueForKey("description")! as! String
        performSegueWithIdentifier("addNotification", sender: self)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNotification" {
            if let DVC = segue.destinationViewController as? AddNotification {
                DVC.titStr = curTitle
            }
        }
    }
}
