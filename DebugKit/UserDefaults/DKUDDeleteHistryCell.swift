//
//  DKUDDeleteHistryCell.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/10/12.
//

import UIKit

class DKUDDeleteHistryCell: UICollectionViewCell {

    static let cellName = "DKUDDeleteHistryCell"
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.layer.cornerRadius = 15;
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
    }
}

extension DKUDDeleteHistryCell {
    static func cellW(SearchText: String) -> CGFloat {
        let rect = NSString(string: SearchText).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: 30),
                                                          options: .usesLineFragmentOrigin,
                                               attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil)
        var width = rect.size.width + 10
        if width < 30 {
            width = 30
        }
        
        return width
    }
}
