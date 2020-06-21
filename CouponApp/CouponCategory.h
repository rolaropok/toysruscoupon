//
//  CouponCategory.h
//  ToysRUsIL
//
//  Created by Fredrick Jansen on 15/02/15.
//  Copyright (c) 2015 Fredrick Jansen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CouponThumbInfo.h"
@interface CouponCategory : NSObject

@property NSMutableArray* coupons;
@property int counts;
@property int category;

-(instancetype) initWithCategory:(int) category;
-(void) addcouponThumb:(CouponThumbInfo *) thumb;
@end
