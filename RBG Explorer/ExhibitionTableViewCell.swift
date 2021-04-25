//
//  ExhibitionTableViewCell.swift
//  RBG Explorer
//
//  Created by Weiyi Kong on 11/9/20.
//  Copyright © 2020 Weiyi Kong. All rights reserved.
//

import UIKit

class ExhibitionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
