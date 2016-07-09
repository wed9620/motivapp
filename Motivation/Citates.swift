//
//  Citates.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 17/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import RealmSwift
import ENSwiftSideMenu

class Citates: UIViewController, iCarouselDelegate, iCarouselDataSource, ENSideMenuDelegate {
    
    @IBOutlet var citatesView: iCarousel!
    
    
    var itemsArray = NSMutableArray()
    var favItems = NSMutableArray()
    var turnedON = false
    var favButton = UIButton()
    let realm = try! Realm()
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var tab: UITabBar!
    @IBOutlet weak var fav: UITabBarItem!
    @IBOutlet weak var all: UITabBarItem!
    var sideMenuOpened = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(Citates.tapped))
        citatesView.type = .TimeMachine
        view.addGestureRecognizer(tap)
        citatesView.addGestureRecognizer(tap)
        citatesView.scrollSpeed = 0.2
        // Do any additional setup after loading the view.
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapped() {
        if isSideMenuOpen() {
            toggleSideMenuView()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        readFromDB()
        parseJSON()
    }
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        guard tab != nil else{
            return itemsArray.count
        }
        if tab.selectedItem == fav {
            return favItems.count
        } else {
            return itemsArray.count
        }
    }
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var item = itemsArray[index]
        if tab.selectedItem == fav {
            item = favItems[index]
        } else {
            item = itemsArray[index]
            for cit in favItems {
                if cit.valueForKey("title") as! String == item.valueForKey("title") as! String {
                    item = cit
                }
            }
        }
        
        favButton = UIButton(frame: CGRect(x: 125, y: 320, width: 50, height: 50))
        favButton.setImage(UIImage(named: "favYES"), forState: .Normal)
        favButton.tag = index
        favButton.addTarget(self, action: #selector(Citates.favoriteTapped(_:)), forControlEvents: .TouchUpInside)
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        tempView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.8)
        let bgImage = UIImageView(image: UIImage(named: "bg2"))
        bgImage.frame = CGRect(x: 0, y: 50, width: 300, height: 250)
        let citateLabel = UITextView(frame: CGRect(x: 0, y: 50, width: 300, height: 250))
        citateLabel.text = item.valueForKey("title") as! String
        citateLabel.font!.fontWithSize(40)
        citateLabel.textColor = UIColor.whiteColor()
        citateLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        citateLabel.userInteractionEnabled = false
        let authorButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        authorButton.setTitle("\(item.valueForKey("author") as! String)", forState: .Normal)
        authorButton.addTarget(self, action: #selector(Citates.showIt(_:)), forControlEvents: .TouchUpInside)
        authorButton.titleLabel!.textColor = UIColor.blackColor()
        tempView.addSubview(bgImage)
        tempView.addSubview(citateLabel)
        tempView.addSubview(authorButton)
        tempView.addSubview(favButton)
        tempView.addGestureRecognizer(tap)
        
        return tempView
    }
    
    func showIt(sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : AuthorVC = mainStoryboard.instantiateViewControllerWithIdentifier("Author") as! AuthorVC
        vc.author = (sender.titleLabel?.text!)!
        navigationController?.showViewController(vc, sender: nil)
    }
    
    func favoriteTapped(sender: UIButton) {
        
        
        var item = itemsArray[sender.tag]
        if tab.selectedItem == fav {
            item = favItems[sender.tag]
        }
        let ON = item.valueForKey("favorite") as! Bool
        if ON == false {
            let newItem = ["title":item["title"] as! String, "author": item["author"] as! String, "favorite": true]
            itemsArray.removeObjectAtIndex(sender.tag)
            itemsArray.insertObject(newItem, atIndex: sender.tag)
            addToDB(sender.tag)
            citatesView.reloadData()
        } else if ON == true {
            if tab.selectedItem == fav {
                let newItem = ["title":item["title"] as! String, "author": item["author"] as! String, "favorite": false]
                let citToDel = realm.objects(FavCitates).filter("title = '\(newItem.valueForKey("title") as! String)'")
                let cit = citToDel.first!
                try! realm.write {
                    realm.delete(cit)
                }
                readFromDB()
            }
            citatesView.reloadData()
        }
    }
    
    func addToDB(index:Int) {
        let citate = itemsArray[index] as! NSDictionary
        for cit in favItems  {
            if cit as! NSObject == citate {
                return
            }
        }
        let myCitate = FavCitates()
        myCitate.title = citate.valueForKey("title") as! String
        myCitate.author = citate.valueForKey("author") as! String
        myCitate.favorite = true
        try! realm.write {
            realm.add(myCitate)
        }
        favItems.addObject(citate)
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.Spacing {
            return value*2
        }
        return value
    }
    
    func parseJSON() {
        let path = NSBundle.mainBundle().pathForResource("Citates", ofType: "json")
        let JSONData = NSData(contentsOfFile: path!)
        if let JSONResult: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
            let itemsArr = JSONResult["citates"] as! NSArray
            for item in itemsArr {
                itemsArray.addObject(["title":item["title"] as! String, "author": item["author"] as! String, "favorite": false])
            }
        }
    }
    @IBAction func toggle(sender: AnyObject) {
        toggleSideMenuView()
    }
    func readFromDB() {
        favItems.removeAllObjects()
        let favs = realm.objects(FavCitates)
        for fav in favs {
            favItems.addObject(fav)
        }
    }
}

extension Citates: UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        citatesView.reloadData()
    }
}
