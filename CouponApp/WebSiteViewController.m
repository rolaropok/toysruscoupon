//
//  WebSiteViewController.m
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "WebSiteViewController.h"
#import "HomeViewController.h"
#import "ThumbViewController.h"
@interface WebSiteViewController ()

@end

@implementation WebSiteViewController
@synthesize CouponWebView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *UrlStr=@"https://toysrus.co.il/";
    
    NSURL *url = [NSURL URLWithString:[UrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [CouponWebView loadRequest:req];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)CrossBtnClicked:(id)sender
{
   // [self.navigationController popViewControllerAnimated:YES];
    
    UIViewController * dest1,*dest2;
    for (UIViewController* viewController in self.navigationController.viewControllers)
    {
        
        if ([viewController isKindOfClass:[HomeViewController class]] )
            dest1 = viewController;
        else if([viewController isKindOfClass:[ThumbViewController class]] )
            dest2 = viewController;
        
    }
    
    if (dest1 != nil)
        [self.navigationController popToViewController:dest1 animated:YES];
    else
        [self.navigationController popToViewController:dest2 animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
