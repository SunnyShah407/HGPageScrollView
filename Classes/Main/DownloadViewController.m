//
//  DownloadViewController.m
//  VideoDownload
//
//  Created by Sunny on 4/28/15.
//  Copyright (c) 2015 Sunny. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadCell.h"
@interface DownloadViewController ()

@end

@implementation DownloadViewController
@synthesize arrData;
- (void)viewDidLoad {
    [super viewDidLoad];
    [tableView registerNib:[UINib nibWithNibName:@"DownloadCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    if (!arrData) {
        arrData = [[NSMutableArray alloc]init];
        [self getAllVideo];

    }
    [tableView reloadData];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [tableView reloadData];
}
-(void)getAllVideo{
    NSFileManager *fm=[NSFileManager defaultManager];
    NSString *strPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"downloads"];
   NSArray *paths= [fm contentsOfDirectoryAtPath:strPath error:nil];
    for (NSString *strName in paths) {
        if ([strName.pathExtension isEqualToString:@"plist"]) {
            NSString *plistPath = [strPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[strName stringByDeletingPathExtension]]];
            BNURLConnection*   connection = [BNURLConnection resumeConnectionWithFilePath:plistPath];
            connection.progressDelegate = self;
            [arrData addObject:connection];
        }
        

    }
}
-(void)downloadNotification:(NSNotification *)notificaiton{
    if (!arrData) {
        arrData = [[NSMutableArray alloc]init];
        [self getAllVideo];
        
    }
    BNURLConnection*   connection = [BNURLConnection downloadFileByURL:[notificaiton object]];
    connection.progressDelegate = self;
  
    [arrData addObject:connection];
    [tableView reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrData.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadCell *cell = [tableView1 dequeueReusableCellWithIdentifier:@"cell"];
    BNURLConnection *connection = [arrData objectAtIndex:indexPath.row];
    cell.lblTitle.text = [connection.currentFilePath lastPathComponent];


    
    cell.sepImageView.frame = CGRectMake(0, cell.sepImageView.frame.origin.y, self.view.frame.size.width, .5);
    cell.btnPause.tag = indexPath.row + 1;
    [cell.btnPause addTarget:self action:@selector(btnPauseClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)btnPauseClicked:(UIButton *)sender{
    BNURLConnection *connection =[arrData objectAtIndex:[sender tag] -1];
    
    if (connection.isDownloadStop) {
        [connection resumeCurrnetDownload];
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else{
        [connection stopDownload];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateProcessWithCurrent:(CGFloat)current withTotal:(CGFloat)total withObject:(BNURLConnection *)connection withSpeed:(CGFloat)speed{
    NSInteger index = [arrData indexOfObject:connection];
    DownloadCell *cell = (DownloadCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.lblProcess.text = [NSString stringWithFormat:@"%@ / %@ Speed :%f/s",[self transformedValue:current] , [self transformedValue:total] , speed];
    cell.processBar.progress = (float)current/(float)total;
}
-(void)updateBarWithProgress:(CGFloat)progress withObject:(BNURLConnection *)connection{
    NSInteger index = [arrData indexOfObject:connection];
    DownloadCell *cell = (DownloadCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    cell.processBar.progress = progress;

}
- (id)transformedValue:(CGFloat)convertedValue
{
    
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

-(BOOL)finishDownloadFile:(NSString *)filename withObject:(BNURLConnection *)connection{
//    _pathContent.text = [_pathContent.text stringByAppendingFormat:@"\nfinish"] ;
//    connection = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_NOTIFICATION object:filename];
    [arrData removeObject:connection];
    [tableView reloadData];
    return YES;
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}
@end
