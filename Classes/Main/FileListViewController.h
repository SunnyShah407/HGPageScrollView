//
//  FileListViewController.h
//  VideoDownload
//
//  Created by Sunny on 4/28/15.
//  Copyright (c) 2015 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileCell.h"
#import <QuickLook/QuickLook.h>
#import <MediaPlayer/MediaPlayer.h>
@interface FileListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>{
    IBOutlet UITableView *tableViewList;
}
@property (nonatomic , retain) NSMutableArray *arrFiles;
@property (nonatomic ,retain) MPMoviePlayerViewController *playerViewController;
@end
