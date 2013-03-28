//
//  TwitterAction.m
//  Twitter
//
//  Created by Joshua Holt on 12/23/09.
//  Updated by Masato Igarashi on 07/05/11

#import "QSTwitterAction.h"
#import "QSTwitterUtil.h"
#import "QSTwitterDefines.h"
#import <AddressBook/ABGlobals.h>

@implementation QSTwitterAction

-(NSArray*)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject {
    if ([self twitterUsernameForContact:dObject] != nil) {
        return @[kDirectMessageAction, kSendMessageAction];
    }
    return nil;
}

-(NSString *)twitterUsernameForContact:(QSObject *)person {
    NSArray *people = nil;
    ABPerson *pers = [person ABPerson];
    if ([NSApplication isMountainLion]) {
        people = [pers linkedPeople];
    } else {
        people = @[pers];
    }
    for (ABPerson *p in people) {
        ABMultiValue *ims = [p valueForProperty:kABSocialProfileProperty];
        for (NSUInteger i = 0; i < [ims count]; i++) {
            NSDictionary *serv = [ims valueAtIndex:i];
            if ([[serv objectForKey:kABSocialProfileServiceKey] isEqualToString:kABSocialProfileServiceTwitter]) {
                return [serv objectForKey:kABSocialProfileUsernameKey];
            }
        }
    }
    return nil;
}

-(NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
    if ([action isEqualToString:kDirectMessageToAction] || [action isEqualToString:kSendMessageToAction]) {
        NSArray *contacts = [QSLib scoredArrayForType:QSABPersonType];
        NSIndexSet *ind = [contacts indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(QSObject *obj, NSUInteger idx, BOOL *stop) {
            return [self twitterUsernameForContact:obj] != nil;
        }];
        return [contacts objectsAtIndexes:ind];
    }
    if ([action isEqualToString:kDirectMessageAction] || [action isEqualToString:kSendMessageAction]) {
        return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:@"Direct Message…"]];
    }
    return nil;
}

-(void)showTooLongthNotifWithLength:(NSUInteger)length {
    [[QSTwitterUtil sharedInstance] twitterNotify:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Message too long (%lu chars)", nil, [NSBundle bundleForClass:[self class]], @"too long message for tweetts"), length]];
}

- (QSObject *)sendTweet:(QSObject *)dObject {
    NSString *message = [dObject stringValue];
    QSTwitterUtil *tu = [QSTwitterUtil sharedInstance];
    if (![tu isSignedIn]) {
        [tu twitterNotify:NSLocalizedStringFromTableInBundle(@"Not signed in to Twitter", nil, [NSBundle bundleForClass:[self class]], @"not signed in message")];
        return [QSObject textProxyObjectWithDefaultValue:message];
    }
    if ([message length] > kMaxTweetLength) {
        [self showTooLongthNotifWithLength:[message length]];
        return [QSObject textProxyObjectWithDefaultValue:message];
    }
    [tu tweet:message];
    return nil;
}

-(QSObject*)sendDirectMessage:(QSObject *)dObject toContact:(QSObject *)iObject {
    NSString *username = [self twitterUsernameForContact:iObject];
    
    return nil;
}

-(QSObject*)sendMessage:(QSObject *)dObject toContact:(QSObject *)iObject {
    NSString *username = [self twitterUsernameForContact:iObject];
    NSString *message = [NSString stringWithFormat:@"@%@ %@",username,[dObject stringValue]];
    if ([message length] > kMaxTweetLength) {
        [self showTooLongthNotifWithLength:[message length]];
        return [QSObject textProxyObjectWithDefaultValue:[dObject stringValue]];
    }
    
    return nil;
}

@end
