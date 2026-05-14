//
//  SceneDelegate.m
//  ExampleOC
//
//  Created by CoderChan on 10/31/25.
//

#import "SceneDelegate.h"
#import "MarsLog.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"willConnectToSession"];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"sceneDidDisconnect"];
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"sceneDidBecomeActive"];
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"sceneWillResignActive"];
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"sceneWillEnterForeground"];
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    [MarsLogger.sharedLogger logWithLevel:(MarsLogLevelInfo) moduleName:@"1234" fileName:__FILE__ lineNumber:__LINE__ funcName:__FUNCTION__ format:@"sceneDidEnterBackground"];
}



@end
