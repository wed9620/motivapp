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
        desc.textColor = UIColor.lightGray
        
        desc.delegate = self 
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите описание"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNote(_ sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentVC = ViewController()
        if desc.text == "" {
            let alert = UIAlertController(title: "Пусто",
                                          message: "Вы ничего не ввели",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .default) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            parentVC.addItemToCollection(desc.text!)
        }
        navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "VC"), animated: true)
    }
    
    func OK() {
        view.endEditing(true)
    }
    
    func loadTemplates() {
        let temps = realm.objects(Templates)
        for temp in temps {
            templates.add(["title":temp.title, "description":temp.desc])
        }
        parseJSON()
    }
    
    func parseJSON() {
        let path = Bundle.main.path(forResource: "templates", ofType: "json")
        let JSONData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        if let JSONResult: NSDictionary = try! JSONSerialization.jsonObject(with: JSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
            let itemsArr = JSONResult["templates"] as! NSArray
            for item in itemsArr {
                templates.add(["title": item["title"] as! String])
            }
        }
    }
    
    func addFromTemplate(_ sender: UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentVC = ViewController()
        let template = self.templates[sender.tag]
        parentVC.addItemToCollection(template["title"] as! String)
        self.navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "VC"), animated: true)
    }
    
}


extension AddNote: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! templateCell
        let template = templates[(indexPath as NSIndexPath).row]
        cell.desc.text = (template as AnyObject).value(forKey: "title") as? String
        cell.addClicked.addTarget(self, action: #selector(AddNote.addFromTemplate(_:)), for: .touchUpInside)
        cell.addClicked.tag = (indexPath as NSIndexPath).row
        return cell
    }
}
