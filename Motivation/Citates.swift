//
//  Citates.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 17/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit
import RealmSwift

class Citates: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
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
        citatesView.type = .coverFlow
        view.addGestureRecognizer(tap)
        citatesView.addGestureRecognizer(tap)
        citatesView.scrollSpeed = 0.3
        citatesView.scrollOffset = 0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: view.frame.height)
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

    override func awakeFromNib() {
        super.awakeFromNib()
        readFromDB()
        parseJSON()
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        guard tab != nil else{
            return itemsArray.count
        }
        if tab.selectedItem == fav {
            return favItems.count
        } else {
            return itemsArray.count
        }
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var item = itemsArray[index]
        if tab.selectedItem == fav {
            item = favItems[index]
        } else {
            item = itemsArray[index]
            for cit in favItems {
                if (cit as AnyObject).value(forKey: "title") as! String == (item as AnyObject).value(forKey: "title") as! String {
                    item = cit
                }
            }
        }
        
        favButton = UIButton(frame: CGRect(x: 125, y: 320, width: 50, height: 50))
        favButton.setTitleColor(UIColor(colorLiteralRed: 74/255, green: 207/255, blue: 1, alpha: 1), for: .highlighted)
        favButton.setImage(UIImage(named: "favYES"), for: UIControlState())
        favButton.tag = index
        favButton.addTarget(self, action: #selector(Citates.favoriteTapped(_:)), for: .touchUpInside)
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        tempView.backgroundColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 0.8)
        let bgImage = UIImageView(image: UIImage(named: "citBG"))
        bgImage.frame = CGRect(x: 0, y: 50, width: 300, height: 250)
        let citateLabel = UITextView(frame: CGRect(x: 0, y: 50, width: 300, height: 250))
        citateLabel.text = (item as AnyObject).value(forKey: "title") as! String
        citateLabel.font = UIFont(name: (citateLabel.font?.fontName)!, size: 20)
        citateLabel.textColor = UIColor.white
        citateLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        citateLabel.isUserInteractionEnabled = false
        let authorButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        authorButton.setTitleColor(UIColor(colorLiteralRed: 74/255, green: 207/255, blue: 1, alpha: 1), for: .highlighted)
        authorButton.setTitle("\((item as AnyObject).value(forKey: "author") as! String)", for: UIControlState())
        authorButton.addTarget(self, action: #selector(Citates.showIt(_:)), for: .touchUpInside)
        authorButton.titleLabel!.textColor = UIColor.black
        tempView.addSubview(bgImage)
        tempView.addSubview(citateLabel)
        tempView.addSubview(authorButton)
        tempView.addSubview(favButton)
        tempView.addGestureRecognizer(tap)
        
        return tempView
    }
    
    func showIt(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : AuthorVC = mainStoryboard.instantiateViewController(withIdentifier: "Author") as! AuthorVC
        vc.author = (sender.titleLabel?.text!)!
        navigationController?.show(vc, sender: nil)
    }
    
    func favoriteTapped(_ sender: UIButton) {
        
        
        var item = itemsArray[sender.tag]
        if tab.selectedItem == fav {
            item = favItems[sender.tag]
        }
        let ON = (item as AnyObject).value(forKey: "favorite") as! Bool
        if ON == false {
            let newItem = ["title":item["title"] as! String, "author": item["author"] as! String, "favorite": true]
            itemsArray.removeObject(at: sender.tag)
            itemsArray.insert(newItem, at: sender.tag)
            addToDB(sender.tag)
            citatesView.reloadData()
        } else if ON == true {
            if tab.selectedItem == fav {
                let newItem = ["title":item["title"] as! String, "author": item["author"] as! String, "favorite": false]
                let citToDel = realm.objects(FavCitates).filter("title = '\(newItem.value(forKey: "title") as! String)'")
                let cit = citToDel.first!
                try! realm.write {
                    realm.delete(cit)
                }
                readFromDB()
            }
            citatesView.reloadData()
        }
    }
    
    func addToDB(_ index:Int) {
        let citate = itemsArray[index] as! NSDictionary
        for cit in favItems  {
            if cit as! NSObject == citate {
                return
            }
        }
        let myCitate = FavCitates()
        myCitate.title = citate.value(forKey: "title") as! String
        myCitate.author = citate.value(forKey: "author") as! String
        myCitate.favorite = true
        try! realm.write {
            realm.add(myCitate)
        }
        favItems.add(citate)
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.spacing {
            return value*2
        }
        return value
    }
    
    func parseJSON() {
        let path = Bundle.main.path(forResource: "Citates", ofType: "json")
        let JSONData = try? Data(contentsOf: URL(fileURLWithPath: path!))
        if let JSONResult: NSDictionary = try! JSONSerialization.jsonObject(with: JSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
            let itemsArr = JSONResult["citates"] as! NSArray
            for item in itemsArr {
                itemsArray.add(["title":item["title"] as! String, "author": item["author"] as! String, "favorite": false])
            }
        }
    }
    @IBAction func toggle(_ sender: AnyObject) {
        
        sideMenuViewController?._presentLeftMenuViewController()
    }
    func readFromDB() {
        favItems.removeAllObjects()
        let favs = realm.objects(FavCitates)
        for fav in favs {
            favItems.add(fav)
        }
    }
}

extension Citates: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        citatesView.reloadData()
    }
}
