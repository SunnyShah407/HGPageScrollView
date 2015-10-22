//
//  MyPageData.m
//  HGPageDeckSample
//
//  Created by Rotem Rubnov on 12/3/2011.
//	Copyright (C) ___YEAR___ ___ORGANIZATIONNAME___
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

#import "MyPageData.h"


@implementation MyPageData
@synthesize webTitle;
@synthesize title, subtitle, image, navController; 


#pragma mark - PageScrollerHeaderInfo

- (NSString*) pageTitle
{
    return self.title;
}

-(void)setTitleOFweb:(NSString *)strWeb;
{
    
   
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title[^>]*>(.*?)</title>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSURL *url = [NSURL URLWithString:strWeb];
    NSString *urlStr= [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
    if (urlStr.length<3) {
        return;
    }
    [regex enumerateMatchesInString:urlStr
                            options:0
                              range:NSMakeRange(0, [urlStr length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             self.webTitle= [urlStr substringWithRange:[result rangeAtIndex:1]];
                            }];
}

- (NSString*) pageSubtitle
{
    return self.subtitle;
}


#pragma mark - NSObject 

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ 0x%x: %@", [self class], self, self.title];
}

@end
