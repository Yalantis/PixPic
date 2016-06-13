//
//  NSTimer+Block.h
//
//  Created by Marcus Brissman on 2014-12-05.
//  Copyright (c) 2014 Marcus Brissman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Block)

/**
 Initializes a new NSTimer object using the specified block.
 @param date The time at which the timer should first fire.
 @param seconds For a repeating timer, this parameter contains the number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 @param block The block to be executed when the timer fire. The block should take no parameters and have no return value.
 @return The receiver, initialized such that, when added to a run loop, it will fire at date and then, if repeats is YES, every seconds after that.
 */
- (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(void))block;

/**
 Creates and returns a new NSTimer object and schedules it on the current run loop in the default mode.
 @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 @param block The block to be executed when the timer fire. The block should take no parameters and have no return value.
 @return A new NSTimer object, configured according to the specified parameters.
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(void))block;

/**
 Creates and returns a new NSTimer object initialized with the specified block.
 @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 @param block The block to be executed when the timer fire. The block should take no parameters and have no return value.
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(void))block;

@end
