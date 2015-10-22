//
//  DownloadCell.h
//  HGPageScrollViewSample
//
//  Created by Sunny on 5/17/15.
//
//

#import <UIKit/UIKit.h>
#import "DownloadModel.h"

@interface DownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIProgressView *processBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;

@property (weak, nonatomic) IBOutlet UIImageView *sepImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblProcess;


@property (nonatomic, strong) DownloadModel *downloadModel;

@end
