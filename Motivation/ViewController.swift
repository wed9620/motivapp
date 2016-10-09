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
    fileprivate let ITEMS_KEY = "todoItems"
    class var sharedInstance: TodoList {
        struct Static {
            static let instance = TodoList()
        }
        return Static.instance
    }
    func addItem(_ item: TodoItem) {
        var todoDictionary = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? Dictionary()
        todoDictionary[item.UUID] = [
            "deadline": item.deadline,
            "title": item.title,
            "UUID": item.UUID
            ]
        UserDefaults.standard.set(todoDictionary, forKey: ITEMS_KEY) // save/overwrite todo item list
        let notification = UILocalNotification()
        notification.alertBody = "\(item.title)"
        notification.timeZone = TimeZone.current
        notification.fireDate = item.deadline as Date
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["title":item.title, "UUID":item.UUID]
        if item.rep != NSCalendar.Unit.minute {
            notification.repeatInterval = item.rep
        }
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    func allItems() -> [TodoItem] {
        let todoDictionary = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({TodoItem(deadline: $0["deadline"] as! Date, rep: NSCalendar.Unit.minute, title: $0["title"] as! String, UUID: $0["UUID"] as! String!)}).sorted(by: {(left: TodoItem, right:TodoItem) -> Bool in
            (left.deadline.compare(right.deadline) == .orderedAscending)
        })
    }
    func removeItem(_ item: TodoItem) {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.shared.scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        
        if var todoItems = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) {
            todoItems.removeValue(forKey: item.UUID)
            UserDefaults.standard.set(todoItems, forKey: ITEMS_KEY) // save/overwrite todo item list
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
        if tableView.numberOfRows(inSection: 0) == 0 {
            tableView.isHidden = true
        } else {
            noObjects.isHidden = true
        }
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните, чтобы обновить")
        refreshControl.addTarget(self, action: #selector(self.reload), for: UIControlEvents.valueChanged)
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
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeItem(_ item: TodoItem) {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.shared.scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == item.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
        
        if var todoItems = UserDefaults.standard.dictionary(forKey: "todoItems") {
            todoItems.removeValue(forKey: item.UUID)
            UserDefaults.standard.set(todoItems, forKey: "todoItems") // save/overwrite todo item list
        }
    }
    
    @IBAction func toggled(_ sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }

    func load() {
        let notes = realm.objects(Notes)
        for note in notes {
            notesArr.add(["description":note.desc])
        }
    }
    
    func addItemToCollection(_ desc:String){
        let myNote = Notes()
        myNote.desc = desc
        notesArr.add(["description":myNote.desc])
        
        try! self.realm.write {
            self.realm.add(myNote)
        }
    }
    
    func tweet(_ sender:UIButton) {
        let note = notesArr[sender.tag]
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let tweetController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetController?.setInitialText("У меня новая цель: \((note as AnyObject).value(forKey: "description") as! String) !!!\n @motivationAPP")
            self.present(tweetController!, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Аккаунт", message: "Пожалуйста, авторизируйтесь", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Настройки", style: .default, handler: { (UIAlertAction) in
                
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsURL {
                    UIApplication.shared.openURL(url)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func preferences(_ sender:UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let vc : AddNotification = mainStoryboard.instantiateViewController(withIdentifier: "AddNotification") as! AddNotification
        vc.titStr = (notesArr[sender.tag] as AnyObject).value(forKey: "description") as! String
        let note = self.notesArr[sender.tag]
        curTitle = (note as AnyObject).value(forKey: "description")! as! String
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notesArr.count == 0 {
            noObjects.isHidden = false
            return 0
        } else {
            noObjects.isHidden = true
        }
        return notesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! CustomCell
        let note = notesArr[(indexPath as NSIndexPath).row]
        if todoItems.count >= (indexPath as NSIndexPath).row {
            for item in todoItems {
                if item.title.contains((note as AnyObject).value(forKey: "description") as! String) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "До dd.MM.YYYY HH:mm"
                    cell.fireDate.text = dateFormatter.string(from: item.deadline as Date)
                    if (item.isOverdue) {
                        cell.fireDate.textColor = UIColor.red
                    } else {
                        cell.fireDate.textColor = UIColor.black
                    }
                }
            }
        }
        
        cell.desc.text = (note as AnyObject).value(forKey: "description") as! String
        cell.tweet.addTarget(self, action: #selector(ViewController.tweet(_:)), for: .touchUpInside)
        cell.tweet.tag = (indexPath as NSIndexPath).row
        cell.preferences.addTarget(self, action: #selector(ViewController.preferences(_:)), for: .touchUpInside)
        cell.preferences.tag = (indexPath as NSIndexPath).row
        
        
        cell.rightButtons = [MGSwipeButton(title: "Выполнено", backgroundColor: UIColor.red
            ,callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                
                self.notesArr.removeObject(at: (indexPath as NSIndexPath).row)
                let goalToDel = self.realm.objects(Notes).filter("desc = '\(note.value(forKey: "description") as! String)'")
                let goal = goalToDel.first!
                try! self.realm.write {
                    self.realm.delete(goal)
                }
                if self.todoItems.count >= (indexPath as NSIndexPath).row {
                    for item in self.todoItems {
                        if item.title.contains(note.value(forKey: "description") as! String) {
                            
                            TodoList.sharedInstance.removeItem(item)
                        }
                    }
                }
                tableView.reloadData()
                if tableView.numberOfRows(inSection: 0) == 0 {
                    tableView.isHidden = true
                    self.noObjects.isHidden = false
                }
                return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.drag
        
        return cell
    }
}
