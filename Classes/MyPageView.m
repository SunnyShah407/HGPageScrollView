//
//  MyPageView.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 15/3/2011.
//  Copyright 2011 TomTom. All rights reserved.
//

#import "MyPageView.h"


@implementation MyPageView 

@synthesize isInitialized;
@synthesize webView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib{
    webView.multipleTouchEnabled = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
