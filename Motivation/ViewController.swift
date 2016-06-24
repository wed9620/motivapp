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

class ViewController: UIViewController, ENSideMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tap = UITapGestureRecognizer()

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
    
//    func sideMenuWillOpen() {
//        if sideMenuOpened == false {
//            UIView.animateWithDuration(0.5, animations: {
//                self.view.frame = CGRectMake(self.view.frame.origin.x + 200, 0 , self.view.frame.width, self.view.frame.height)
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
//    
//    func sideMenuWillClose() {
////        if sideMenuOpened {
//            UIView.animateWithDuration(0.5, animations: {
//                self.view.frame = CGRectMake(self.view.frame.origin.x - 200, 0 , self.view.frame.width, self.view.frame.height)
//            })
////        }
//    }
    
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
        let note = notesArr[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CustomCell
        
        cell.desc.text = note.valueForKey("description") as! String
        //cell.desc.sizeToFit()
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Выполнено", backgroundColor: UIColor.redColor()
            ,callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                
                self.notesArr.removeObjectAtIndex(indexPath.row)
                let goalToDel = self.realm.objects(Notes).filter("desc = '\(note.valueForKey("description") as! String)'")
                let goal = goalToDel.first!
                try! self.realm.write {
                    self.realm.delete(goal)
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
