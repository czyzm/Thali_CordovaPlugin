//
//  Thali CordovaPlugin
//  AppContext.swift
//
//  Copyright (C) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//

import CoreBluetooth
import Foundation
import ThaliCore

public typealias ClientConnectCallback = (String, [String : AnyObject]) -> Void

@objc public protocol AppContextDelegate: class, NSObjectProtocol {
    /**
     Notifies about context's peer changes

     - parameter peers:   array of changed peers
     - parameter context: related AppContext
     */
    func context(context: AppContext, didChangePeerAvailability peers: Array<[String : AnyObject]>)

    /**
     Notifies about network status changes

     - parameter status:  dictionary with current network availability status
     - parameter context: related AppContext
     */
    func context(context: AppContext, didChangeNetworkStatus status: [String : AnyObject])

    /**
     Notifies about peer advertisement update

     - parameter discoveryAdvertisingState: dictionary with information about peer's state
     - parameter context:                   related AppContext
     */
    func context(context: AppContext, didUpdateDiscoveryAdvertisingState discoveryAdvertisingState: [String : AnyObject])

    /**
     Notifies about failing connection to port

     - parameter port:      port failed to connect
     - parameter context: related AppContext
     */
    func context(context: AppContext, didFailIncomingConnectionToPort port: UInt16)

    /**
     Notifies about entering background

     - parameter context: related AppContext
     */
    func appWillEnterBackground(withContext context: AppContext)

    /**
     Notifies about entering foreground

     - parameter context: related AppContext
     */
    func appDidEnterForeground(withContext context: AppContext)
}

/// Interface for communication between native and cross-platform parts
@objc public final class AppContext: NSObject {
    /// delegate for AppContext's events
    public weak var delegate: AppContextDelegate?
    private let appNotificationsManager: ApplicationStateNotificationsManager
    private var networkChangedRegistered: Bool = false

    private var bluetoothManager: CBCentralManager?

    private func updateNetworkStatus() {

        enum RadioState: String {
            case On = "on"
            case Off = "off"
            case Unavailable = "unavailable"
            case NotHere = "notHere"
            case DoNotCare = "doNotCare"
        }

        var bluetoothState = RadioState.Unavailable
        var bluetoothLowEnergyState = RadioState.Unavailable
        var wifiState = RadioState.Unavailable
        let cellularState = RadioState.DoNotCare

        if (nil != bluetoothManager) {
            switch bluetoothManager!.state {
            case .PoweredOn:
                bluetoothState = .On
                bluetoothLowEnergyState = .On
            case .PoweredOff:
                bluetoothState = .Off
                bluetoothLowEnergyState = .Off
            case .Unsupported:
                bluetoothState = .NotHere
                bluetoothLowEnergyState = .NotHere
            default:
                bluetoothState = .Unavailable
                bluetoothLowEnergyState = .Unavailable
            }
        }

        let wifiEnabled = NetworkReachability().isWiFiEnabled()
        let wifiConnected = NetworkReachability().isWiFiConnected()

        wifiState = wifiEnabled ? .On : .Off

        let bssid = ((wifiState == .On) && wifiConnected) ? NetworkReachability().BSSID() : "null"

        let networkStatus = [
            "wifi"              : wifiState.rawValue,
            "bluetooth"         : bluetoothState.rawValue,
            "bluetoothLowEnergy": bluetoothLowEnergyState.rawValue,
            "cellular"          : cellularState.rawValue,
            "bssid"             : bssid
        ]

        delegate?.context(self, didChangeNetworkStatus: networkStatus)
    }

    public override init() {
        appNotificationsManager = ApplicationStateNotificationsManager()
        super.init()
        appNotificationsManager.didEnterForegroundHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.appDidEnterForeground(withContext: strongSelf)
        }
        appNotificationsManager.willEnterBackgroundHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.appWillEnterBackground(withContext: strongSelf)
        }

        #if TEST
            // We use background queue because CI tests use main_queue synchronously
            // Otherwise we won't be able to get centralManager state.
            let centralManagerDispathQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        #else
            let centralManagerDispathQueue = nil
        #endif
        bluetoothManager = CBCentralManager(delegate: self, queue: centralManagerDispathQueue)
    }

    /**
     Start the client components

     - returns: true if successful
     */
    public func startListeningForAdvertisements() -> Bool {
        return false
    }

    /**
     Stop the client components

     - returns: true if successful
     */
    public func stopListeningForAdvertisements() -> Bool {
        return false
    }

    /**
     Start the server components

     - parameter port: server port to listen
     - returns: true if successful
     */
    public func startUpdateAdvertisingAndListening(withServerPort port: UInt16) -> Bool {
        return false
    }

    /**
     Stop the client components

     - returns: true if successful
     */
    public func stopListening() -> Bool {
        return false
    }

    /**
     Stop the server components

     - returns: true if successful
     */
    public func stopAdvertisingAndListening() -> Bool {
        return false
    }

    /**
     try to establish connection with peer and open TCP listener

     - parameter peer: identifier of peer to connect
     - parameter callback: callback with connection results.
     */
    public func connectToPeer(peer: String, callback:ClientConnectCallback) {

    }

    /**

     Kill connection without cleanup - Testing only !!

     - parameter peerIdentifier: identifier of peer to kill connection

     - returns: true if successful
     */
    public func killConnection(peerIdentifier: String) -> Bool {
        return false
    }

    public func getIOSVersion() -> String {
        return NSProcessInfo().operatingSystemVersionString
    }
    
    public func didRegisterToNative(function: String) {
        if function == AppContext.networkChanged() {
            updateNetworkStatus()
        }
    }
    

#if TEST
    func executeNativeTests() -> String {
        let runner = TestRunner.`default`
        runner.runTest()
        return runner.resultDescription ?? ""
    }
#endif

}

// MARK: CBCentralManagerDelegate
extension AppContext: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(central: CBCentralManager) {}
}

/// Node functions names
extension AppContext {
    @objc public class func networkChanged() -> String {
        return "networkChanged"
    }

    @objc public class func peerAvailabilityChanged() -> String {
        return "peerAvailabilityChanged"
    }

    @objc public class func appEnteringBackground() -> String {
        return "appEnteringBackground"
    }

    @objc public class func appEnteredForeground() -> String {
        return "appEnteredForeground"
    }

    @objc public class func discoveryAdvertisingStateUpdateNonTCP() -> String {
        return "discoveryAdvertisingStateUpdateNonTCP"
    }

    @objc public class func incomingConnectionToPortNumberFailed() -> String {
        return "incomingConnectionToPortNumberFailed"
    }

    @objc public class func executeNativeTests() -> String {
        return "executeNativeTests"
    }

    @objc public class func getOSVersion() -> String {
        return "getOSVersion"
    }

    @objc public class func didRegisterToNative() -> String {
        return "didRegisterToNative"
    }

    @objc public class func killConnections() -> String {
        return "killConnections"
    }

    @objc public class func connect() -> String {
        return "connect"
    }

    @objc public class func stopAdvertisingAndListening() -> String {
        return "stopAdvertisingAndListening"
    }

    @objc public class func startUpdateAdvertisingAndListening() -> String {
        return "startUpdateAdvertisingAndListening"
    }

    @objc public class func stopListeningForAdvertisements() -> String {
        return "stopListeningForAdvertisements"
    }

    @objc public class func startListeningForAdvertisements() -> String {
        return "startListeningForAdvertisements"
    }



}
