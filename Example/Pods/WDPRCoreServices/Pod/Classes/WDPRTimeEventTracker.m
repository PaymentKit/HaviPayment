//
//  WDPRTimeEventTracker.m
//  Mdx
//
//  Created by Vidos, Hugh on 8/2/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRTimeEventTracker.h"

@implementation WDPRTimeEvent

- (id)initWithEvent:(NSString *)event
               time:(NSTimeInterval)time
              error:(NSError *)error {
  self = [super init];
  if (self) {
    self->_event = [event copy];
    self->_time = time;
    self->_error = [error copy];
  }
  return self;
}

- (NSString *)description {
  NSString *format =
      (self.error) ? @"%@\n\t[%3.3f ms]  ERROR" : @"%@\n\t[%3.3f ms]";
  return [NSString stringWithFormat:format, self.event, self.time * 1000];
}

@end

@interface WDPRTimeEventTracker ()

@property(atomic, strong) NSMutableSet *internalEvents;

@end

@implementation WDPRTimeEventTracker

- (id)init {
  self = [super init];
  if (self) {
    self->_internalEvents = [NSMutableSet set];
  }
  return self;
}

- (NSSet *)currentEvents {
  @synchronized(self) {
    return [NSSet setWithSet:self.internalEvents];
  }
}

- (NSString *)description {
  NSMutableString *output = [[NSMutableString alloc] init];
  for (WDPRTimeEvent *event in self.internalEvents) {
    if ([output length] > 0) {
      [output appendString:@"\n"];
    }
    [output appendString:[event description]];
  }
  return [NSString stringWithString:output];
}

- (void)addTimeEvent:(NSString *)event
                time:(NSTimeInterval)time
               error:(NSError *)error {
  WDPRTimeEvent *timeEvent =
      [[WDPRTimeEvent alloc] initWithEvent:event time:time error:error];
  @synchronized(self) {
    [self.internalEvents addObject:timeEvent];
  }
}

- (void)resetAllEvents {
  @synchronized(self) {
    [self.internalEvents removeAllObjects];
  }
}

@end
