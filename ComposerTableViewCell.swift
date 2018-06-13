//
//  ComposerTableViewCell.swift
//  composers
//
//  Created by Maya McAuliffe on 6/11/18.
//  Copyright © 2018 Maya McAuliffe. All rights reserved.
//

import UIKit

class ComposerTableViewCell: UITableViewCell {
    // Mark: Properties
    @IBOutlet weak var nameButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
