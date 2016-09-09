//
//  ToDoCell.swift
//  
//
//  Created by Сергей Шинкаренко on 12/05/16.
//
//

import UIKit
import MGSwipeTableCell

class ToDoCell: MGSwipeTableCell{

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var toDo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
