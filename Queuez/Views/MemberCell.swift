//
//  MemberCell.swift
//  Queuez
//
//  Created by Mycah on 8/12/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var queueNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
