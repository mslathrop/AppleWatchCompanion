//
//  AppDelegate.m
//  NanoCompanion
//
//  Created by Steven Troughton-Smith on 13/01/2015.
//  Copyright (c) 2015 High Caffeine Content. All rights reserved.
//

#import "AppDelegate.h"

@protocol Companion <NSObject>

- (id)initFromPropertyList:(id)arg1;
- (void)updatedIconGraph:(id)arg1;

@end

@implementation AppDelegate

-(NSString *)sanitizedName:(NSString *)name
{
    NSString *s = [name stringByReplacingOccurrencesOfString:@"Settings" withString:@""];
    
    s = [s stringByReplacingOccurrencesOfString:@"Bridge" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"Nano" withString:@""];
    return s;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    NSMutableArray *vcs = @[].mutableCopy;
    
    NSArray *paths = @[@"/System/Library/NanoPreferenceBundles/Applications/", @"/System/Library/NanoPreferenceBundles/General/", @"/System/Library/NanoPreferenceBundles/Customization/",@"/System/Library/NanoPreferenceBundles/Privacy/"];
    
    for (NSString *path in paths)
    {
        NSArray *category = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        for (NSString *bundle in category)
        {
            if ([bundle isEqualToString:@"NanoPassbookBridgeSettings.bundle"])
                continue;
            
            NSLog(@"Loading Bundle %@", bundle);
            
            NSBundle *b = [NSBundle bundleWithPath:[path stringByAppendingPathComponent:bundle]];
            [b load];
            
            UIViewController *vc = [[[b principalClass] alloc] init];
            
            if ([[vc class] isEqual:NSClassFromString(@"CSLUILayoutNavController")])
            {
                UIViewController<Companion> *carousel = [vc valueForKey:@"layoutViewController"];
                
                NSDictionary *defaultIcons = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/NanoPreferenceBundles/Customization/CarouselLayoutSettings.bundle/DefaultIconPositions.plist"];
                
                NSObject<Companion> *graph = [[NSClassFromString(@"CSLHexAppGraph") alloc] initFromPropertyList:defaultIcons];
                [carousel updatedIconGraph:graph];
            }
            
            if ([[vc class] isSubclassOfClass:[UINavigationController class]])
            {
                vc.tabBarItem.title = [self sanitizedName:b.infoDictionary[@"CFBundleName"]];
                [vcs addObject:vc];
            }
            else
            {
                UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
                navC.tabBarItem.title = [self sanitizedName:b.infoDictionary[@"CFBundleName"]];
                [vcs addObject:navC];
            }
        }
    }
    
    UITabBarController *tabVC = [[UITabBarController alloc] init];
    
    tabVC.viewControllers = vcs;
    
    self.window.rootViewController = tabVC;
    
    return YES;
}

@end