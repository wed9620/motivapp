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
        var url : URL!
        navBar.title = author
        switch author {
        case "Билл Гейтс":
            url = Bundle.main.url(forResource: "heitz", withExtension:"html")
        
            break
        case "Генри Форд":
            url = Bundle.main.url(forResource: "henry_ford", withExtension:"html")
            break
        case "Джордж Сорос":
            url = Bundle.main.url(forResource: "Soros", withExtension:"html")
            break
        case "Криштиану Роналду" :
            url = Bundle.main.url(forResource: "ronaldo", withExtension:"html")
        case "Джон Дэвисон Рокфеллер":
            url = Bundle.main.url(forResource: "rokfeller", withExtension:"html")
        default:
            break
        }
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
