//
//  AppDelegate.m
//  DocuSign
//
//  Created by Aniket on 1/22/14.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self addLocalDocuments];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:128.0/255 blue:1 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)addLocalDocuments {
    //Copy Some Dummy Documents to Local directory
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"DocumentsCopied"] boolValue]) {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * documentsDirectory = [(NSURL *)[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];

        NSArray * tempFiles = @[@"Dummy Document.docx",@"Another Dummy Document.docx"];
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
