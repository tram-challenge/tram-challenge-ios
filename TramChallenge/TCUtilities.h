//
//  TCUtilities.h
//  TramChallenge
//
//  Created by Stephen Sykes on 27/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TCUtilities : NSObject

NSArray *tc_map(NSArray *objects, id (^block)(id object, NSInteger index));

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