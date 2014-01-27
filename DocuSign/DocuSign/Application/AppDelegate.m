//
//  AppDelegate.m
//  DocuSign
//
//  Created by Aniket on 1/22/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self addLocalDocuments];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:128.0/255 blue:1 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    return YES;
}

/* Copy Some Dummy Documents to Local Directory */
- (void)addLocalDocuments {
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"DocumentsCopied"] boolValue]) {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];

        NSArray * tempFiles = @[@"Dummy Document.doc",@"Another Dummy Document.doc"];
        [tempFiles enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
            NSError * error = nil;
            NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            [fileManager copyItemAtPath:path toPath:[documentsDirectory stringByAppendingPathComponent:fileName] error:&error];
             if (error) NSLog(@"Failed To Copy %@\n Due To:%@",fileName,error.localizedDescription);
        }];
    }
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"DocumentsCopied"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
