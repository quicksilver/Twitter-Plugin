//
//  TwitterAction.m
//  Twitter
//
//  Created by Joshua Holt on 12/23/09.

#import "TwitterAction.h"
#import "TwitterUtil.h"
#import <QSCore/QSTextProxy.h>
#import <QSCore/QSNotifyMediator.h>


@implementation TwitterAction

- (QSObject *)performActionOnObject:(QSObject *)dObject{
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSTwitterUserName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSTwitterUserPassword"];

    NSDictionary *token_response = AccessTokenRequest(userName, password);
    NSString *oauth_token        = [token_response objectForKey:@"oauth_token"];
    NSString *oauth_token_secret = [token_response objectForKey:@"oauth_token_secret"];

    NSString *message = [dObject stringValue];
    NSDictionary *response = Tweet(message, oauth_token, oauth_token_secret);

    if ([response objectForKey:@"text"]) {
        TwitterNotify(message);
    } else {
        TwitterNotify([NSString stringWithFormat:@"ERROR: %@",[response objectForKey:@"error"]]);
    }
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return nil;
}

@end
