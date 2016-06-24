//
//  AddNote.swift
//  Pods
//
//  Created by Сергей Шинкаренко on 27/03/16.
//
//

import UIKit
import RealmSwift
import MGSwipeTableCell
import ENSwiftSideMenu

class AddNote: UIViewController, ENSideMenuDelegate {
    
    var note = NSDictionary()
    let realm = try! Realm()
    var templates = NSMutableArray()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tit: UITextField!
    @IBOutlet var tap: UITapGestureRecognizer!
    var tapOver = UITapGestureRecognizer()
    var sideMenuOpened = Bool()
    var sideMenuClosed = Bool()
    
    var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    
    var blurEffectView : UIVisualEffectView!
    
    @IBOutlet weak var desc: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
        tableView.removeFromSuperview()
        tap.addTarget(self, action: #selector(AddNote.OK))
        view.addGestureRecognizer(tap)
        loadTemplates()
        // Do any additional setup after loading the view.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
        self.sideMenuController()?.sideMenu?.delegate = self
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
//        if sideMenuOpened{
//            UIView.animateWithDuration(0.5, animations: {
//                self.view.frame = CGRectMake(self.view.frame.origin.x - 200, 0 , self.view.frame.width, self.view.frame.height)
//            })
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNote(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentVC = ViewController()
        if desc.text == "" {
            let alert = UIAlertController(title: "Пусто",
                                          message: "Вы ничего не ввели",
                                          preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .Default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            parentVC.addItemToCollection(desc.text!)
        }
        navigationController?.pushViewController(mainStoryboard.instantiateViewControllerWithIdentifier("VC"), animated: true)
    }
    
    @IBAction func fromTemplate(sender: AnyObject) {
        tapOver = UITapGestureRecognizer(target: self, action: #selector(AddNote.tappedOnBlur))
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(tableView)
        blurEffectView.addGestureRecognizer(tapOver)

        tableView.hidden = false
    }
    
    func tappedOnBlur() {
        tableView.hidden = true
        blurEffectView.hidden = true
    }
    
    func OK() {
        view.endEditing(true)
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
    
    func loadTemplates() {
        let temps = realm.objects(Templates)
        for temp in temps {
            templates.addObject(["title":temp.title, "description":temp.desc])
        }
        parseJSON()
    }
    
    func parseJSON() {
        let path = NSBundle.mainBundle().pathForResource("templates", ofType: "json")
        let JSONData = NSData(contentsOfFile: path!)
        if let JSONResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
            let itemsArr = JSONResult["templates"] as! NSArray
            for item in itemsArr {
                templates.addObject(["title": item["title"] as! String])
            }
        }
    }
}


extension AddNote: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as! templateCell
        let template = templates[indexPath.row]
        cell.rightButtons = [MGSwipeButton(title: "Добавить", backgroundColor: UIColor.darkGrayColor()
            ,callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let parentVC = ViewController()
                let template = self.templates[indexPath.row]
                parentVC.addItemToCollection(template["title"] as! String)
                self.navigationController?.pushViewController(mainStoryboard.instantiateViewControllerWithIdentifier("VC"), animated: true)

                return true
        })]
        cell.desc.text = template.valueForKey("title") as? String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentVC = ViewController()
        let template = templates[indexPath.row]
        parentVC.addItemToCollection(template["title"] as! String)
        navigationController?.pushViewController(mainStoryboard.instantiateViewControllerWithIdentifier("VC"), animated: true)
    }
}
