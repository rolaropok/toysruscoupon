//
//  CouponManager.m
//  ToysRUsIL
//
//  Created by soft on 20/02/15.
//  Copyright (c) 2015 soft. All rights reserved.
//

#import "CouponManager.h"
#import "CouponInfo.h"
@interface CouponManager ()<NSURLConnectionDelegate>



@end
@implementation CouponManager

@synthesize cat1,cat2,cat3,cat4,cat5;
@synthesize cat1Size,cat2Size,cat3Size,cat4Size,cat5Size;
@synthesize totalCoupons;


+ (id)sharedManager {
    static CouponManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        cat1 = [[NSMutableArray alloc] init];
        cat2 = [[NSMutableArray alloc] init];
        cat3 = [[NSMutableArray alloc] init];
        cat4 = [[NSMutableArray alloc] init];
        cat5 = [[NSMutableArray alloc] init];
        
        cat1Size = 0;
        cat2Size = 0;
        cat3Size = 0;
        cat4Size = 0;
        cat5Size = 0;
        
        totalCoupons = 0;
    }
    return self;
}


- (void) parseCoupons:(NSArray*) arr
{
    
    for (int i=0; i<arr.count; i++)
    {
        //pageNo++;
        NSDictionary *dic=[arr objectAtIndex:i];
        CouponInfo *Coupon=[[CouponInfo alloc]init];
        Coupon.isLoaded = @"NO";
        Coupon.C_Category = ((NSString *)[dic objectForKey:@"c_category"]).integerValue;
        Coupon.C_Date=[dic objectForKey:@"c_date"];
        Coupon.C_Image=[dic objectForKey:@"c_image"];
        Coupon.C_ThumbImage=[dic objectForKey:@"c_thumb_image"];
        Coupon.C_Name=[dic objectForKey:@"c_name"];
        Coupon.C_Text=[dic objectForKey:@"c_text"];
        Coupon.C_ID=[dic objectForKey:@"id"];
        Coupon.To_Date=[dic objectForKey:@"to_date"];
        Coupon.Total_Like=[NSString stringWithFormat:@"%@", [dic objectForKey:@"total_like"]];
        Coupon.CouponNumber=[NSString stringWithFormat:@"%@",[dic objectForKey:@"coupan_number"]];
        
        
        NSURL *Shareurl=[NSURL URLWithString:[[dic objectForKey:@"c_share_image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *Sharerequest   = [NSURLRequest requestWithURL:Shareurl];
        
        [NSURLConnection sendAsynchronousRequest:Sharerequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (connectionError == nil && data != nil)
            {
                UIImage *image = [UIImage imageWithData:data];
                if (image != nil)
                {
                    Coupon.C_ShareImage=image;
                }
                else
                {
                    NSLog(@"ShareImage is not downloaded");
                }
            }
            else if (connectionError != nil)
            {
                NSLog(@"Error %@",[connectionError description]);
            }
            else
            {
                NSLog(@"No data could be downloaded");
            }
        }];
        
        
        switch (Coupon.C_Category) {
            case 1:
                [cat1 addObject:Coupon];
                break;
            case 2:
                [cat2 addObject:Coupon];
                break;
            case 3:
                [cat3 addObject:Coupon];
                break;
            case 4:
                [cat4 addObject:Coupon];
                break;
            case 5:
                [cat5 addObject:Coupon];
                break;
            default:
                break;
        }
    }
    
    cat1Size = [cat1 count];
    cat2Size = [cat2 count];
    cat3Size = [cat3 count];
    cat4Size = [cat4 count];
    cat5Size = [cat5 count];
}

- (void) clearCoupons
{
    
    [cat1 removeAllObjects];
    [cat2 removeAllObjects];
    [cat3 removeAllObjects];
    [cat4 removeAllObjects];
    [cat5 removeAllObjects];
    
    cat1Size = cat2Size = cat3Size = cat4Size = cat5Size = 0;
    
}
@end
