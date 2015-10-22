//
//  HGPageScrollViewSampleViewController.h
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 13/3/2011.
//	Copyright (C) 2011 TomTom
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//

#import <UIKit/UIKit.h>
#import "HGPageScrollView.h"
#import "HGPageImageView.h"
#import "SAMAddressBar.h"
#import "SAMAddressBarTextField.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "UIWebViewAdditions.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import "XCDYouTubeClient.h"
#import "YTVimeoExtractor.h"
#define kNumPages 10

@interface BrowserViewController : UIViewController <HGPageScrollViewDelegate, HGPageScrollViewDataSource, UITextFieldDelegate ,UIWebViewDelegate,NJKWebViewProgressDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate> {
		
	HGPageScrollView *_myPageScrollView;
    NSMutableArray   *_myPageDataArray;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;

    IBOutlet UIToolbar *editToolbar;
    NSURL *_urlToHandle;
	IBOutlet UIToolbar *toolbar;
    IBOutlet UISearchBar *searchBar;
    NSMutableIndexSet *indexesToDelete, *indexesToInsert, *indexesToReload;
    UIActionSheet *_longPressActionSheet;
    NSInteger copyButtonIndex;
    NSInteger openLinkButtonIndex;
    NSInteger downloadButtonIndex;;

    // Buttons Indexes for UIActionSheet (action button)
    NSInteger addBookmarkButtonIndex;
    NSInteger sendUrlButtonIndex;
    NSInteger printButtonIndex;
    NSInteger openWithSafariButtonIndex;
    UIPrintInteractionController *printInteraction;
    NSURL *downloadURL;
    UIButton *btnDownload;

}
@property (nonatomic, readonly) SAMAddressBar *addressBar;
@end

 