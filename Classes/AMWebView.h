//
//  AMWebView.h
//  AMWebView
//
//  Created by Minh Nguyen on 3/20/15.
//  Copyright (c) 2015 Double Nose. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AMWebViewButton) {
    AMWebViewBack = 0,
    AMWebViewNext,
    AMWebViewMenu,
    AMWebViewReload
};

@interface AMWebView : UIView

+ (instancetype)amWebView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (copy, nonatomic) void(^eventHandler)(id sender);

@end
