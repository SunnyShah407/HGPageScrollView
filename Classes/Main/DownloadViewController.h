//
//  DownloadViewController.h
//  VideoDownload
//
//  Created by Sunny on 4/28/15.
//  Copyright (c) 2015 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNURLConnection.h"
@interface DownloadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,BNURLConnectionProgressDelegate,UINavigationControllerDelegate>{
    IBOutlet UITableView *tableView;
}
@property(nonatomic,retain) NSMutableArray *arrData;
@end
