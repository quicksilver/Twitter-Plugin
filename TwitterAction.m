//
//  TwitterAction.m
//  Twitter
//
//  Created by Joshua Holt on 12/23/09.
//  Updated by Masato Igarashi on 07/05/11

#import "TwitterAction.h"
#import "QSTwitterUtil.h"

@implementation TwitterAction

- (QSObject *)performActionOnObject:(QSObject *)dObject{
    QSTwitterUtil *tu = [QSTwitterUtil sharedInstance];
    if (![tu isSignedIn]) {
        [tu twitterNotify:NSLocalizedStringFromTableInBundle(@"Not signed in to Twitter", nil, [NSBundle bundleForClass:[self class]], @"not signed in message")];
        return nil;
    }
    NSString *message = [dObject stringValue];
    if ([message length] > 140) {
        [tu twitterNotify:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Message too long (%lu chars)", nil, [NSBundle bundleForClass:[self class]], @"too long message for tweetts"), [message length]]];
    }
    [tu tweet:message];
    return nil;
}

@end
