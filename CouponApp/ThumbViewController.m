//
//  ThumbViewController.m
//  ToysRUsIL
//
//  Created by Fredrick Jansen on 14/02/15.
//  Copyright (c) 2015 Fredrick Jansen. All rights reserved.
//

#import "ThumbViewController.h"
#import "HomeCustomCell.h"
#import "CouponInfo.h"
#import "DataBase.h"
#import "WebSiteViewController.h"
#import "NetworkIndicator.h"
#import "AMPActivityIndicator.h"
#import "UIImageView+WebCache.h"
#import "HomeViewController.h"
#import "CouponManager.h"

@interface ThumbViewController ()<NSURLConnectionDelegate,UIScrollViewDelegate>
{
    NSURLConnection *couponConnection,*functionConnection,*refreshConnection;

    int pageIndex;
    BOOL scrollDirectionDetermined;
    BOOL isSwaped;
    int offsetx;
    int refreshTag;
    long int status;
    NSInteger pageNo;
    NSString* workingURL;
    NSInteger selectedCategory;
    NSInteger selectedCoupon;
    
    CouponManager *couponManager;
    
}
@property (nonatomic,retain) NSMutableData *webData,*webData1,*webData2;



@end

@implementation ThumbViewController
@synthesize CouponArr;

@synthesize webData,webData1,webData2;
@synthesize HomeTableView;
@synthesize progressView;
@synthesize HomeScrollView;
@synthesize PreviousButton,NextButton;
@synthesize BackRedBagView;
@synthesize pageControl;

@synthesize assortedButton,babyButton,boyButton,girlButton,powerCardButton;
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
    
    couponManager = [CouponManager sharedManager];
    
    selectedCategory = 1;
    CouponArr = couponManager.cat1;
    scrollDirectionDetermined = NO;
    isSwaped = NO;
    pageNo=1;
    pageNo = CouponArr.count;
    [self addSubViewsInScrolleView];
    [self registerNotification];
    [self setSelected:1];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Notification

-(void)registerNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(selectCategory:)
               name:@"selectCategory" object:nil];
}

-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) selectCategory:(NSNotification *)notification
{
    NSInteger cat = [((NSString*)[notification.userInfo valueForKey:@"category"]) integerValue];
    
    switch (cat) {
        case 1:
            [self clickAssortedCategory:nil];
            break;
        case 2:
            [self clickBabyCategory:nil];
            break;
        case 3:
            [self clickBoyCategory:nil];
            break;
        case 4:
            [self clickGirlCategory:nil];
            break;
        case 5:
            [self clickPowerCardCategory:nil];
            break;
        default:
            break;
    }
    
}


#pragma mark - home tab btns methods

-(IBAction)FavoritesBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"Favorites" sender:self];
}

-(IBAction)StoreLocatorBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MapVIew" sender:self];
}

-(IBAction)ShopOnlineBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"ShopOnline" sender:self];
}

-(IBAction)PoliceBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"Policy" sender:self];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    //  NSLog(@"response code %ld",(long)[response statusCode]);
    
    if (connection==couponConnection) {
        [webData setLength:0];
    }else if(connection==functionConnection)
    {
        [webData1 setLength:0];
        
    }
    else if(connection == refreshConnection)
    {
        [webData2 setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==couponConnection) {
        [webData appendData:data];
    }
    else if(connection==functionConnection)
    {
        [webData1 appendData:data];
    }
    else if(connection == refreshConnection)
    {
        [webData2 appendData:data];
    }
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    [self hideLoader];
    [NetworkIndicator stopLoading];
    //  isReloading = NO ;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // isReloading = NO ;
    NSError *err;
    if (connection==couponConnection) {
        // NSString *ste=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
        //  NSDictionary *json=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
        //  NSLog(@"error %@ ",err);
        if (arr.count>0) {
            
            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
                [self hideLoader];
                
            }else{
                
                for (int i=0; i<arr.count; i++)
                {
                    pageNo++;
                    NSDictionary *dic=[arr objectAtIndex:i];
                    CouponInfo *Coupon=[[CouponInfo alloc]init];
                    Coupon.isLoaded = @"NO";
                    //Coupon.CouponImage= [self mergeThumbImageWith:nil];
                    Coupon.C_Date=[dic objectForKey:@"c_date"];
                    Coupon.C_Image=[dic objectForKey:@"c_image"];
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
                                //dispatch_async(dispatch_get_main_queue(), ^{
                                Coupon.C_ShareImage=image;
                                //  });
                            }
                            else
                            {
                                // NSLog(@"image is not downloaded");
                            }
                        }
                        else if (connectionError != nil)
                        {
                            //  NSLog(@"Error %@",[connectionError description]);
                        }
                        else
                        {
                            // NSLog(@"No data could be downloaded");
                        }
                    }];
                    
                    
                    [CouponArr addObject:Coupon];
                    
                }
                
                [self addSubViewsInScrolleView];
                //[self refreshHomeScrollView:pageIndex];
                NSLog(@"Finished Loading Coupons");
                [NetworkIndicator stopLoading];
                isSwaped = NO;
                for(int i=0;i<CouponArr.count;i++){
                    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        // Add code here to do background processing
                        //
                        //
                        [NetworkIndicator startLoading];
                        
                        NSURL *url=[NSURL URLWithString:[[ CouponArr[i] C_Image] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        UIImage *cImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                        [CouponArr[i] setCouponImage:[self mergeThumbImageWith:cImage]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIView* a = [[HomeScrollView subviews] objectAtIndex:i];
                            
                            if(([a subviews] != nil)&&([a subviews].count != 0))
                            {
                                UIImageView* imageView = [[a subviews]objectAtIndex:0];
                                imageView.image = [CouponArr[i] CouponImage];
                                [CouponArr[i] setIsLoaded:@"YES"];
                                
                                if ([[[a subviews]objectAtIndex:1] isKindOfClass:[UIActivityIndicatorView class]])
                                {
                                    [[[a subviews]objectAtIndex:1] removeFromSuperview];
                                    
                                }
                                
                            }
                            else
                                NSLog(@"Invalid Image Index - %d",i);
                            
                        });
                        
                        [NetworkIndicator stopLoading];
                        
                    });
                }
                
            }
        }else{
            
            [NetworkIndicator stopLoading];
        }
    }
    
    if (connection==refreshConnection) {
        
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData2 options:kNilOptions error:&err];
        //  NSLog(@"error %@ ",err);
        //NSLog(@"Refresh - %@" , [arr description]);
        
        if (arr.count>0) {
            
            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
                [self hideLoader];
                [NetworkIndicator stopLoading];
            }else{
                [couponManager clearCoupons];
                [couponManager parseCoupons:arr];
                [self addSubViewsInScrolleView];
                [self hideLoader];
                [NetworkIndicator stopLoading];
            }
            
        }else{
            
            [self hideLoader];
            [NetworkIndicator stopLoading];
        }
    }

    
    if (connection==functionConnection) {
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData1 options:kNilOptions error:nil];
        
        [NetworkIndicator stopLoading];
        NSLog(@"# Like Button Clicked");
        
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic=[arr objectAtIndex:0];
            if ([[dic objectForKey:@"status"] isEqualToString:@"success"] ) {
                NSLog(@"# Do Like Succeed");
                                //[self nextpage];
            }else if ([[dic objectForKey:@"status"] isEqualToString:@"failure"])
            {
                NSLog(@"# Do Like Failed");
            }
        }
        
    }
    
}

- (void) backgroundService
{
    
    
}


#pragma mark - add views in scrollview
-(void)addSubViewsInScrolleView
{
    //pageIndex=0;
    //NSLog(@"CouponArr Size:%d",CouponArr.count);
    
    for (UIView *v in self.HomeScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    int i=0;
    BOOL flag = YES;
    NSInteger couponcounts = CouponArr.count;

    int pages = ceil((float)couponcounts / 6);
    int page = 1;
    
    while (flag) {
        // if (CouponArr.count>0) {
        
        CouponInfo *coupIfo;
        UIView* CView=[[UIView alloc]initWithFrame:CGRectMake((page-1)*320, 0, 320, 421)];
        //[CView setBackgroundColor:[UIColor whiteColor]];
        [self.HomeScrollView addSubview:CView];
        
        int width,height,offsetX,offsetY,margin;
        if ([AppDelegate sharedInstance].DeviceHight>480)
        {
            width = 120, height =120;
            offsetX = 40,offsetY = 15;
            margin = 5;
        }
        else
        {
            width = 110, height =100;
            offsetX = 40,offsetY = 15;
            margin = 5;
        }
        
        if (i < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i];
            UIImageView* thumbImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX,offsetY,width,height)];
            [thumbImageView1 setTag:i];
            [thumbImageView1 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            [thumbImageView1 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView1 addGestureRecognizer:thumbnailTapGesture];
            [CView addSubview:thumbImageView1];
        }else
            flag = NO;
        
        if (i+1 < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i+1];
            UIImageView* thumbImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX + margin + width,offsetY,width,height)];
            [thumbImageView2 setTag:i+1];
            [thumbImageView2 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView2 addGestureRecognizer:thumbnailTapGesture];
            [thumbImageView2 setUserInteractionEnabled:YES];
            [CView addSubview:thumbImageView2];
        }else
            flag = NO;
        
        if (i+2 < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i+2];
            UIImageView* thumbImageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX,offsetY + margin + height,width,height)];
            [thumbImageView3 setTag:i+2];
            [thumbImageView3 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView3 addGestureRecognizer:thumbnailTapGesture];
            [thumbImageView3 setUserInteractionEnabled:YES];
            [CView addSubview:thumbImageView3];
            
        }else
            flag = NO;

        if (i+3 < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i+3];
            UIImageView* thumbImageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX+ margin + width,offsetY + margin + height,width,height)];
            [thumbImageView4 setTag:i+3];
            [thumbImageView4 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView4 addGestureRecognizer:thumbnailTapGesture];
            [thumbImageView4 setUserInteractionEnabled:YES];
            [CView addSubview:thumbImageView4];
         
        }else
            flag = NO;
        
        if (i+4 < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i+4];
            UIImageView* thumbImageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX,offsetY + (margin + height)*2,width,height)];
            [thumbImageView5 setTag:i+4];
            [thumbImageView5 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView5 addGestureRecognizer:thumbnailTapGesture];
            [thumbImageView5 setUserInteractionEnabled:YES];
            [CView addSubview:thumbImageView5];
        }else
            flag = NO;
        
        if (i+5 < couponcounts) {
            coupIfo=[CouponArr objectAtIndex:i+5];
            UIImageView* thumbImageView6 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX+ margin + width,offsetY + (margin + height)*2,width,height)];
            [thumbImageView6 setTag:i+5];
            [thumbImageView6 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
            [thumbImageView6 addGestureRecognizer:thumbnailTapGesture];
            [thumbImageView6 setUserInteractionEnabled:YES];
            [CView addSubview:thumbImageView6];
        }else
            flag = NO;
        
        
        UIButton *homePevious=[UIButton buttonWithType:UIButtonTypeCustom];
        homePevious.frame=CGRectMake(0, 185, 25, 27);
        [homePevious setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [CView addSubview:homePevious];
        homePevious.tag=i;
        [homePevious addTarget:self action:@selector(PreviousButClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *HomeNext=[UIButton buttonWithType:UIButtonTypeCustom];
        HomeNext.frame=CGRectMake(295, 185, 25, 27);
        [HomeNext setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [CView addSubview:HomeNext];
        [HomeNext addTarget:self action:@selector(nextButClicked:) forControlEvents:UIControlEventTouchUpInside];
        HomeNext.tag=i;
        
        if (pages==1) {
            homePevious.alpha=0;
            HomeNext.alpha=0;
        }else if (i<6){
            homePevious.alpha=0;
        }else if (page > pages-1){
            HomeNext.alpha=0;
        }

       
        
        //NSLog(@"6");
        if ([AppDelegate sharedInstance].DeviceHight==480)
        {
            CView.frame=CGRectMake((page-1)*320, 0, 320, 340);
            homePevious.frame=CGRectMake(0, 135, 25, 27);
            HomeNext.frame=CGRectMake(295, 135, 25, 27);
            
        }
        i+=6;
        page++;
    }
    
    if (CouponArr.count==1) {
        PreviousButton.alpha=0;
        NextButton.alpha=0;
    }
    
    self.HomeScrollView.contentSize=CGSizeMake(320* pages+10,390);
    
    if ([AppDelegate sharedInstance].DeviceHight==480)
    {
        self.HomeScrollView.contentSize=CGSizeMake(320*pages+10, 340);
    }
    self.HomeScrollView.scrollEnabled=YES;
    
}

-(void) nextCategory
{
    switch (selectedCategory) {
        case 1:
            [self clickBabyCategory:nil];
            break;
        case 2:
            [self clickBoyCategory:nil];
            break;
        case 3:
            [self clickGirlCategory:nil];
            break;
        case 4:
            [self clickPowerCardCategory:nil];
            break;
        case 5:
            break;
        default:
            break;
    }
}


-(void) beforeCategory
{
    switch (selectedCategory) {
        case 2:
            [self clickAssortedCategory:nil];
            break;
        case 3:
            [self clickBabyCategory:nil];
            
            
            break;
        case 4:
            [self clickBoyCategory:nil];
            
            
            break;
        case 5:
            [self clickGirlCategory:nil];
            break;
    }
}

- (IBAction)clickAssortedCategory:(id)sender {
    
    if (selectedCategory == 1)
        return;
    
    selectedCategory = 1;
    
    [self setSelected:selectedCategory];
    CouponArr = couponManager.cat1;
    [self addSubViewsInScrolleView];
    [self moveTo:0];
    
}

- (IBAction)clickBabyCategory:(id)sender {
    if (selectedCategory == 2)
        return;
    selectedCategory = 2;
    [self setSelected:selectedCategory];
    CouponArr = couponManager.cat2;
    [self addSubViewsInScrolleView];
    [self moveTo:0];
}

- (IBAction)clickBoyCategory:(id)sender {
    if (selectedCategory == 3)
        return;
    selectedCategory = 3;
    [self setSelected:selectedCategory];
    CouponArr = couponManager.cat3;
    [self addSubViewsInScrolleView];
    [self moveTo:0];
}

- (IBAction)clickGirlCategory:(id)sender {
    if (selectedCategory == 4)
        return;
    selectedCategory = 4;
    [self setSelected:selectedCategory];
    CouponArr = couponManager.cat4;
    [self addSubViewsInScrolleView];
    [self moveTo:0];
}

- (IBAction)clickPowerCardCategory:(id)sender {
    if (selectedCategory == 5)
        return;
    selectedCategory = 5;
    [self setSelected:selectedCategory];
    CouponArr = couponManager.cat5;
    [self addSubViewsInScrolleView];
    [self moveTo:0];
}

-(void) setSelected:(NSInteger) cat
{
    [assortedButton setSelected:NO];
    [boyButton setSelected:NO];
    [babyButton setSelected:NO];
    [girlButton setSelected:NO];
    [powerCardButton setSelected:NO];
    
    if (cat == 1)
        [assortedButton setSelected:YES];
    else if (cat == 2)
        [babyButton setSelected:YES];
    else if (cat == 3)
        [boyButton setSelected:YES];
    else if (cat == 4)
        [girlButton setSelected:YES];
    else if (cat == 5)
        [powerCardButton setSelected:YES];
}


-(void) moveTo:(int) page
{
    
    pageIndex = 0;
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * page;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:NO];
    
}

-(void) tapOnThumbnail:(UITapGestureRecognizer*)sender
{
    UIImageView *thumb = (UIImageView*)sender.view;
    selectedCoupon = thumb.tag;
    NSLog(@"%ld Category's %ld Coupon",(long)selectedCategory,(long)selectedCoupon);
    [self performSegueWithIdentifier:@"Coupons" sender:nil];
    
}

-(IBAction)nextButClicked:(id)sender
{
    
    CGRect frame;
    if (pageIndex<CouponArr.count) {
        
        frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex+1);
        frame.origin.y = 0;
        frame.size = self.HomeScrollView.frame.size;
        [self.HomeScrollView scrollRectToVisible:frame animated:YES];
        
        pageIndex++;
        if (pageIndex==CouponArr.count-1) {
            //  NextButton.alpha=0;
        }
        
//        if((pageIndex+3 >= CouponArr.count-1)&&(!isSwaped) && (CouponArr.count-1 < self.couponCounts))
//            [self SwapCoupnCallWebservice];
        
    }
}

-(IBAction)PreviousButClicked:(id)sender
{
    
    CGRect frame;
    if (pageIndex>0) {
   
        frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex-1);
        frame.origin.y = 0;
        frame.size = self.HomeScrollView.frame.size;
        [self.HomeScrollView scrollRectToVisible:frame animated:YES];
        pageIndex--;
        
        if (pageIndex==0) {
            // PreviousButton.alpha=0;
        }
        
    }
}

-(void) refreshHomeScrollView:(int) pos
{
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * pos;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:YES];
}

-(void)LeftGestureForView:(id)sender
{
    
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    CGRect frame;
    if (Swipe.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (pageIndex<CouponArr.count) {
            
            PreviousButton.alpha=1;
            if (CouponArr.count==1) {
                self.NextButton.alpha=0;
                self.PreviousButton.alpha=0;
            }
            
            frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex+1);
            frame.origin.y = 0;
            frame.size = self.HomeScrollView.frame.size;
            [self.HomeScrollView scrollRectToVisible:frame animated:YES];
            pageIndex++;
            if (pageIndex==CouponArr.count-1) {
                NextButton.alpha=0;
            }
        }
    }
    
}

-(void)RightGestureForView:(id)sender
{
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    if (Swipe.direction==UISwipeGestureRecognizerDirectionRight) {
        
        
        CGRect frame;
        if (pageIndex>0) {
            
            NextButton.alpha=1;
            if (CouponArr.count==1) {
                self.NextButton.alpha=0;
                self.PreviousButton.alpha=0;
            }
            frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex-1);
            frame.origin.y = 0;
            frame.size = self.HomeScrollView.frame.size;
            [self.HomeScrollView scrollRectToVisible:frame animated:YES];
            pageIndex--;
            
            if (pageIndex==0) {
                PreviousButton.alpha=0;
            }
            
        }
    }
}

#pragma mark - custom Activityindicator method view
-(void)showLoader{
    Parentview=[[UIView alloc]initWithFrame:CGRectMake(90,200, 150,50)];
    Parentview.backgroundColor=[UIColor grayColor];
    Parentview.layer.cornerRadius=2;
    Parentview.layer.borderWidth=1;
    Parentview.layer.borderColor=[UIColor lightGrayColor].CGColor;
    Parentview.layer.masksToBounds=YES;
    
    progressView  = [[AMPActivityIndicator alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
    progressView.backgroundColor =[UIColor clearColor];
    progressView.opaque = YES;
    [progressView setBarColor:[UIColor whiteColor ]];
    [progressView setBarHeight:7.0f];
    [progressView setBarWidth:2.0f];
    [progressView setAperture:10.0f];
    [progressView setCenter:CGPointMake(30, 25)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(60,15,70,20);
    headerLabel.text= @"Loading...";
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.textColor=[UIColor whiteColor];
    [Parentview addSubview:progressView];
    [Parentview addSubview:headerLabel];
    [self.view addSubview:Parentview];
    [progressView startAnimating];
}
-(void)hideLoader{
    [Parentview removeFromSuperview];
}

#pragma mark - custom Activityindicator 2 method view

-(void)showLoader2{
    animateView=[[UIView alloc]initWithFrame:CGRectMake(35,250, 250,60)];
    animateView.backgroundColor=[UIColor darkGrayColor];
    animateView.layer.cornerRadius=2;
    animateView.layer.borderWidth=1;
    animateView.layer.borderColor=[UIColor colorWithWhite:0.8 alpha:1].CGColor;
    animateView.layer.masksToBounds=YES;
    
    progressView  = [[AMPActivityIndicator alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
    progressView.backgroundColor =[UIColor clearColor];
    progressView.opaque = YES;
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarHeight:7.0f];
    [progressView setBarWidth:2.0f];
    [progressView setAperture:10.0f];
    [progressView setCenter:CGPointMake(30, 25)];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(60,15,90,30);
    headerLabel.text= @"Wait...";
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.textColor=[UIColor whiteColor];
    [animateView addSubview:progressView];
    [animateView addSubview:headerLabel];
    //[indicatorView addSubview:headerLabel];
    [self.view addSubview:animateView];
    [progressView startAnimating];
}

#pragma mark - refresh  Button method

-(IBAction)RefreshButtonClicked:(id)sender
{
    if([NetworkIndicator getCounter] < 1)
        [self RefreshCoupons];
}

#pragma mark - scrollview delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)tableView {
    
    CGFloat pageWidth = self.HomeScrollView.frame.size.width;
    int page = floor((self.HomeScrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    int totalPages = floor(self.HomeScrollView.contentSize.width / pageWidth);
    NSLog(@"Page : %d / %d , PN:%ld",page,totalPages,(long)pageNo);
    pageIndex = page;
    if((page+3 >= totalPages)&&(!isSwaped) && (totalPages < self.couponCounts))
        [self SwapCoupnCallWebservice];
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollDirectionDetermined = NO;
    if (self.HomeScrollView.contentOffset.x + self.HomeScrollView.frame.size.width > self.HomeScrollView.contentSize.width)
        [self nextCategory];
    else if (self.HomeScrollView.contentOffset.x < 0)
        [self beforeCategory];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollDirectionDetermined = NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"Coupons"]) {
        
        HomeViewController *home =(HomeViewController*) segue.destinationViewController;
        home.category = selectedCategory;
        home.startCouponId = selectedCoupon;
    }
}

- (IBAction)changePage {
    // Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:YES];
    
    // Keep track of when scrolls happen in response to the page control
    // value changing. If we don't do this, a noticeable "flashing" occurs
    // as the the scroll delegate will temporarily switch back the page
    // number.
    scrollDirectionDetermined = YES;
}
-(void)SwapCoupnCallWebservice
{
    isSwaped = YES;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Coupon_Url;
    
    //[self showLoader];
    
    [NetworkIndicator startLoading];
    
    NSLog(@"calling SwapCouponService");
    
    //https://toysruscoupon.nethost.co.il/webservices/index.php?action=getCoupan&coupan=Yes&device_id=dviceid123458&page=1items=2
    
    BOOL CheckUrl=YES;// [self isValidURL:[NSURL URLWithString:urlstring]];
    
    if (CheckUrl==YES) {
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
        NSString *deviceId=[[[[num description]
                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                            stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        if (deviceId==nil) {
            deviceId=@"ae32877r840kg08967";
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:deviceId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSLog(@"Total Page Number = %ld",(long)pageNo);
        
        NSString *page=[NSString stringWithFormat:@"%ld",(long)pageNo];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[page dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *items=@"2";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[items dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        couponConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //NSLog(@"SwapCoupanCall- RequestBody%@",[body description]);
        if(couponConnection)
        {
            webData = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }
        
    }
    
    
}

-(UIImage*) mergeThumbImageWith:(UIImage*)couponImg
{
    UIImage *bgImg;
    if (couponImg.size.width < 300) {
        bgImg = [UIImage imageNamed:@"imgthumbbg.png"];
    }
    else
        bgImg = [UIImage imageNamed:@"imgbg.png"];
    
    if (couponImg == nil) {
        return  bgImg;
    }
    
    UIGraphicsBeginImageContext(bgImg.size);
    [bgImg drawInRect:CGRectMake(0, 0, bgImg.size.width, bgImg.size.height)];
    [couponImg drawInRect:CGRectMake((bgImg.size.width - couponImg.size.width)/2, (bgImg.size.height - couponImg.size.height)/2, couponImg.size.width, couponImg.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


-(void)RefreshCoupons
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  http://198.12.150.189/~simssoe/index.php
    
    NSString  *urlstring = Main_Coupon_Url;
    
    [self showLoader];
    
    pageNo = 0;
    [NetworkIndicator startLoading];
    
    NSLog(@"calling RefreshCoupons");

    BOOL CheckUrl=YES;// [self isValidURL:[NSURL URLWithString:urlstring]];
    
    if (CheckUrl==YES) {
 
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
        NSString *deviceId=[[[[num description]
                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                            stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        if (deviceId==nil) {
            deviceId=@"ae32877r840kg08967";
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:deviceId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"%d",0]] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        //NSLog(@"Total Page Number = %d",0);
        
        NSString *page=[NSString stringWithFormat:@"%d",0];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[page dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *itemcount = [NSString stringWithFormat:@"%ld",(long)couponManager.totalCoupons];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[itemcount dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];

        
        refreshConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //NSLog(@"SwapCoupanCall- RequestBody%@",[body description]);
        if(refreshConnection)
        {
            webData2 = [[NSMutableData alloc]init];
        }
        
    }
    
    
    
    
    
}

@end
