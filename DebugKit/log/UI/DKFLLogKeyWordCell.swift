//
//  DKFLLogKeyWordCell.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/7.
//

import UIKit

enum DKFLLogKeyWordCellType {
    case normal
    case select
    case reject
}

class DKFLLogKeyWordCell: UICollectionViewCell {

    static let cellName = "DKFLLogKeyWordCell"
    @IBOutlet weak var title: UILabel!
    private(set) var type: DKFLLogKeyWordCellType = .normal
    
    var longPress: UILongPressGestureRecognizer?
    var longPressCallback: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.layer.cornerRadius = 15;
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction)))
        
    }
    
    func setType(type: DKFLLogKeyWordCellType) {
        switch type {
        case .normal:
            self.title.textColor = UIColor.systemBlue
            self.contentView.backgroundColor = UIColor.clear
            self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
        case .select:
            self.title.textColor = UIColor.white
            self.contentView.backgroundColor = UIColor.systemBlue
            self.contentView.layer.borderColor = UIColor.clear.cgColor
        case .reject:
            self.title.textColor = UIColor.lightText
            self.contentView.backgroundColor = UIColor.lightGray
            self.contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @objc func longPressAction() {
        if let longPressCallback = self.longPressCallback {
            longPressCallback()
        }
    }
}

extension DKFLLogKeyWordCell {
    static func cellH(keyword: String) -> CGFloat {
        let rect = NSString(string: keyword).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: 30),
                                                          options: .usesLineFragmentOrigin,
                                               attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil)
        var width = rect.size.width + 10
        if width < 30 {
            width = 30
        }
        
        return width
    }
}
