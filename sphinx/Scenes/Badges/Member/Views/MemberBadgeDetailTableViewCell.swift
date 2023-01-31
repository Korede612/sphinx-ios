//
//  MemberBadgeDetailTableViewCell..swift
//  sphinx
//
//  Created by James Carucci on 1/30/23.
//  Copyright © 2023 sphinx. All rights reserved.
//

import UIKit

public enum MemberBadgeDetailCellType{
    case badges
    case posts
    case contributions
    case earnings
}

class MemberBadgeDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(type:MemberBadgeDetailCellType){
        switch(type){
        case .badges:
            titleLabel.text = "Badges:"
            break
        case .contributions:
            titleLabel.text = "Contributions:"
            break
        case .earnings:
            titleLabel.text = "Earnings:"
            break
        case .posts:
            titleLabel.text = "Posts:"
            break
        }
        
        configureStackView(type: type)
    }
    
    func configureStackView(type:MemberBadgeDetailCellType){
        switch(type){
            case .contributions:
                let satsLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 97.0, height: stackView.frame.height))
                let satsString = "5000 sats"
                let numLength = satsString.count - "sats".count
                let satsLabelAttributedText = NSMutableAttributedString(string: satsString)
                satsLabelAttributedText.addAttribute(.foregroundColor, value: UIColor.Sphinx.BlueTextAccent, range: NSRange(location: satsString.distance(from: String.Index(utf16Offset: 0, in: satsString), to: String.Index(utf16Offset: 0, in: satsString)), length: numLength))
                
                satsLabelAttributedText.addAttribute(.font,value: UIFont(name: "Roboto", size: 15.0), range: NSRange(location: satsString.distance(from: String.Index(utf16Offset: 0, in: satsString), to: String.Index(utf16Offset: 0, in: satsString)), length: satsString.count))
                satsLabel.attributedText = satsLabelAttributedText
                satsLabel.textAlignment = .right
                stackView.addSubview(satsLabel)
                
                
                stackView.translatesAutoresizingMaskIntoConstraints = false
                let rankLabel = UILabel(frame: CGRect(x: satsLabel.frame.width, y: 0.0, width: 34.0, height: stackView.frame.height))
                rankLabel.text = "6th"
                rankLabel.font = UIFont(name: "Roboto", size: 15.0)
                rankLabel.textAlignment = .right
                rankLabel.textColor = UIColor.Sphinx.SecondaryText
                stackView.addSubview(rankLabel)
                
                stackViewWidth.constant = rankLabel.frame.width + satsLabel.frame.width
                self.layoutIfNeeded()
                break
            case .earnings:
                let satsLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 97.0, height: stackView.frame.height))
                let satsString = "3000 sats"
                let numLength = satsString.count - "sats".count
                let satsLabelAttributedText = NSMutableAttributedString(string: satsString)
                satsLabelAttributedText.addAttribute(.foregroundColor, value: UIColor.Sphinx.PrimaryGreen, range: NSRange(location: satsString.distance(from: String.Index(utf16Offset: 0, in: satsString), to: String.Index(utf16Offset: 0, in: satsString)), length: numLength))
                
                satsLabelAttributedText.addAttribute(.font,value: UIFont(name: "Roboto", size: 15.0), range: NSRange(location: satsString.distance(from: String.Index(utf16Offset: 0, in: satsString), to: String.Index(utf16Offset: 0, in: satsString)), length: satsString.count))
                satsLabel.attributedText = satsLabelAttributedText
                satsLabel.textAlignment = .right
                stackView.addSubview(satsLabel)
                
                
                stackView.translatesAutoresizingMaskIntoConstraints = false
                let rankLabel = UILabel(frame: CGRect(x: satsLabel.frame.width, y: 0.0, width: 34.0, height: stackView.frame.height))
                rankLabel.text = "8th"
                rankLabel.font = UIFont(name: "Roboto", size: 15.0)
                rankLabel.textAlignment = .right
                rankLabel.textColor = UIColor.Sphinx.SecondaryText
                stackView.addSubview(rankLabel)
                
                
                stackViewWidth.constant = rankLabel.frame.width + satsLabel.frame.width
                self.layoutIfNeeded()
                break
            case .badges:
                let imageUrls : [String] = [
                    "https://i.ibb.co/Ch8mwg0/badge-Example.png",
                    "https://i.ibb.co/0Bs3Xsk/badge-example2.png",
                    "https://i.ibb.co/FJXZfSf/example3.png"
                ]
                let imageWidth : CGFloat = 40.0
                let imageSpacing : CGFloat = 8.0
                var cursorValue : CGFloat = 0.0
                stackView.translatesAutoresizingMaskIntoConstraints = false
            
                for imageUrl in imageUrls{
                    let image1 = UIImageView(frame: CGRect(x: cursorValue, y: 0.0, width: imageWidth, height: 40.0))
                    image1.sd_setImage(with: URL(string: imageUrl))
                    image1.makeCircular()
                    stackView.addSubview(image1)
                    
                    cursorValue += (imageWidth + imageSpacing)
                }
            
                if(imageUrls.count >= 3){
                    let bubble = UIView(frame: CGRect(x: cursorValue, y: 0.0, width: imageWidth, height: 40.0))
                    bubble.backgroundColor = UIColor.Sphinx.MainBottomIcons
                    let bubbleLabel = UILabel(frame: bubble.bounds)
                    bubbleLabel.text = "+3"
                    bubbleLabel.textColor = UIColor.Sphinx.BodyInverted
                    bubbleLabel.textAlignment = .center
                    bubble.makeCircular()
                    bubble.addSubview(bubbleLabel)
                    stackView.addSubview(bubble)
                    cursorValue += (imageWidth + imageSpacing)
                }
                
                stackViewWidth.constant = cursorValue
                self.layoutIfNeeded()
                break
            case .posts:
                stackView.translatesAutoresizingMaskIntoConstraints = false
                    let postsLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 48.0, height: stackView.frame.height))
                    postsLabel.text = "150"
                    postsLabel.font = UIFont(name: "Roboto", size: 15.0)
                    postsLabel.textColor = UIColor.Sphinx.BodyInverted
                    postsLabel.textAlignment = .right
                stackView.addSubview(postsLabel)
                stackViewWidth.constant = postsLabel.frame.width
                self.layoutIfNeeded()
                break
        }
    }
    
}

// MARK: - Static Properties
extension MemberBadgeDetailTableViewCell {
    static let reuseID = "MemberBadgeDetailTableViewCell"
    
    static let nib: UINib = {
        UINib(nibName: "MemberBadgeDetailTableViewCell", bundle: nil)
    }()
}
