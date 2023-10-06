//
//  StarCollectionViewCell.swift
//  stock Insight
//
//  Created by 이현호 on 2023/05/30.
//

import UIKit

class StarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stockCodeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var percentageLabel: UILabel!
    
    func settingCell(){
        self.percentageLabel.layer.cornerRadius = 10
    }
}
