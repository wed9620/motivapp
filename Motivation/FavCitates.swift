//
//  FavCitates.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 18/04/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import Foundation
import RealmSwift

class FavCitates: Object {
    
    dynamic var title = ""
    dynamic var author = ""
    dynamic var favorite = false
}
