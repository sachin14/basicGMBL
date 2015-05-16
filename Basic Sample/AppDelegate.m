
#import "AppDelegate.h"
#import <Gimbal/Gimbal.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // To get started with an API key, go to https://manager.gimbal.com/
#warning Instert your Gimbal Application API key below in order to see this sample application work
    [Gimbal setAPIKey:@"24989070-de5c-47fa-b39c-987d6ec6bcf0" options:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasBeenPresentedWithOptInScreen"] == NO)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Opt-In" bundle:nil] instantiateInitialViewController];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [self processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    [self registerForNotifications:application];
    
    return YES;
}

# pragma mark - Remote Notification Support

- (void)registerForNotifications:(UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Gimbal setPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processRemoteNotification:userInfo];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForRemoteNotification:userInfo];
    if (communication)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSH_NOTIFICATION_RECEIVED"
                                                            object:nil
                                                          userInfo:@{@"COMMUNICATION": communication}];
    }
}

@end
