//
//  HabitColorCell.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class HabitColorCell: UICollectionViewCell {
    static var reuseId = "HabitColorCell"
    
    private let colorViewSize: CGFloat = 40.0
    private let centerOffset: CGFloat = 2.0
    
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.frame = CGRect(
            x: (contentView.bounds.width - colorViewSize) / centerOffset,
            y: (contentView.bounds.height - colorViewSize) / centerOffset,
            width: colorViewSize,
            height: colorViewSize
        )
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
}
