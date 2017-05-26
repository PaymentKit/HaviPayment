//
//  WDPRTimeEventTracker.h
//  Mdx
//
//  Created by Vidos, Hugh on 8/2/13.
//  Copyright (c) 2013 WDPRO. All rights reserved
//

#import <Foundation/Foundation.h>

// A pair object with an event name and event time.
@interface WDPRTimeEvent : NSObject

@property(nonatomic, readonly, copy) NSString *event;
@property(nonatomic, readonly, assign) NSTimeInterval time;
@property(nonatomic, readonly, copy) NSError *error;

- (id)initWithEvent:(NSString *)event
               time:(NSTimeInterval)time
              error:(NSError *)error;

@end

// A list of all the network events and how long they took.
@interface WDPRTimeEventTracker : NSObject

@property(atomic, readonly, assign, getter=currentEvents) NSSet *events;

- (void)addTimeEvent:(NSString *)event
                time:(NSTimeInterval)time
               error:(NSError *)error;
- (void)resetAllEvents;

@end
