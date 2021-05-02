//
//  SendQuoteTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-02.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class SendQuoteTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
    }
}
