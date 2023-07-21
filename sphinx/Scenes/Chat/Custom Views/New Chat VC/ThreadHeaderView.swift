//
//  ThreadHeaderView.swift
//  sphinx
//
//  Created by James Carucci on 7/19/23.
//  Copyright © 2023 sphinx. All rights reserved.
//

import Foundation
import UIKit


protocol ThreadHeaderViewDelegate : NSObject{
    func didTapShowMore()
    func didTapTextField()
}

class ThreadHeaderView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var firstMessageMessageContentLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var showMoreLabel: UILabel!
    
    var delegate : ThreadHeaderViewDelegate? = nil
    var isExpanded : Bool = false
    let kHeightOffset = 116.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("ThreadHeaderView", owner: self, options: nil)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //contentView.backgroundColor = .green
//        firstMessageMessageContentLabel.backgroundColor = .red
    }
    
    func configureWith(state:MessageTableCellState){
        var stateCopy = state
        if let firstMessage = stateCopy.threadMessageArray?.threadMessages.filter({$0.isOriginalMessage == true}).first{
            firstMessageMessageContentLabel.isHidden = false
            firstMessageMessageContentLabel.backgroundColor = .red
            firstMessageMessageContentLabel.text = firstMessage.previewText
            senderNameLabel.text = firstMessage.senderAlias
            timestampLabel.text = firstMessage.sendDate?.getThreadDateTime()
            avatarImageView.sd_setImage(with: URL(string: firstMessage.senderPic ?? ""))
            avatarImageView.makeCircular()
            imageContainerView.makeCircular()
            avatarImageView.contentMode = .scaleAspectFill
        }
    }
    
    func calculateViewHeight()->CGFloat?{
        guard let height = self.calculateTextHeight(lines: 2, lineSpacing: 5.0) else {
            return nil
        }
        
        let offsetHeight = avatarImageView.frame.maxY + 28.0
        
        return height + offsetHeight
    }
    
    
    func calculateTextHeight(lines: Int, lineSpacing: CGFloat) -> CGFloat? {
        guard let labelText = firstMessageMessageContentLabel.text
        else{
            return nil
        }
        let width = firstMessageMessageContentLabel.frame.width
        let numLines = calculateNumberOfLines(text: labelText, fontSize: firstMessageMessageContentLabel.font.pointSize, lineSpacing: lineSpacing, width: width)
        var height = kHeightOffset + (CGFloat(numLines) * firstMessageMessageContentLabel.font.pointSize)
        if numLines >= 5 && isExpanded == false{
            height = kHeightOffset + (CGFloat(5) * firstMessageMessageContentLabel.font.pointSize)
            firstMessageMessageContentLabel.lineBreakMode = .byTruncatingTail
            showMoreLabel.isHidden = false
            showMoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMoreTouched)))
            showMoreLabel.isUserInteractionEnabled = true
            firstMessageMessageContentLabel.isUserInteractionEnabled = false
        }
        else{
            showMoreLabel.isHidden = true
            firstMessageMessageContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTextViewTouched)))
            firstMessageMessageContentLabel.isUserInteractionEnabled = true
        }
        
        return ceil(height)
    }
    
    func calculateNumberOfLines(text: String, fontSize: CGFloat, lineSpacing: CGFloat, width: CGFloat) -> Int {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Roboto", size: fontSize)!,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        let boundingRect = attributedText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                       context: nil)
        
        let numberOfLines = Int(ceil(boundingRect.height / (fontSize + lineSpacing)))
        return numberOfLines
    }
    
    @objc func handleShowMoreTouched(){
        delegate?.didTapShowMore()
    }
    
    @objc func handleTextViewTouched(){
        delegate?.didTapTextField()
    }
    
}
