//
//  NewChatViewController+MentionsAutocomplete.swift
//  sphinx
//
//  Created by Tomas Timinskas on 30/05/2023.
//  Copyright © 2023 sphinx. All rights reserved.
//

import UIKit

extension NewChatViewController: ChatMentionAutocompleteDelegate {
    
    func configureMentions() {
        chat?.processAliases()
        configureMentionAutocompleteTableView()
    }
    
    func didDetectPossibleMention(
        mentionText: String
    ) {
        //Test this logic and chat aliases
        let possibleMentions = self.chat?.aliases.filter({
            if (mentionText.count > $0.count) {
                return false
            }
            let substring = $0.substring(range: NSRange(location: 0, length: mentionText.count))
            return (substring.lowercased() == mentionText && mentionText != "")
        }).sorted()
        
        if let datasource = chatMentionAutocompleteDataSource, let mentions = possibleMentions {
            datasource.updateMentionSuggestions(suggestions: mentions)
        }
    }
    
    func configureMentionAutocompleteTableView() {
        mentionsAutocompleteTableView.isHidden = true
        
        chatMentionAutocompleteDataSource = ChatMentionAutocompleteDataSource(
            tableView: mentionsAutocompleteTableView,
            delegate: self
        )
        
        mentionsAutocompleteTableView.delegate = chatMentionAutocompleteDataSource
        mentionsAutocompleteTableView.dataSource = chatMentionAutocompleteDataSource
    }
    
    func processAutocomplete(text: String) {
        bottomView.populateMentionAutocomplete(mention: text)
//        NotificationCenter.default.post(name: NSNotification.Name.autocompleteMention, object: text)
    }
}
