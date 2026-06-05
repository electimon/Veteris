//
//  main.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "AntiDebug.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        root_anti_debugging();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
