//
//  MemberBadgeDetailTableViewCell..swift
//  sphinx
//
//  Created by James Carucci on 1/30/23.
//  Copyright © 2023 sphinx. All rights reserved.
//

import UIKit

class MemberBadgeDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK: - Static Properties
extension MemberBadgeDetailTableViewCell {
    static let reuseID = "MemberBadgeDetailTableViewCell"
    
    static let nib: UINib = {
        UINib(nibName: "MemberBadgeDetailTableViewCell", bundle: nil)
    }()
}
