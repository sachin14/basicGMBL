
#import "ViewController.h"

#import <Gimbal/Gimbal.h>

@interface ViewController () <GMBLPlaceManagerDelegate, GMBLCommunicationManagerDelegate>

@property (nonatomic) GMBLPlaceManager *placeManager;
@property (nonatomic) GMBLCommunicationManager *communicationManager;

@property (nonatomic, readonly) NSArray *events;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeManager = [GMBLPlaceManager new];
    self.placeManager.delegate = self;
    
    self.communicationManager = [GMBLCommunicationManager new];
    self.communicationManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNotification:)
                                                 name:@"PUSH_NOTIFICATION_RECEIVED"
                                               object:nil];
}

- (void)didReceiveNotification:(NSNotification *)notification
{
    GMBLCommunication *communication = notification.userInfo[@"COMMUNICATION"];
    if (communication)
    {
       
        [self addEventWithMessage:communication.descriptionText date:[NSDate date] icon:@"commEnter.png"];
    }
}

# pragma mark - Gimbal PlaceManager delegate methods

- (void)placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit
{
    [self addEventWithMessage:visit.place.name date:visit.arrivalDate icon:@"placeEnter.png"];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit
{
    [self addEventWithMessage:visit.place.name date:visit.departureDate icon:@"placeExit.png"];
}

- (void)placeManager:(GMBLPlaceManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting forVisits:(NSArray *)visits
{
    // this will be invoked when a beacon assigned to a place within a current visit is sighted.
}

# pragma mark - Gimbal CommunicationManager delegate methods

- (NSArray *)communicationManager:(GMBLCommunicationManager *)manager
presentLocalNotificationsForCommunications:(NSArray *)communications
                         forVisit:(GMBLVisit *)visit
{
    for (GMBLCommunication *communication in communications)
    {
        //NSString *message1 = [NSString alloc]initWith
        [self addEventWithMessage:communication.descriptionText date:[NSDate date] icon:@"commEnter.png"];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        localNotification.alertBody = communication.descriptionText;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    return communications;
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *item = self.events[indexPath.row];
    
    cell.textLabel.text = item[@"message"];
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:item[@"date"]
                                                               dateStyle:NSDateFormatterMediumStyle
                                                               timeStyle:NSDateFormatterMediumStyle];
    cell.imageView.image = [UIImage imageNamed:item[@"icon"]];
    
    return cell;
}

#pragma mark - Utility methods

- (NSArray *)events
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"events"];
}

- (void)addEventWithMessage:(NSString *)message date:(NSDate *)date icon:(NSString *)icon
{
    NSDictionary *item = @{@"message":message, @"date":date, @"icon":icon};
    
    NSLog(@"Event %@",[item description]);
    
    NSMutableArray *events = [NSMutableArray arrayWithArray:self.events];
    [events insertObject:item atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:@"events"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
