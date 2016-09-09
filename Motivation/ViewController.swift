//
//  ViewController.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 25/03/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell
import Social
import Foundation

// TodoList:
class TodoList {
    private let ITEMS_KEY = "todoItems"
    class var sharedInstance: TodoList {
        struct Static {
            static let instance = TodoList()
        }
        return Static.instance
    }
    func addItem(item: TodoItem) {
        var todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary()
        todoDictionary[item.UUID] = [
            "deadline": item.deadline,
            "title": item.title,
            "UUID": item.UUID
            ]
        NSUserDefaults.standardUserDefaults().setObject(todoDictionary, forKey: ITEMS_KEY) // save/overwrite todo item list
        let notification = UILocalNotification()
        notification.alertBody = "\(item.title)"
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.fireDate = item.deadline
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["title":item.title, "UUID":item.UUID]
        if item.rep != NSCalendarUnit.Minute {
            notification.repeatInterval = item.rep
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    func allItems() -> [TodoItem] {
        let todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({TodoItem(deadline: $0["deadline"] as! NSDate, rep: NSCalendarUnit.Minute, title: $0["title"] as! String, UUID: $0["UUID"] as! String!)}).sort({(left: TodoItem, right:TodoItem) -> Bool in
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


class ViewController: UIViewController, SSASideMenuDelegate {
    
    // IBOutlets
    @IBOutlet weak var noObjects: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // Variables
    var tap = UITapGestureRecognizer()
    var todoItems = TodoList.sharedInstance.allItems()
    var deletedOne = false
    let addedNote = AddNote()
    var curTitle = String()
    let realm = try! Realm()
    var notesArr = NSMutableArray()
    var sideMenuOpened = Bool()
    var refreshControl: UIRefreshControl!
    
    // MARK:UIViewController
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
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить")
        refreshControl.addTarget(self, action: #selector(self.reload), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.addGestureRecognizer(tap)
    }

    func reload() {
        tableView.reloadData()
        tableView.beginUpdates()
        tableView.endUpdates()
        refreshControl.endRefreshing()
    }
    
    //
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func toggled(sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }

    func load() {
        let notes = realm.objects(Notes)
        for note in notes {
            notesArr.addObject(["description":note.desc])
        }
    }
    
    func addItemToCollection(desc:String){
        let myNote = Notes()
        myNote.desc = desc
        notesArr.addObject(["description":myNote.desc])
        
        try! self.realm.write {
            self.realm.add(myNote)
        }
    }
    
    func tweet(sender:UIButton) {
        let note = notesArr[sender.tag]
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetController.setInitialText("У меня новая цель: \(note.valueForKey("description") as! String) !!!\n @motivationAPP")
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
    }
    
    func preferences(sender:UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let vc : AddNotification = mainStoryboard.instantiateViewControllerWithIdentifier("AddNotification") as! AddNotification
        vc.titStr = notesArr[sender.tag].valueForKey("description") as! String
        let note = self.notesArr[sender.tag]
        curTitle = note.valueForKey("description")! as! String
        
        navigationController?.pushViewController(vc, animated: true)
        
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
        if todoItems.count >= indexPath.row {
            for item in todoItems {
                if item.title.containsString(note.valueForKey("description") as! String) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "До dd.MM.YYYY HH:mm"
                    cell.fireDate.text = dateFormatter.stringFromDate(item.deadline)
                    if (item.isOverdue) {
                        cell.fireDate.textColor = UIColor.redColor()
                    } else {
                        cell.fireDate.textColor = UIColor.blackColor()
                    }
                }
            }
        }
        
        cell.desc.text = note.valueForKey("description") as! String
        cell.tweet.addTarget(self, action: #selector(ViewController.tweet(_:)), forControlEvents: .TouchUpInside)
        cell.tweet.tag = indexPath.row
        cell.preferences.addTarget(self, action: #selector(ViewController.preferences(_:)), forControlEvents: .TouchUpInside)
        cell.preferences.tag = indexPath.row
        
        
        cell.rightButtons = [MGSwipeButton(title: "Выполнено", backgroundColor: UIColor.redColor()
            ,callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                
                self.notesArr.removeObjectAtIndex(indexPath.row)
                let goalToDel = self.realm.objects(Notes).filter("desc = '\(note.valueForKey("description") as! String)'")
                let goal = goalToDel.first!
                try! self.realm.write {
                    self.realm.delete(goal)
                }
                if self.todoItems.count >= indexPath.row {
                    for item in self.todoItems {
                        if item.title.containsString(note.valueForKey("description") as! String) {
                            
                            TodoList.sharedInstance.removeItem(item)
                        }
                    }
                }
                tableView.reloadData()
                if tableView.numberOfRowsInSection(0) == 0 {
                    tableView.hidden = true
                    self.noObjects.hidden = false
                }
                return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
        
        return cell
    }
}
