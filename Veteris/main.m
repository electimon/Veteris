//
//  main.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //if (!(setuid(0) == 0 && setgid(0) == 0))
        //{
        //    NSLog(@"Failed to gain root privileges, aborting...");
            //exit(EXIT_FAILURE);
        //}
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
