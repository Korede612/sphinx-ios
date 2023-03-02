//
//  AppDelegate.swift
//  sphinx
//
//  Created by Tomas Timinskas on 12/09/2019.
//  Copyright © 2019 Sphinx. All rights reserved.
//

import UIKit
import UserNotifications
import StoreKit
import SDWebImage
import Alamofire
import GiphyUISDK
import BackgroundTasks
import AVFAudio
import SDWebImageSVGCoder
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var launchingVC = false
    var style : UIUserInterfaceStyle? = nil

    var notificationUserInfo : [String: AnyObject]? = nil

    var backgroundSessionCompletionHandler: (() -> Void)?
    
    let onionConnector = SphinxOnionConnector.sharedInstance
    
    let newMessageBubbleHelper = NewMessageBubbleHelper()
    
    let actionsManager = ActionsManager.sharedInstance
    let feedsManager = FeedsManager.sharedInstance
    
    let podcastPlayerController = PodcastPlayerController.sharedInstance
    
    let chatListViewModel = ChatListViewModel(contactsService: ContactsService())

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        
        if UIDevice.current.isIpad {
            return .allButUpsideDown
        }

        if WindowsManager.sharedInstance.shouldRotateOrientation() {
            return .allButUpsideDown
        }

        return .portrait
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = CGFloat(0)
        }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        
        setAppConfiguration()
        registerAppRefresh()
        configureGiphy()
        configureNotificationCenter()
        configureStoreKit()
        configureSVGRendering()
        connectTor()
        
        setInitialVC(launchingApp: true)
        
        registerForVoIP()
        print(print("Device ID:\(UserDefaults.Keys.deviceId.get(defaultValue: ""))"))

        return true
    }
    
    func setAppConfiguration() {
        Constants.setSize()
        window?.setStyle()
        saveCurrentStyle()
    }
    
    func registerAppRefresh() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.gl.sphinx.refresh", using: nil, launchHandler: { task in
            self.handleAppRefresh(task: task)
        })
    }
    
    func configureSVGRendering(){
        // register coder, on AppDelegate
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
        
    }
    
    func configureGiphy() {
        if let GIPHY_API_KEY = Bundle.main.object(forInfoDictionaryKey: "GIPHY_API_KEY") as? String {
            Giphy.configure(apiKey: GIPHY_API_KEY)
        }
    }
    
    func configureNotificationCenter() {
        notificationUserInfo = nil
        UNUserNotificationCenter.current().delegate = self
    }
    
    func configureStoreKit() {
        SKPaymentQueue.default().add(StoreKitService.shared)
    }
    
    func syncDeviceId() {
        UserContact.syncDeviceId()
    }
    
    func getRelayKeys() {
        UserData.sharedInstance.getAndSaveTransportKey()
        UserData.sharedInstance.getOrCreateHMACKey()
    }
    
    func handleAppRefresh(task: BGTask) {
        scheduleAppRefresh()
        
        chatListViewModel.loadFriends { _ in
            self.chatListViewModel.syncMessages(
                progressCallback: { _ in },
                completion: { (_, _) in
                    task.setTaskCompleted(success: true)
                },
                errorCompletion: {
                    task.setTaskCompleted(success: true)
                }
            )
        }
    }
    
    fileprivate func registerForVoIP(){
        let registry = PKPushRegistry(queue: .main)
        DispatchQueue.main.async {
            registry.delegate = UIApplication.shared.delegate as! AppDelegate
        }
        registry.desiredPushTypes = [PKPushType.voIP]
    }
    
    
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.gl.sphinx.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh \(error)")
        }
    }

    func connectTor() {
        if !SignupHelper.isLogged() { return }

        if !onionConnector.usingTor() {
            return
        }
        onionConnector.startTor(delegate: self)
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        if DeepLinksHandlerHelper.storeLinkQueryFrom(url: url) {
            setInitialVC(launchingApp: false, deepLink: true)
        }
        return true
    }

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        backgroundSessionCompletionHandler = completionHandler
    }

    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {
        saveCurrentStyle()
        WindowsManager.sharedInstance.removeMessageOptions()
        setBadge(application: application)
        
        podcastPlayerController.finishAndSaveContentConsumed()
        
        actionsManager.syncActionsInBackground()
        feedsManager.saveContentFeedStatus()
        
        CoreDataManager.sharedManager.saveContext()
        
        scheduleAppRefresh()
    }

    func applicationWillEnterForeground(
        _ application: UIApplication
    ) {
        notificationUserInfo = nil

        if !UserData.sharedInstance.isUserLogged() {
            return
        }
        
        reloadMessagesData()
        presentPINIfNeeded()
        
        feedsManager.restoreContentFeedStatusInBackground()
        podcastPlayerController.finishAndSaveContentConsumed()
    }

    func saveCurrentStyle() {
        if #available(iOS 13.0, *) {
            style = UITraitCollection.current.userInterfaceStyle
        }
    }
    
    func handleIncomingCall(chatID:Int,callerName:String){
        if #available(iOS 14.0, *) {
            let callManager = JitsiIncomingCallManager.sharedInstance
            callManager.chatID = chatID
            callManager.reportIncomingCall(id: UUID(), handle: callerName)
        }
        
    }
    
    func handleAcceptedCall(callLink:String){
        VideoCallManager.sharedInstance.startVideoCall(link: callLink, audioOnly: true)
    }

    func reloadAppIfStyleChanged() {
        if #available(iOS 13.0, *) {
            guard let _ = UIWindow.getSavedStyle() else {
                if style != UIScreen.main.traitCollection.userInterfaceStyle {
                    style = UIScreen.main.traitCollection.userInterfaceStyle

                    let isUserLogged = UserData.sharedInstance.isUserLogged()
                    takeUserToInitialVC(isUserLogged: isUserLogged)
                }
                return
            }
        }
    }

    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        reloadAppIfStyleChanged()
        
        if !UserData.sharedInstance.isUserLogged() {
            return
        }
        
        SphinxSocketManager.sharedInstance.connectWebsocket(forceConnect: true)

        if let notification = notificationUserInfo {
            handlePush(notification: notification)
            setInitialVC(launchingApp: false)
        }
    }


    func applicationWillTerminate(
        _ application: UIApplication
    ) {
        setBadge(application: application)

        SKPaymentQueue.default().remove(StoreKitService.shared)

        podcastPlayerController.finishAndSaveContentConsumed()
        CoreDataManager.sharedManager.saveContext()
    }

    func setInitialVC(
        launchingApp: Bool,
        deepLink: Bool = false
    ) {
        if launchingVC {
            return
        }
        launchingVC = true

        let isUserLogged = UserData.sharedInstance.isUserLogged()

        if shouldStayInView(launchingApp: launchingApp) && !deepLink {
            reloadMessagesData()
            launchingVC = false
            return
        }
        
        if isUserLogged {
            syncDeviceId()
            getRelayKeys()
            feedsManager.restoreContentFeedStatusInBackground()
        }

        takeUserToInitialVC(isUserLogged: isUserLogged)
        presentPINIfNeeded()
    }

    func presentPINIfNeeded() {
        if GroupsPinManager.sharedInstance.shouldAskForPin() {
            let pinVC = PinCodeViewController.instantiate()
            WindowsManager.sharedInstance.showConveringWindowWith(rootVC: pinVC)
        }
    }

    func takeUserToInitialVC(
        isUserLogged: Bool
    ) {
        hideAccessoryView()

        let rootViewController = StoryboardScene.Root.initialScene.instantiate()
        let mainCoordinator = MainCoordinator(rootViewController: rootViewController)

        if let window = window {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }

        if isUserLogged {
            mainCoordinator.presentInitialDrawer()
        } else {
            window?.setDarkStyle()
            mainCoordinator.presentSignUpScreen()
        }

        launchingVC = false
    }

    func shouldStayInView(
        launchingApp: Bool
    ) -> Bool {
        let isUserLogged = UserData.sharedInstance.isUserLogged()
        let shouldTakeToChat = UserDefaults.Keys.chatId.get(defaultValue: -1) >= 0
        let shouldTakeToSubscription = UserDefaults.Keys.subscriptionQuery.get(defaultValue: "") != ""

        if isUserLogged && !launchingApp && !shouldTakeToChat && !shouldTakeToSubscription {
            UserDefaults.Keys.chatId.removeValue()
            return true
        }

        if shouldTakeToChat && isOnSameChatAsPush() {
            UserDefaults.Keys.chatId.removeValue()
            return true
        }

        if (shouldTakeToChat || shouldTakeToSubscription) && isOnChatList() {
            return true
        }

        return false
    }

    func isOnSameChatAsPush() -> Bool {
        let chatId = UserDefaults.Keys.chatId.get(defaultValue: -1)

        if let currentVC = getCurrentVC() as? ChatViewController, let currentVCChatId = currentVC.chat?.id, currentVCChatId == chatId {
            return true
        }
        return false
    }

    func isOnChatList() -> Bool {
        getCurrentVC() is DashboardRootViewController
    }

    func hideAccessoryView() {
        if let currentVC = getCurrentVC() as? ChatViewController {
            currentVC.accessoryView.hide()
        }
    }

    func getCurrentVC() -> UIViewController? {
        let rootVC = window?.rootViewController

        if let rootVController = rootVC as? RootViewController, let currentVC = rootVController.getLastCenterViewController() {
            return currentVC
        }
        return nil
    }

    func goToSupport() {
        if let roowVController = window?.rootViewController as? RootViewController, let leftMenuVC = roowVController.getLeftMenuVC() {
            leftMenuVC.goToSupport()
        }
    }

    func reloadDashboard() {
        reloadMessagesData()
    }

    func reloadMessagesData() {
        if let currentVC = getCurrentVC() {
            if let currentVC = currentVC as? ChatViewController {
                UserDefaults.Keys.chatId.removeValue()
                currentVC.fetchNewData()
            } else if let dashboardRootVC = currentVC as? DashboardRootViewController {
                
                let shouldDeepLinkIntoChatDetails =
                    UserDefaults.Keys.chatId.get(defaultValue: -1) >= 0 ||
                    UserDefaults.Keys.contactId.get(defaultValue: -1) >= 0

                if shouldDeepLinkIntoChatDetails {
                    dashboardRootVC.handleDeepLinksAndPush()
                } else {
                    dashboardRootVC.loadContactsAndSyncMessages(
                        shouldShowHeaderLoadingWheel: true
                    )
                }
            }
        }
    }

    func setBadge(
        application: UIApplication
    ) {
        application.applicationIconBadgeNumber = TransactionMessage.getReceivedUnseenMessagesCount()
    }

    func setMessagesAsSeen() {
        if let rootVController = window?.rootViewController as? RootViewController,
           let currentVC = rootVController.getLastCenterViewController() as? ChatViewController,
           let currentChat = currentVC.chat {
            currentChat.setChatMessagesAsSeen()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if application.applicationState == .background {
            self.chatListViewModel.syncMessages(
                onPushReceived: true,
                progressCallback: { _ in },
                completion: { (_, _) in
                    completionHandler(.newData)
                },
                errorCompletion: {
                    completionHandler(.noData)
                }
            )
        } else {
            completionHandler(.noData)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if UIApplication.shared.applicationState == .inactive, response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            notificationUserInfo = response.notification.request.content.userInfo as? [String: AnyObject]
        }
        completionHandler()
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        UserContact.updateDeviceId(deviceId: token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }

    func registerForPushNotifications() {
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.getNotificationSettings { settings in
            notificationsCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func handlePush(
        notification: [String: AnyObject]
    ) {
        if let aps = notification["aps"] as? [String: AnyObject],
            let customData = aps["custom_data"] as? [String: AnyObject] {
            if let chatId = customData["chat_id"] as? Int {
                UserDefaults.Keys.chatId.set(chatId)
            }
        }
        notificationUserInfo = nil
    }
}

extension AppDelegate : SphinxOnionConnectorDelegate {
    func onionConnecting() {
        newMessageBubbleHelper.showLoadingWheel(text: "establishing.tor.circuit".localized)
    }
    
    func onionConnectionFinished() {
        newMessageBubbleHelper.hideLoadingWheel()
        
        SphinxSocketManager.sharedInstance.reconnectSocketOnTor()
        reloadDashboard()
    }

    func onionConnectionFailed() {
        newMessageBubbleHelper.hideLoadingWheel()
        newMessageBubbleHelper.showGenericMessageView(text: "tor.connection.failed".localized)
        
        NotificationCenter.default.post(name: .onConnectionStatusChanged, object: nil)
    }
}

extension AppDelegate : PKPushRegistryDelegate{
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == PKPushType.voIP {
            let tokenData = pushCredentials.token
            let deviceToken: String = tokenData.reduce("", {$0 + String(format: "%02X", $1) })
            UserContact.updateVoipDeviceId(deviceId: deviceToken)
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if let dict = payload.dictionaryPayload as? [String:Any],
           let aps = dict["aps"] as? [String:Any],
           let contents = aps["alert"] as? String,
           let pushMessage = VoIPPushMessage.voipMessage(jsonString: contents),
           let pushBody = pushMessage.body as? VoIPPushMessageBody {
           
            if #available(iOS 14.0, *) {
                let manager = JitsiIncomingCallManager.sharedInstance
                
                let (result, link) = EncryptionManager.sharedInstance.decryptMessage(message: pushBody.linkURL)
                manager.currentJitsiURL = (result == true) ? link : pushBody.linkURL
                pushBody.linkURL = link
                
                manager.provider.configuration.supportsVideo = pushBody.isVideoCall()
                self.handleIncomingCall(chatID: 0, callerName: pushBody.callerName)
            }
            completion()
        } else {
            completion()
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("invalidated token")
    }
}



