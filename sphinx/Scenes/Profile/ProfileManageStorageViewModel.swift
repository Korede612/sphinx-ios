//
//  ProfileManageStorageViewModel.swift
//  sphinx
//
//  Created by James Carucci on 5/22/23.
//  Copyright © 2023 sphinx. All rights reserved.
//

import Foundation
import UIKit

class ProfileManageStorageViewModel : NSObject{
    var vc : ProfileManageStorageViewController
    var tableView:UITableView
    var mediaTypes = StorageManagerMediaType.allCases
    var stats = [StorageManagerMediaType:Double]()
    
    init(
        vc:ProfileManageStorageViewController,
        tableView:UITableView
    ){
        self.vc = vc
        self.tableView = tableView
    }
    
    func finishSetup(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MediaStorageTypeSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: MediaStorageTypeSummaryTableViewCell.reuseID)
    }
    
    
}

extension ProfileManageStorageViewModel : UITableViewDelegate,UITableViewDataSource, MediaStorageTypeSummaryTableViewCellDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MediaStorageTypeSummaryTableViewCell.reuseID,
            for: indexPath
        ) as! MediaStorageTypeSummaryTableViewCell
        cell.delegate = self
        cell.finishSetup()
        cell.setupAsMediaType(type: mediaTypes[indexPath.row])
        cell.storageAmountLabel.text = formatBytes(Int(loadMediaSize(forType: mediaTypes[indexPath.row]) ?? 0))
        vc.isLoading == true ? (cell.showLoading()) : (cell.hideLoading())
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Specify the desired height for your cells
        return 64.0 // Adjust this value according to your requirements
    }
    
    func loadMediaSize(forType:StorageManagerMediaType)->Double?{
        var result : Double? = nil
        result = (stats[forType] ?? 0) * 1e6
        return result
    }
    
    func didTapDelete(type: StorageManagerMediaType) {
        var typeString : String? = nil
        switch(type){
            case .audio:
                typeString = "audio files"//StorageManager TODO: replace with localization for each
                break
            case .video:
                typeString = "video"
                break
            case .photo:
                typeString = "images"
                break
        }
        
        AlertHelper.showTwoOptionsAlert(
            title: "Are you sure?",
            message: "Continuing will delete all of your \(typeString ?? "media files").",
            confirmButtonTitle: "Yes",
            cancelButtonTitle: "Cancel",
            confirm: {
                self.handleDeletion(type: type)
        }) //StorageManager TODO
    }
    
    func handleDeletion(type:StorageManagerMediaType){
        vc.setIsLoading()
        switch(type){
        case .audio:
            StorageManager.sharedManager.deleteAllAudioFiles(completion: {
                StorageManager.sharedManager.refreshAllStoredData(completion: {
                    self.refreshData()
                    self.vc.resetIsLoading()
                })
            })
            break
        case .video:
            
            break
        case .photo:
            StorageManager.sharedManager.deleteAllImages(completion: {
                StorageManager.sharedManager.refreshAllStoredData(completion: {
                    self.refreshData()
                    self.vc.resetIsLoading()
                })
            })
            break
        }
        print("delete all of \(type)")
    }
    
    func refreshData(){
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.stats = StorageManager.sharedManager.getStorageItemSummaryByType()
            self.vc.updateUsageLabels()
            self.vc.storageSummaryView.summaryDict = self.stats
            self.tableView.reloadData()
        //})
        
    }
}
