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

    NSString *userName = [defaults valueForKey:@"QSTwitUserName"];
    NSString *password = [defaults valueForKey:@"QSTwitUserPassword"];

    if (userName == nil || [userName isEqualToString:@""]) {
        [defaults removeObjectForKey:@"QSTwitTokenDict"];
        [defaults removeObjectForKey:@"QSTwitUserPassword"];
        TwitterNotify(@"Please Set up your account in the preference pane.");
    } else {
        NSDictionary *dict = [defaults dictionaryForKey:@"QSTwitTokenDict"];
        NSString *token  = [dict valueForKey:@"oauth_token"];
        NSString *secret = [dict valueForKey:@"oauth_token_secret"];

        if (![userName isEqualToString:[dict valueForKey:@"screen_name"]] ||
                !(password == nil || [password isEqualToString:@""])) {

            dict = AccessTokenRequest(userName, password);
            token  = [dict valueForKey:@"oauth_token"];
            secret = [dict valueForKey:@"oauth_token_secret"];

            if (token == nil || [token isEqualToString:@""]) {
                TwitterNotify(@"[ERROR] Access Token request failed");
                return nil;
            } else {
                [defaults setObject:dict forKey:@"QSTwitTokenDict"];
                [defaults removeObjectForKey:@"QSTwitUserPassword"];
                TwitterNotify(@"[INFO] Access Token updated");
            }
        }

        NSString *message = [dObject stringValue];
        NSDictionary *response = Tweet(message, token, secret);

        if ([response valueForKey:@"text"]) {
            TwitterNotify(message);
        } else {
            TwitterNotify([NSString stringWithFormat:@"[ERROR] %@",[response valueForKey:@"error"]]);
        }
    }
    return nil;
}

@end
