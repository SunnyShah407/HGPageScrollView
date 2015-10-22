//
//  MyPageView.h
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 15/3/2011.
//  Copyright 2011 TomTom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPageView.h"

@interface MyPageView : HGPageView <UIWebViewDelegate>{
 

}

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic ,retain)     IBOutlet UIWebView *webView;

@end
