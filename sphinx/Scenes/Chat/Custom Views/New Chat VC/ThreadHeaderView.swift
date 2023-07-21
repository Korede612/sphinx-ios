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
    @IBOutlet weak var initialsLabel: UILabel!
    
    var delegate : ThreadHeaderViewDelegate? = nil
    var isExpanded : Bool = false
    
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
        
        initialsLabel.layer.cornerRadius = initialsLabel.frame.size.height/2
        initialsLabel.clipsToBounds = true
        
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configureWith(
        firstMessage:TransactionMessage,
        delegate:ThreadHeaderViewDelegate
    ){
        self.delegate = delegate
        firstMessageMessageContentLabel.backgroundColor = contentView.backgroundColor
        firstMessageMessageContentLabel.isHidden = false
        firstMessageMessageContentLabel.text = firstMessage.messageContent
        senderNameLabel.text = firstMessage.senderAlias
        timestampLabel.text = firstMessage.date?.getThreadDateTime()
        if let path = firstMessage.senderPic{
            let avatarURL = URL(string: path)
            avatarImageView.sd_setImage(with: avatarURL)
            avatarImageView.makeCircular()
        }
        else{
            initialsLabel.isHidden = false
            //initialsLabel.backgroundColor = firstMessage.senderColor
            initialsLabel.backgroundColor = .green
            initialsLabel.textColor = UIColor.white
            initialsLabel.text = firstMessage.senderAlias?.getInitialsFromName()
        }
        
        imageContainerView.makeCircular()
        avatarImageView.contentMode = .scaleAspectFill
        adjustNumberOfLines()
    }
    
    func adjustNumberOfLines(max:Int=5){
        if(isExpanded){
            firstMessageMessageContentLabel.numberOfLines = 0
            showMoreLabel.isHidden = true
            firstMessageMessageContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTextViewTouched)))
            firstMessageMessageContentLabel.isUserInteractionEnabled = true
            return
        }
        guard let labelText = firstMessageMessageContentLabel.text
        else{
            return
        }
        let width = firstMessageMessageContentLabel.frame.width
        let lineSpacing : CGFloat = 5.0
        let numLines = calculateNumberOfLines(text: labelText, fontSize: firstMessageMessageContentLabel.font.pointSize, lineSpacing: lineSpacing, width: width)
        firstMessageMessageContentLabel.numberOfLines = min(numLines,max)
        
        if numLines >= 5 && isExpanded == false{
            firstMessageMessageContentLabel.lineBreakMode = .byTruncatingTail
            showMoreLabel.isHidden = false
            showMoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMoreTouched)))
            showMoreLabel.isUserInteractionEnabled = true
            firstMessageMessageContentLabel.isUserInteractionEnabled = false
        }
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
