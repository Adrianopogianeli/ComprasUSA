//
//  StateTableViewCell.swift
//  ComprasUSA
//
//  Created by admin on 4/22/18.
//  Copyright © 2018 Adriano Pogianeli. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {
    

    @IBOutlet weak var lbNome: UILabel!
    
    @IBOutlet weak var lbImposto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
