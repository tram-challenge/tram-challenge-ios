//
//  TCUtilities.m
//  TramChallenge
//
//  Created by Stephen Sykes on 27/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCUtilities.h"

@implementation TCUtilities

NSArray *tc_map(NSArray *objects, id (^block)(id object, NSInteger index))
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:objects.count];
    for (NSInteger i = 0; i < objects.count; i++) {
        id object = objects[i];
        id result = block(object, i);
        if (result) {
            [results addObject:result];
        }
    }
    return [NSArray arrayWithArray:results];
}

static NSMutableDictionary *counters;

+ (void)executeMostRecentAfter:(NSTimeInterval)delay identifier:(NSString *)identifier block:(void (^)())block
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        counters = [NSMutableDictionary dictionary];
    });

    NSString *idString = [identifier copy];

    if (!counters[idString]) counters[idString] = @0;
    NSInteger curCounter = [counters[idString] integerValue];
    NSUInteger counterInteger = curCounter + 1;
    NSNumber *nextValue = @(counterInteger);
    counters[idString] = nextValue;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (counterInteger == [counters[idString] integerValue]) {
            block();
        }
    });
}

@end

@implementation NSObject (TCUtilities)

+ (instancetype)tc_cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}

@end


@implementation NSSet (TCUtilities)

- (NSSet *)tc_setByRemovingObject:(id)object
{
    NSMutableSet *mutableSelf = [self mutableCopy];
    [mutableSelf removeObject:object];
    return [NSSet setWithSet:mutableSelf];
}

@end

@implementation UIButton (TCUtilities)

- (NSString *)tc_title
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setTc_title:(NSString *)tc_title
{
    [self setTitle:tc_title forState:UIControlStateNormal];
}


- (UIColor *)tc_titleColor
{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setTc_titleColor:(UIColor *)tc_titleColor
{
    [self setTitleColor:tc_titleColor forState:UIControlStateNormal];
    [self setTitleColor:[tc_titleColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
}

@end

@implementation UIView (TCUtilities)

- (CGFloat)x      { return self.center.x - self.bounds.size.width / 2;  }
- (CGFloat)y      { return self.center.y - self.bounds.size.height / 2; }
- (CGFloat)width  { return self.bounds.size.width;  }
- (CGFloat)height { return self.bounds.size.height; }

@end
