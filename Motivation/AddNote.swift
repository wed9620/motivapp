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

class AddNote: UIViewController, UITextViewDelegate {
    
    var note = NSDictionary()
    let realm = try! Realm()
    var templates = NSMutableArray()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tap: UITapGestureRecognizer!
    var tapOver = UITapGestureRecognizer()
    var sideMenuOpened = Bool()
    var sideMenuClosed = Bool()
    
    @IBOutlet weak var desc: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tap.addTarget(self, action: #selector(AddNote.OK))
        view.addGestureRecognizer(tap)
        loadTemplates()
        desc.text = "Введите описание"
        desc.textColor = UIColor.lightGrayColor()
        
        desc.delegate = self 
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите описание"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        view.frame = CGRectMake(0, 0 , view.frame.width, view.frame.height)
    }
    
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
    
    func OK() {
        view.endEditing(true)
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
    
    func addFromTemplate(sender: UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentVC = ViewController()
        let template = self.templates[sender.tag]
        parentVC.addItemToCollection(template["title"] as! String)
        self.navigationController?.pushViewController(mainStoryboard.instantiateViewControllerWithIdentifier("VC"), animated: true)
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
        cell.desc.text = template.valueForKey("title") as? String
        cell.addClicked.addTarget(self, action: #selector(AddNote.addFromTemplate(_:)), forControlEvents: .TouchUpInside)
        cell.addClicked.tag = indexPath.row
        return cell
    }
}
