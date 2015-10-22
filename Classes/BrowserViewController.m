//
//  HGPageScrollViewSampleViewController.m
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

#import "BrowserViewController.h"
#import "MyPageData.h"
#import "MyPageView.h"
#import "MyTableViewController.h"
#import "UnpreventableUILongPressGestureRecognizer.h"

@interface BrowserViewController(internal)
- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index;
- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet;
- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet;



@end


#define kPlatformSupportsViewControllerHeirarchy ([self respondsToSelector:@selector(childViewControllers)] && [self.childViewControllers isKindOfClass:[NSArray class]])

@implementation BrowserViewController

@synthesize addressBar = _addressBar;


- (SAMAddressBar *)addressBar {
    if (!_addressBar) {
        _addressBar = [[SAMAddressBar alloc] init];
        _addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _addressBar.textField.delegate = self;
        _addressBar.textField.text = @"http://www.google.com";
    }
    return _addressBar;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// load pageScrollView data
	_myPageDataArray = [[NSMutableArray alloc] initWithCapacity : kNumPages];
    [self.navigationController setNavigationBarHidden:YES];
	
    self.view.backgroundColor = [UIColor colorWithRed:0.851f green:0.859f blue:0.882f alpha:1.0f];

    CGSize size = [UIScreen mainScreen].bounds.size;

    self.addressBar.frame = CGRectMake(0.0f, 0.0f, size.width, 58.0f);
    for (int i=0; i<kNumPages; i++) {
        MyPageData *pageData = [[MyPageData alloc] init] ;
        pageData.title = [NSString stringWithFormat:@"%d", i];
        pageData.subtitle = _addressBar.textField.text;
        [pageData setTitleOFweb:pageData.subtitle];
        [_myPageDataArray addObject:pageData];
        break;
        

    }
	// now that we have the data, initialize the page scroll view
	_myPageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
    

    _myPageScrollView.backgroundColor = self.view.backgroundColor;
    [_myPageScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, size.height-44-44 )];
 	[self.view addSubview:_myPageScrollView];
    
    [_myPageScrollView reloadData];
    [self.view bringSubviewToFront:searchBar];
    [self.view bringSubviewToFront:toolbar];
    [self.view bringSubviewToFront:editToolbar];

    // uncomment this line if you want to select a page initially, before HGPageScrollView is shown,
	//[pageScrollView selectPageAtIndex:0 animated:NO];
    [self setPageWithAnimation:NO];
    
    [self.view addSubview:self.addressBar];
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, -50, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_progressView];

   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemBecameCurrent:)
                                                 name:@"AVPlayerItemBecameCurrentNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIWindowDidBecomeHiddenNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(youTubeFinished:)
                                                 name:@"UIMoviePlayerControllerWillExitFullscreenNotification"
                                               object:nil];
    
    /*
     [YTVimeoExtractor fetchVideoURLFromURL:@"http://vimeo.com/58600663"
     quality:YTVimeoVideoQualityMedium
     completionHandler:^(NSURL *videoURL, NSError *error, YTVimeoVideoQuality quality) {
     if (error) {
     // handle error
     NSLog(@"Video URL: %@", [videoURL absoluteString]);
     } else {
     
     NSLog(@"%@",videoURL.absoluteString);
     downloadURL = videoURL;
     [self btnDownloadClicked];
     }
     }];
     */
    

}

-(void)youTubeFinished:(NSNotification *)notification{
    if (btnDownload) {
        [btnDownload removeFromSuperview];
    }
}
-(void)playerItemBecameCurrent:(NSNotification*)notification {
    AVPlayerItem *playerItem = [notification object];
    if (![playerItem isKindOfClass:[AVPlayerItem class]]) {
        return;
    }
    if(playerItem == nil)
        return;
    
    
    // Break down the AVPlayerItem to get to the path
    AVURLAsset *asset = (AVURLAsset*)[playerItem asset];
    NSURL *url = [asset URL];
    NSString *path = [url absoluteString];
    NSLog(@"%@",[self getWebView].request.URL.absoluteString);
    downloadURL = [NSURL URLWithString:path];

    
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIWindow *window = [[UIApplication sharedApplication]keyWindow];
        
        btnDownload = [UIButton buttonWithType:0];
        [btnDownload setTitle:@"Download" forState:UIControlStateNormal];
        [btnDownload.titleLabel setTextColor:[UIColor whiteColor]];
        [btnDownload setFrame:CGRectMake(20, self.view.frame.size.height - 50, 150, 30)];
        [btnDownload setBackgroundColor:[UIColor darkGrayColor]];
        [btnDownload addTarget:self action:@selector(btnDownloadClicked) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:btnDownload];
    });
}
-(void)btnDownloadClicked{
    [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_NOTIFICATION object:downloadURL];
}
-(IBAction)btnBack{
    UIWebView *webView = [self getWebView];
    if ([webView canGoBack]) {
        [webView goBack];
    }
}
-(IBAction)goForward{
    UIWebView *webView = [self getWebView];
    if ([webView canGoForward]) {
        [webView goForward];
    }

}
-(void)viewWillAppear:(BOOL)animated{
}
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
//    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSArray *arr = [html componentsSeparatedByString:@"{\"low\":\""];
    if (arr.count==2) {
        NSString *str = [arr objectAtIndex:1];
        NSArray *arr1 = [str componentsSeparatedByString:@"\","];
        downloadURL = [NSURL URLWithString:[arr1 objectAtIndex:0]];
    }
    
    if ([webView.request.URL.absoluteString rangeOfString:@".youtube.com"].location != NSNotFound) {
        NSLog(@"%@",webView.request.URL.absoluteString);
        NSArray *arr = [webView.request.URL.absoluteString componentsSeparatedByString:@"watch?v="];
        if (arr.count==2) {
            
            NSString *videoIdentifier =[arr objectAtIndex:0] ;
            [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
                if (video)
                {
                    NSLog(@"%@",video.title);
                    NSLog(@"%@",video.streamURLs);
                    // Do something with the `video` object
                }
                else
                {
                    // Handle error
                }
            }];
        }
    }
    
}
- (void) webView:(UIWebView *)sender didFailLoadWithError:(NSError *) error {
    switch ([error code]) {
        case kCFURLErrorCancelled :
        {
            // Do nothing in this case
            break;
        }
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }
    }
    
}
#pragma mark -
#pragma mark HGPageScrollViewDataSource


- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_myPageDataArray count];
}


- (UIView *)pageScrollView:(HGPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index;  
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        UIView *navBarCopy = [[UINavigationBar alloc] initWithFrame:pageData.navController.navigationBar.frame];
        return navBarCopy;
    }
        
    return nil;
}


- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{    
    
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {

        if (kPlatformSupportsViewControllerHeirarchy) {
            // on iOS 5 use built-in view controller hierarchy support
            UIViewController *viewController = [self.childViewControllers objectAtIndex:0];
            return (HGPageView*)viewController.view;
        }
        else{
            return (HGPageView*)pageData.navController.topViewController.view;
        }
    } else if (pageData.isImageOnly) {
        CGSize imageSize = [[pageData image] size];
        CGRect frame = CGRectMake(0, 0, 320, 320.0 / imageSize.width * imageSize.height);
        
        HGPageImageView *imageView = [[HGPageImageView alloc]
                                      initWithFrame:frame];
        [imageView setImage:[pageData image]];
        [imageView setReuseIdentifier:@"imageId"];
        
        return imageView;
    }
    else{
         NSString *pageId = pageData.title;

        MyPageView *pageView = (MyPageView*)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"MyPageView" owner:self options:nil] objectAtIndex:0];
            _progressProxy = [[NJKWebViewProgress alloc] init];
            pageView.webView.delegate = _progressProxy;
            _progressProxy.webViewProxyDelegate = self;
            _progressProxy.progressDelegate = self;
            pageView.reuseIdentifier = pageData.title;
            
            UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
            longPressRecognizer.allowableMovement = 20;
            longPressRecognizer.minimumPressDuration = 1.0f;
            [pageView.webView addGestureRecognizer:longPressRecognizer];
        }
        
        // configure the page
        
        UILabel *titleLabel = (UILabel*)[pageView viewWithTag:1];
        titleLabel.text = pageData.title;
        [titleLabel setHidden:false];

        UIImageView *imageView = (UIImageView*)[pageView viewWithTag:2];
        imageView.image = pageData.image;
        
        //UITextView *textView = (UITextView*)[pageView viewWithTag:3];
        //	textView.text = @"some text here";
        
        //adjust content size of scroll view
        UIScrollView *pageContentsScrollView = (UIScrollView*)[pageView viewWithTag:10];	
        pageContentsScrollView.scrollEnabled = NO; //initially disable scroll
        
        // set the pageView frame height
        CGRect frame = pageView.frame;
        frame.size.height = 420;
        pageView.frame = frame; 
        return pageView;
        
    }
	
}
#pragma mark -
#pragma mark UILongPressGestureRecognizer handling

- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    
    HGPageScrollView *pageScrollView = _myPageScrollView;
    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex];
    
    NSString *pageId = pageData.title;

    MyPageView *pageView = (MyPageView*)[pageScrollView getCurrentPageWithIdentifier:pageId];
    UIWebView *webView = pageView.webView;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:webView];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [webView frame].size;
        CGSize windowSize = [webView windowSize];
        
        CGFloat f = windowSize.width / viewSize.width;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.) {
            point.x = point.x * f;
            point.y = point.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [webView scrollOffset];
            point.x = point.x * f + offset.x;
            point.y = point.y * f + offset.y;
        }
        
        // Load the JavaScript code from the Resources and inject it into the web page
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CIALBrowser" ofType:@"bundle"]];
        
        NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
        NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString: jsCode];
        
        // get the Tags at the touch location
        NSString *tags = [webView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%li,%li);",(long)point.x,(long)point.y]];
        
        NSString *tagsHREF = [webView stringByEvaluatingJavaScriptFromString:
                              [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%li,%li);",(long)point.x,(long)point.y]];
        
        NSString *tagsSRC = [webView stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%li,%li);",(long)point.x,(long)point.y]];
        NSLog(@"tags : %@",tags);
        NSLog(@"href : %@",tagsHREF);
        NSLog(@"src : %@",tagsSRC);
        
        NSString *url = nil;
        if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
            url = tagsSRC;
        }
        if ([tags rangeOfString:@",A,"].location != NSNotFound) {
            url = tagsHREF;
        }
        
        NSArray *urlArray = [[url lowercaseString] componentsSeparatedByString:@"/"];
        NSString *urlBase = nil;
        if ([urlArray count] > 2) {
            urlBase = [urlArray objectAtIndex:2];
        }
        if ((url == nil) &&
            ([url length] == 0)) {
            url = tagsSRC;
        }
        
        if ((url != nil) &&
            ([url length] != 0)) {
            // Release any previous request
            // Save URL for the request
            _urlToHandle = [[NSURL alloc] initWithString:url];
            
            // ask user what to do
            _longPressActionSheet = [[UIActionSheet alloc] initWithTitle:[_urlToHandle.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
            _longPressActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            if (downloadURL.absoluteString.length >1) {
                downloadButtonIndex = [_longPressActionSheet addButtonWithTitle:@"Download Video"];
            }
            openLinkButtonIndex = [_longPressActionSheet addButtonWithTitle:@"Open"];
            copyButtonIndex = [_longPressActionSheet addButtonWithTitle:@"Copy"];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGPoint touchPosition = [gestureRecognizer locationInView:webView];
                [_longPressActionSheet showFromRect:CGRectMake(touchPosition.x, touchPosition.y, 1, 1)
                                             inView:webView
                                           animated:YES];
            } else {
                _longPressActionSheet.cancelButtonIndex = [_longPressActionSheet addButtonWithTitle:@"Cancel"];
                [_longPressActionSheet showInView:self.view];
            }
        }
    }
}
#pragma mark -
#pragma mark UIActionSheet delegate
-(UIWebView *)getWebView{
    
    HGPageScrollView *pageScrollView = _myPageScrollView;
    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex];
    
    NSString *pageId = pageData.title;

    MyPageView *pageView = (MyPageView*)[pageScrollView getCurrentPageWithIdentifier:pageId];
    return pageView.webView;
}
- (void)loadURL:(NSURL *)url {
    
    
    if (!url) return;
    
    _addressBar.textField.text = url.absoluteString;
    
    [[self getWebView] loadRequest:[NSURLRequest requestWithURL:url]];
}
- (void)addBookmark {
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIWebView *webView = [self getWebView];
    if (copyButtonIndex == buttonIndex) {
        NSString *urlString;
        NSURLRequest *req = [self getWebView].request;
        if (req != nil) {
            urlString = [req.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            urlString = [_urlToHandle.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        [pasteBoard setValue:urlString forPasteboardType:@"public.utf8-plain-text"];
    }
    else if (downloadButtonIndex == buttonIndex){
        [self btnDownloadClicked];
    }
    else if (openLinkButtonIndex == buttonIndex) {
        [self loadURL:_urlToHandle];
        _urlToHandle = nil;
    } else if (addBookmarkButtonIndex == buttonIndex) {
        [self addBookmark];
    } else if (openWithSafariButtonIndex == buttonIndex) {
        [[UIApplication sharedApplication] openURL:_urlToHandle];
    } else if (sendUrlButtonIndex == buttonIndex) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
        [mailViewController setMessageBody:[webView.request.URL absoluteString]
                                    isHTML:NO];
        
        mailViewController.mailComposeDelegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        [self presentViewController:mailViewController animated:YES completion:NULL];
    }
 else if (printButtonIndex == buttonIndex) {
        Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
        
        if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
        {
            printInteraction = [printInteractionController sharedPrintController];
            printInteraction.delegate = self;
            
            UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];
            
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            
            printInteraction.printInfo = printInfo;
            printInteraction.showsPageRange = YES;
            
            UIViewPrintFormatter *formatter = [webView viewPrintFormatter];
            printInteraction.printFormatter = formatter;
//            
//            [printInteraction presentFromBarButtonItem:_editButtonItem
//                                              animated:YES
//                                     completionHandler:
//             ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
//             }
//             ];
        }
    }
    
    
}
#pragma mark -

- (void) updateLocationField {
    UIWebView *webView = [self getWebView];
    NSString *location = webView.request.URL.absoluteString;
    if (location.length)
        _addressBar.textField.text = webView.request.URL.absoluteString;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    downloadURL = nil;
    [self updateLocationField];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _longPressActionSheet)
    {
        _longPressActionSheet = nil;
    }
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;  
{
    if(scrollView.viewMode == HGPageScrollViewModePage){
        [scrollView.pageHeaderView setHidden:YES];
        return @"";
    }
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index];
    return [headerInfo webTitle];
        
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;  
{
    if(scrollView.viewMode == HGPageScrollViewModePage){
        return @"";
    }
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index]; 
    return [headerInfo pageSubtitle];
}


- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // in this sample project, the page at index 0 is a navigation controller. 
        return pageData.navController.topViewController;
    }
    else{
        return [_myPageDataArray objectAtIndex:index];        
    }
}

#pragma mark - 
#pragma mark HGPageScrollViewDelegate

- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    _addressBar.textField.text = pageData.subtitle;

    if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[scrollView pageAtIndex:index];
        UILabel *titleLabel = (UILabel*)[page viewWithTag:1];
        [titleLabel setHidden:YES];
        UIScrollView *pageContentsScrollView = (UIScrollView*)[page viewWithTag:10];
        
        if (!page.isInitialized) {
            // prepare the page for interaction. This is a "second step" initialization of the page 
            // which we are deferring to just before the page is selected. While the page is initially
            // requeseted (pageScrollView:viewForPageAtIndex:) this extra step is not required and is preferably 
            // avoided due to performace reasons.  
            
            // asjust text box height to show all text
            UITextView *textView = (UITextView*)[page viewWithTag:3];
            CGFloat margin = 12;
            CGSize size = [textView.text sizeWithFont:textView.font
                                    constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
                                        lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = textView.frame;
            frame. size.height = size.height + 4*margin;
            textView.frame = frame;
            
            // adjust content size of scroll view
            pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
            
            // mark the page as initialized, so that we don't have to do all of the above again 
            // the next time this page is selected
            page.isInitialized = YES;  
        }
        
        // enable scroll
        pageContentsScrollView.scrollEnabled = YES;
        
    }
    else{
        if (kPlatformSupportsViewControllerHeirarchy) {

            // this page is presented within UINavigationController navigation stack
            // while in DECK mode, the view controller owning this view is our own child. This is done to be consistent with iOS view-heirarchy rules. 
            // Now that the page is about to be selected (HGPageScroller is switching to PAGE mode), we need to associate the view controller with the UINaivationController in which it belongs.
            UIViewController *childViewController = [self.childViewControllers objectAtIndex:0];
            [pageData.navController pushViewController:childViewController animated:NO]; 
        }
    }
    
    [self showHideToolBaar];
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // copy the toolbar items to the navigation controller
        [pageData.navController.topViewController setToolbarItems:toolbar.items];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:pageData.navController animated:NO];
    }
    else{
        // add "edit" button to the toolbar
        
    }

}

- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
    if (!pageData.navController) {
        // disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
        HGPageView *page = [scrollView pageAtIndex:index];
        UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
        scrollContentView.scrollEnabled = NO;

        }
    else{
        if ([self respondsToSelector:@selector(addChildViewController:)]) {

            // this page is presented within UINavigationController navigation stack
            // while in PAGE mode, the view controller owning this page is a child of UINavigationController. 
            // Before moving back to DECK mode, we need to re-associate this view controller with us (making it our child). After the transition to DECK mode completes, the page is inserted as a subview into HGPageScrollView. Before this happens, the view controller owning this page must be our own child. This is done to be consistent with iOS view-heirarchy rules.
            UIViewController *viewController = pageData.navController.topViewController;
            [self addChildViewController:viewController];
        }
    }

    
}


- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    // Now the page scroller is in DECK mode. 
    // Complete an add/remove pages request if one is pending
    if (indexesToDelete) {
        [self removePagesAtIndexSet:indexesToDelete];
        indexesToDelete = nil;
    }
    if (indexesToInsert) {
        [self addPagesAtIndexSet:indexesToInsert];
        indexesToInsert = nil;
    }
}



#pragma mark - toolbar Actions
-(void)setPageWithAnimation:(BOOL)animation{

    HGPageScrollView *pageScrollView = _myPageScrollView;
    
    
    if (self.modalViewController) {
        MyPageData *pageData = [_myPageDataArray objectAtIndex:[pageScrollView indexForSelectedPage]];
        [self dismissModalViewControllerAnimated:NO];
        // copy the toolbar items back to our own toolbar
    }
    
    if(pageScrollView.viewMode == HGPageScrollViewModePage){
        [pageScrollView deselectPageAnimated:animation];
    }
    else {
        [pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:animation];
    }

}

- (IBAction) didClickBrowsePages : (id) sender
{
    [self setPageWithAnimation:YES];

    [self hideTabBar];
}
-(void)showHideToolBaar{
    if(_myPageScrollView.viewMode == HGPageScrollViewModePage){
        toolbar.hidden = false;
        searchBar.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            toolbar.alpha = 1.0;
            editToolbar.alpha = 0.0f;
            searchBar.alpha = 1.0;
            _addressBar.alpha = 1.0;
            self.tabBarController.tabBar.hidden = false;

        } completion: ^(BOOL finished) {//creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.

        }];
        

    }
    else{
        [self hideTabBar];
      
    }
}
-(void)hideTabBar{
    [UIView animateWithDuration:0.3 animations:^{
//        [_myPageScrollView setFrame:self.view.frame];
        toolbar.alpha = .0;
        searchBar.alpha = .0;
        _addressBar.alpha = 0.0;
        editToolbar.alpha = 1.0;
        self.tabBarController.tabBar.hidden = YES;
    } completion: ^(BOOL finished) {//creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.
        
    }];
}
- (IBAction) didClickAddPage : (id) sender
{
    HGPageScrollView *pageScrollView = _myPageScrollView;
    
    // create an index set of the pages we wish to add

    // example 1: inserting one page at the current index  
    NSInteger selectedPageIndex = [pageScrollView indexForSelectedPage];
    indexesToInsert = [[NSMutableIndexSet alloc] initWithIndex:(selectedPageIndex == NSNotFound)? 0 : _myPageDataArray.count];

    // example 2: appending 2 pages at the end of the page scroller 
    //NSRange range; range.location = [_myPageDataArray count]; range.length = 2;
    //indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];

    // example 3: inserting 2 pages at the beginning of the page scroller 
    //NSRange range; range.location = 0; range.length = 2;
    //indexesToInsert = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];

    
    // we can only insert pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [self didClickBrowsePages:self];
    }
    else{
        [self addPagesAtIndexSet:indexesToInsert];
        indexesToInsert = nil;
    }

}



- (void) addPagesAtIndexSet : (NSIndexSet *) indexSet 
{
    // create new pages and add them to the data set 
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MyPageData *pageData = [[MyPageData alloc] init] ;
        pageData.title = [NSString stringWithFormat:@"%d", idx];
        pageData.subtitle = @"http://www.google.com";
        pageData.webTitle = @"Google";
        [_myPageDataArray addObject:pageData];
    }];
    
    // update the page scroller 
    HGPageScrollView *pageScrollView = _myPageScrollView;
    [pageScrollView insertPagesAtIndexes:indexSet animated:YES];
    [pageScrollView scrollToPageAtIndex:_myPageDataArray.count-1 animated:NO];

    return;
    // update the toolbar
   
    
}


- (IBAction) didClickRemovePage : (id) sender
{
    HGPageScrollView *pageScrollView = _myPageScrollView;
    
    // create an index set of the pages we wish to delete
    
    // example 1: deleting the page at the current index
    indexesToDelete = [[NSMutableIndexSet alloc] initWithIndex:[pageScrollView indexForSelectedPage]];
    
    // example 2: deleting the last 2 pages from the page scroller
    //NSRange range; range.location = [_myPageDataArray count] - 2; range.length = 2;
    //indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
        
    // example 3: deleting the first 2 pages from the page scroller
    //NSRange range; range.location = 0; range.length = 2;
    //indexesToDelete = [[NSMutableIndexSet alloc] initWithIndexesInRange:range];
    
    // we can only delete pages in DECK mode
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    }
    else{
        [self removePagesAtIndexSet:indexesToDelete];
        indexesToDelete = nil;
    }
    
}


- (void) removePagesAtIndexSet : (NSIndexSet *) indexSet 
{
    HGPageScrollView *pageScrollView = _myPageScrollView;

    // remove from the data set
    [_myPageDataArray removeObjectsAtIndexes:indexSet];

    // update the page scroller
    [pageScrollView deletePagesAtIndexes:indexSet animated : YES];
    
    // update toolbar
   
    
}



- (IBAction) didClickEditPage : (id) sender
{
    
    HGPageScrollView *pageScrollView = _myPageScrollView;

    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex]; 
    if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[pageScrollView pageAtIndex:selectedIndex];
        UITextField *textField = (UITextField*)[page viewWithTag:4];
        textField.hidden = NO;
        textField.text = pageData.title;
        textField.delegate = self;
        [textField becomeFirstResponder];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;            
{
    HGPageScrollView *pageScrollView = _myPageScrollView;
    NSInteger selectedIndex = [pageScrollView indexForSelectedPage];
    MyPageData *pageData = [_myPageDataArray objectAtIndex:selectedIndex];
    
    NSString *pageId = pageData.title;
    pageData.subtitle = textField.text;
    [pageData setTitleOFweb:pageData.subtitle];
    MyPageView *pageView = (MyPageView*)[pageScrollView getCurrentPageWithIdentifier:pageId];
    [pageView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
    [textField resignFirstResponder];
    
    return YES;
    
    pageData.title = textField.text;   

    [textField resignFirstResponder];
    textField.hidden = YES;
    textField.delegate = nil;
    
    indexesToReload = [[NSMutableIndexSet alloc] initWithIndex:selectedIndex];
    
    if (pageScrollView.viewMode == HGPageScrollViewModePage) {
        [pageScrollView deselectPageAnimated:YES];
    }
    else{
        [self reloadPagesAtIndexSet : indexesToReload];
    }
    
    return YES;
}

- (void) reloadPagesAtIndexSet : (NSIndexSet*) indexSet 
{
    HGPageScrollView *pageScrollView = _myPageScrollView;
    [pageScrollView reloadPagesAtIndexes:indexesToReload];
}


@end

