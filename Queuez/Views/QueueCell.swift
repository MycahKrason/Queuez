//
//  QueueCell.swift
//  Queuez
//
//  Created by Mycah on 8/6/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class QueueCell: UITableViewCell {

    @IBOutlet weak var queueTitle: UILabel!
    @IBOutlet weak var queueSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
