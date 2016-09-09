//
//  AuthorVC.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 15/06/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import UIKit

class AuthorVC: UIViewController {
    
    var author: String!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        var url : NSURL!
        navBar.title = author
        switch author {
        case "Билл Гейтс":
            url = NSBundle.mainBundle().URLForResource("heitz", withExtension:"html")
        
            break
        case "Генри Форд":
            url = NSBundle.mainBundle().URLForResource("henry_ford", withExtension:"html")
            break
        case "Джордж Сорос":
            url = NSBundle.mainBundle().URLForResource("Soros", withExtension:"html")
            break
        case "Криштиану Роналду" :
            url = NSBundle.mainBundle().URLForResource("ronaldo", withExtension:"html")
        case "Джон Дэвисон Рокфеллер":
            url = NSBundle.mainBundle().URLForResource("rokfeller", withExtension:"html")
        default:
            break
        }
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
