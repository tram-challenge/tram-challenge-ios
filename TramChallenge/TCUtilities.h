//
//  TCUtilities.h
//  TramChallenge
//
//  Created by Stephen Sykes on 27/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG

# define lg(fmt, ...) NSLog(@"%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])

#else

# define lg(...) ((void)0)

#endif


@interface TCUtilities : NSObject

NSArray *tc_map(NSArray *objects, id (^block)(id object, NSInteger index));

+ (void)executeMostRecentAfter:(NSTimeInterval)delay identifier:(NSString *)identifier block:(void (^)())block;

@end

@interface NSObject (TCUtilities)

+ (instancetype)tc_cast:(id)object;

@end

@interface NSSet (TCUtilities)

- (NSSet *)tc_setByRemovingObject:(id)object;

@end

@interface UIButton (MORUtilities)

@property (nonatomic) NSString *tc_title;
@property (nonatomic) UIColor *tc_titleColor;

@end

@interface UIView (TCUtilities)

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

@end
