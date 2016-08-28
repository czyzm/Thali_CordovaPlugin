//
//  BluetoothHarwareControlObserver.h
//  ThaliCore
//
//  Copyright (C) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//

#ifndef BluetoothHarwareControlObserver_h
#define BluetoothHarwareControlObserver_h

#import <Foundation/Foundation.h>

typedef enum BluetoothHardwareControlNotification : NSUInteger {
    PowerChangedNotification,
} BluetoothHardwareControlNotification;

@protocol BluetoothHarwareControlObserverProtocol <NSObject>

@required
- (void)receivedBluetoothNotification: (BluetoothHardwareControlNotification)btNotification;

@end

#endif /* BluetoothHarwareControlObserver_h */