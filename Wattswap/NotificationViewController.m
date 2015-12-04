//
//  NotificationViewController.m
//  TagN
//
//  Created by Jhpassion0621 on 3/13/15.
//  Copyright (c) 2015 DMSoft. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationOtherTableCell.h"

@interface NotificationViewController () <DMScrollingHeaderViewDelegate>

@end

@implementation NotificationViewController

@synthesize m_tblNotifications;
@synthesize m_lblNoNotification;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self followScrollView:m_tblNotifications withHeaderView:self.m_vwHeader];
    [self setShouldScrollWhenContentFits:NO];
    [self setScrollingHeaderViewDelegate:self];
    
    [self showHeaderViewAnimated:NO];
    
    m_refreshControl = [[UIRefreshControl alloc] init];
    [m_refreshControl addTarget:self action:@selector(onRefreshPhotos) forControlEvents:UIControlEventValueChanged];
    
    [m_tblNotifications addSubview:m_refreshControl];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self showHeaderViewAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications.count > 0) {
        m_lblNoNotification.hidden = YES;
    } else {
        m_lblNoNotification.hidden = NO;
    }
    
    [GlobalData sharedGlobalData].g_appDelegate.m_nBadges = 0;
    [[WebService sharedInstance] setAsReadNotificationsWithUserId:[GlobalData sharedGlobalData].g_userMe.user_id
                                                        Completed:^{
                                                            NSLog(@"Success set as read");
                                                        }
                                                           Failed:^(NSString *strError) {
                                                               NSLog(@"%@", strError);
                                                           }];
    
    [[GlobalData sharedGlobalData].g_tabbar.tabBar.items[3] setBadgeValue:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [m_tblNotifications reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)onRefreshPhotos {
    [[WebService sharedInstance] getNotificationsWithUserId:([GlobalData sharedGlobalData].g_userMe)?[GlobalData sharedGlobalData].g_userMe.user_id:@0
                                                  Completed:^(NSArray *aryNotifications) {
#if DEBUG
                                                      NSLog(@"AppDelegate - GetNotifications succeeded");
#endif
                                                      [m_refreshControl endRefreshing];
                                                      [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications = [aryNotifications mutableCopy];
                                                      
                                                      m_nBadges = 0;
                                                      for(int nIndex = 0; nIndex < [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications.count; nIndex++) {
                                                          Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[nIndex];
                                                          
                                                          if(nIndex < 20 && notification.notification_type.integerValue == TAGN_PUSH_ACCEPT_INVITATION) {
                                                              
                                                              NSNumber *user_id = [NSNumber numberWithInteger:((NSString*)[notification.notification_extra objectForKey:@"notification_from_user_id"]).integerValue];
                                                              [[WebService sharedInstance] getUserInfoWithUserId:user_id
                                                                                                       Completed:^(NSDictionary *dicUser) {
                                                                                                           
                                                                                                           [[GlobalData sharedGlobalData].g_appDelegate registerUser2ContactsWithData:dicUser];
                                                                                                       }
                                                                                                          Failed:^(NSString *strError) {
                                                                                                              NSLog(@"%@", strError);
                                                                                                          }];
                                                              
                                                          }
                                                          
                                                          if(notification.notification_is_read == NO) {
                                                              m_nBadges++;
                                                          }
                                                      }
                                                      
                                                      if(m_nBadges > 0) {
                                                          [[GlobalData sharedGlobalData].g_tabbar.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%d", m_nBadges]];
                                                      } else {
                                                          [[GlobalData sharedGlobalData].g_tabbar.tabBar.items[3] setBadgeValue:nil];
                                                      }
                                                      
                                                      [m_tblNotifications reloadData];
                                                  }
                                                     Failed:^(NSString *strError) {
#if DEBUG
                                                         NSLog(@"AppDelegate - GetNotifications failed");
                                                         NSLog(@"%@", strError);
#endif
                                                     }];

}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
    
    if(notification.notification_type.intValue == TAGN_PUSH_ADD_MEMBER) {
    
        __weak NotificationTableCell *cell = (NotificationTableCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationTableCell"];
        
        [cell.imgAvatar drawView];
        
        UIImage *imgAvatar = [[CoreDataService sharedInstance] imageWithUrl:notification.notification_user_avatar];
        if(imgAvatar) {
            cell.imgAvatar.image = imgAvatar;
        } else {
            [cell.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:notification.notification_user_avatar]]
                                  placeholderImage:[UIImage imageNamed:@"icon_defaultAvatar"]
                       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               cell.imgAvatar.image = image;
                                               [[CoreDataService sharedInstance] saveImage:image withUrl:notification.notification_user_avatar];
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               NSLog(@"%@", error.description);
                                           }];
        }
        
        cell.lblMessage.text = notification.notification_string;
        cell.delegate = self;
        
        return cell;
    } else {
        __weak NotificationOtherTableCell *cell = (NotificationOtherTableCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationOtherTableCell"];
        
        [cell.imgAvatar drawView];
        
        UIImage *imgAvatar = [[CoreDataService sharedInstance] imageWithUrl:notification.notification_user_avatar];
        if(imgAvatar) {
            cell.imgAvatar.image = imgAvatar;
        } else {
            [cell.imgAvatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:notification.notification_user_avatar]]
                                  placeholderImage:[UIImage imageNamed:@"icon_defaultAvatar"]
                       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               cell.imgAvatar.image = image;
                                               [[CoreDataService sharedInstance] saveImage:image withUrl:notification.notification_user_avatar];
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               NSLog(@"%@", error.description);
                                           }];
        }
        
        cell.lblMessage.text = notification.notification_string;
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
    
    if(notification.notification_type.intValue == TAGN_PUSH_ADD_MEMBER) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
        
        SVPROGRESSHUD_SHOW;
        [[WebService sharedInstance] removeNotificationWithNotificationId:notification.notification_id
                                                                Completed:^{
                                                                    SVPROGRESSHUD_DISMISS;
                                                                    [[GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications removeObjectAtIndex:indexPath.row];
                                                                    [m_tblNotifications deleteRowsAtIndexPaths:@[indexPath]
                                                                                              withRowAnimation:UITableViewRowAnimationFade];
                                                                }
                                                                   Failed:^(NSString *strError) {
                                                                       SVPROGRESSHUD_ERROR(strError);
                                                                   }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
    switch (notification.notification_type.intValue) {
        case TAGN_PUSH_ADD_MEMBER:
        case TAGN_PUSH_ACCEPT_INVITATION:
        case TAGN_PUSH_DECLINE_INVITATION:
        case TAGN_PUSH_REMOVE_MEMBER:
        case TAGN_PUSH_REMOVE_PHOTO:
        case TAGN_PUSH_REMOVE_SHARE:
        case TAGN_PUSH_REMOVE_COMMENT:
            break;
        case TAGN_PUSH_UPLOAD_PHOTO: {
            [GlobalData sharedGlobalData].g_tabbar.selectedIndex = 0;
            [[GlobalData sharedGlobalData].g_tabbar.m_sharedTagNVC goToImage:[[Image alloc] initWithDict:notification.notification_extra] NotificationType:TAGN_PUSH_UPLOAD_PHOTO];
        }
            break;

        case TAGN_PUSH_ADD_COMMENT: {
            [GlobalData sharedGlobalData].g_tabbar.selectedIndex = 0;
            [[GlobalData sharedGlobalData].g_tabbar.m_sharedTagNVC goToImage:[[Image alloc] initWithDict:notification.notification_extra] NotificationType:TAGN_PUSH_ADD_COMMENT];
        }
            break;
        case TAGN_PUSH_LIKED_IMAGE: {
            [GlobalData sharedGlobalData].g_tabbar.selectedIndex = 0;
            [[GlobalData sharedGlobalData].g_tabbar.m_sharedTagNVC goToImage:[[Image alloc] initWithDict:notification.notification_extra] NotificationType:TAGN_PUSH_LIKED_IMAGE];
        }
            break;
        default:
            break;
    }

    
}

- (void)onClickBtnAccept:(NotificationTableCell *)cell
{
    NSIndexPath *indexPath = [m_tblNotifications indexPathForCell:cell];
    
    Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
    
    [[WebService sharedInstance] acceptRequestWithUserId:[GlobalData sharedGlobalData].g_userMe.user_id
                                                Username:[GlobalData sharedGlobalData].g_userMe.user_name
                                                 ShareID:notification.notification_share_id
                                          NotificationID:notification.notification_id
                                               Completed:^{
                                                   [[GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications removeObjectAtIndex:indexPath.row];
                                                   [m_tblNotifications deleteRowsAtIndexPaths:@[indexPath]
                                                                             withRowAnimation:UITableViewRowAnimationFade];
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_END_UPLOAD
                                                                                                       object:nil];
                                               }
                                                  Failed:^(NSString *strError) {
                                                      NSLog(@"%@", strError);
                                                  }];
}

- (void)onClickBtnDecline:(NotificationTableCell *)cell
{
    NSIndexPath *indexPath = [m_tblNotifications indexPathForCell:cell];
    
    Notification *notification = [GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications[indexPath.row];
    
    [[WebService sharedInstance] declineRequestWithUserId:[GlobalData sharedGlobalData].g_userMe.user_id
                                                 Username:[GlobalData sharedGlobalData].g_userMe.user_name
                                                  ShareID:notification.notification_share_id
                                           NotificationID:notification.notification_id
                                                Completed:^{
                                                    [[GlobalData sharedGlobalData].g_appDelegate.m_aryNotifications removeObjectAtIndex:indexPath.row];
                                                    [m_tblNotifications deleteRowsAtIndexPaths:@[indexPath]
                                                                              withRowAnimation:UITableViewRowAnimationFade];
                                                    
                                                }
                                                   Failed:^(NSString *strError) {
                                                       NSLog(@"%@", strError);
                                                   }];
}

#pragma tag -- UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // This enables the user to scroll down the navbar by tapping the status bar.
    [self showHeaderView];
    
    return YES;
}

@end
