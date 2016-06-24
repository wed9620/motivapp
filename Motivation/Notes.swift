//
//  Notes.swift
//  Motivation
//
//  Created by Сергей Шинкаренко on 27/03/16.
//  Copyright © 2016 Sergei Shinkarenko. All rights reserved.
//

import Foundation
import RealmSwift

class Notes: Object {
    
    dynamic var title = String()
    dynamic var desc = String()
}

class Templates: Object {
    
    dynamic var title = String()
    dynamic var desc = String()
}
