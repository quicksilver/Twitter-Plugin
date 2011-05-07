//
//  TwitterAction.m
//  Twitter
//
//  Created by Joshua Holt on 12/23/09.
//  Updated by Masato Igarashi on 07/05/11

#import "TwitterAction.h"
#import "TwitterUtil.h"
#import <QSCore/QSTextProxy.h>
#import <QSCore/QSNotifyMediator.h>


@implementation TwitterAction

- (QSObject *)performActionOnObject:(QSObject *)dObject{

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSString *userName = [defaults valueForKey:@"QSTwitterUserName"];
    NSString *password = [defaults valueForKey:@"QSTwitterUserPassword"];

    if (userName == nil || [userName isEqualToString:@""]) {
        [defaults removeObjectForKey:@"QSTwitterTokenDict"];
        [defaults removeObjectForKey:@"QSTwitterUserPassword"];
        TwitterNotify(@"Please Set up your account in the preference pane.");
    } else {
        NSDictionary *dict = [defaults dictionaryForKey:@"QSTwitterTokenDict"];
        NSString *oauth_token        = [dict valueForKey:@"oauth_token"];
        NSString *oauth_token_secret = [dict valueForKey:@"oauth_token_secret"];

        if (![userName isEqualToString:[dict valueForKey:@"screen_name"]] ||
                !(password == nil || [password isEqualToString:@""])) {

            dict = AccessTokenRequest(userName, password);
            oauth_token        = [dict valueForKey:@"oauth_token"];
            oauth_token_secret = [dict valueForKey:@"oauth_token_secret"];

            if (oauth_token == nil || [oauth_token isEqualToString:@""]) {
                TwitterNotify(@"[ERROR] Access Token request failed");
                return nil;
            } else {
                [defaults setObject:dict forKey:@"QSTwitterTokenDict"];
                [defaults removeObjectForKey:@"QSTwitterUserPassword"];
                TwitterNotify(@"[INFO] Access Token updated");
            }
        }

        NSString *message = [dObject stringValue];
        NSDictionary *response = Tweet(message, oauth_token, oauth_token_secret);

        if ([response valueForKey:@"text"]) {
            TwitterNotify(message);
        } else {
            TwitterNotify([NSString stringWithFormat:@"[ERROR] %@",[response valueForKey:@"error"]]);
        }
    }
    return nil;
}

@end
