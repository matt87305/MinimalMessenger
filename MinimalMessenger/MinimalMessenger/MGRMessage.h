//
//  MGRMessage.h
//  MinimalMessenger
//
//  Created by Matt Rosemeier on 5/3/14.
//  Copyright (c) 2014 Matt Rosemeier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, MGRMessageType) {
    MGRMessageTypeSent = 0,
    MGRMessageTypeReceived
};

@interface MGRMessage : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSDate * date;

@end
