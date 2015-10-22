//
//  FileListViewController.m
//  VideoDownload
//
//  Created by Sunny on 4/28/15.
//  Copyright (c) 2015 Sunny. All rights reserved.
//

#import "FileListViewController.h"

@interface FileListViewController ()

@end

@implementation FileListViewController
@synthesize arrFiles;
@synthesize playerViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!arrFiles) {
        arrFiles = [[NSMutableArray alloc]init];
        [self getAllVideo];

    }

    [tableViewList registerNib:[UINib nibWithNibName:@"FileCell" bundle:nil] forCellReuseIdentifier:@"filecell"];
    
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getAllVideo{
    NSFileManager *fm=[NSFileManager defaultManager];
    NSArray *paths=[fm contentsOfDirectoryAtPath:DOCUMENT_PATH error:nil];
    for (NSString *strName in paths) {
        NSString *strFullPath=[DOCUMENT_PATH stringByAppendingPathComponent:strName];
        if (![strFullPath isEqualToString:[DOCUMENT_PATH stringByAppendingPathComponent:@"downloads"]]) {
            [arrFiles addObject:strFullPath];

        }
    }
}

-(void)fileNotification:(NSNotification *)notification{
    if (!arrFiles) {
        arrFiles = [[NSMutableArray alloc]init];
    }
    [tableViewList reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrFiles.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileCell *cell = [tableView1 dequeueReusableCellWithIdentifier:@"filecell"];
    cell.lblTitle.text = [[arrFiles objectAtIndex:indexPath.row] lastPathComponent];
    cell.sepImageView.frame = CGRectMake(0, cell.sepImageView.frame.origin.y, self.view.frame.size.width, .5);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableViewList deselectRowAtIndexPath:indexPath animated:YES];
    
    NSURL *URL = [NSURL fileURLWithPath:[arrFiles objectAtIndex:indexPath.row]];
    self.playerViewController =
    [[MPMoviePlayerViewController alloc]
     initWithContentURL:URL];
    self.playerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
   
    
    
    [self presentViewController:self.playerViewController animated:YES completion:NULL];
    
    //---play movie---
    //MPMoviePlayerController *player =[self.playerViewController moviePlayer];
    //[player play];
    [playerViewController.moviePlayer play];
    return;
    QLPreviewController *preview=[[QLPreviewController alloc]init];
    preview.delegate=self;
    preview.dataSource=self;
    [self.navigationController presentViewController:preview animated:YES completion:NULL];
}
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return [arrFiles count];
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
      
    return [NSURL fileURLWithPath:[arrFiles objectAtIndex:index]];
}
@end
