//
//  ThreadTableDataSource.swift
//  sphinx
//
//  Created by Tomas Timinskas on 02/08/2023.
//  Copyright © 2023 sphinx. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class ThreadTableDataSource : NewChatTableDataSource {
    
    var threadUUID: String!
    var isHeaderExpanded = false
    
    init(
        chat: Chat?,
        contact: UserContact?,
        threadUUID: String,
        tableView: UITableView,
        newMsgIndicator : NewMessagesIndicatorView,
        headerImageView: UIImageView?,
        bottomView: UIView,
        webView: WKWebView,
        delegate: NewChatTableDataSourceDelegate?
    ) {
        
        self.threadUUID = threadUUID
        
        super.init(
            chat: chat,
            contact: contact,
            tableView: tableView,
            newMsgIndicator: newMsgIndicator,
            headerImageView: headerImageView,
            bottomView: bottomView,
            webView: webView,
            delegate: delegate
        )
    }
    
    lazy var threadHeaderHeight: CGFloat? = {
        guard let headerMessageCellState = messageTableCellStateArray.first else {
            return nil
        }
        
        let kDifference:CGFloat = 32.0
        
        return ThreadHeaderTableViewCell.getCellHeightWith(
            messageCellState: headerMessageCellState,
            mediaData: nil
        ) - kDifference
    }()
    
    override func configureTableTransformAndInsets() {
        ///Nothing to do
    }
    
    override func configureTableCellTransformOn(cell: ChatTableViewCellProtocol?) {
        ///Nothing to do
    }
    
    override func loadMoreItems() {
        ///Nothing to do
    }
    
    override func restorePreloadedMessages() {
        ///Nothing to do
    }
    
    override func saveMessagesToPreloader() {
        ///Nothing to do
    }
    
    override func saveSnapshotCurrentState() {
        ///Nothing to do
    }
    
    override func restoreScrollLastPosition() {
        tableView.alpha = 1.0
    }
    
    override func shouldHideNewMsgsIndicator() -> Bool {
        let contentInset: CGFloat = 16
        return (tableView.contentOffset.y > tableView.contentSize.height - tableView.frame.size.height - contentInset) || tableView.alpha == 0
    }
    
    override func makeCellProvider(
        for tableView: UITableView
    ) -> DataSource.CellProvider {
        { (tableView, indexPath, dataSourceItem) -> UITableViewCell in
            return self.getThreadCellFor(
                dataSourceItem: dataSourceItem,
                indexPath: indexPath
            )
        }
    }
}
