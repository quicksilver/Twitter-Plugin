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

-(BOOL)messageIsTooLong:(NSString *)message {
    if ([message length] > kMaxTweetLength) {
    [[QSTwitterUtil sharedInstance] twitterNotify:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Message too long (%lu chars)", nil, [NSBundle bundleForClass:[self class]], @"too long message for tweetts"), [message length]]];
        return YES;
    }
    return NO;
}

- (QSObject *)sendTweet:(QSObject *)dObject {
    NSString *message = [dObject stringValue];
    QSTwitterUtil *tu = [QSTwitterUtil sharedInstance];
    if ([self messageIsTooLong:message]) {
        return [QSObject textProxyObjectWithDefaultValue:message];
    }
    return [tu tweet:message toUser:nil];
}

-(QSObject *)sendDirectMessage:(QSObject *)dObject toContact:(QSObject *)iObject {
    NSString *username = [self twitterUsernameForContact:iObject];
    NSString *message = [dObject stringValue];
    
    if ([self messageIsTooLong:message]) {
        return [QSObject textProxyObjectWithDefaultValue:[dObject stringValue]];
    }
    return [[QSTwitterUtil sharedInstance] tweet:message toUser:username];
}

-(QSObject*)sendMessage:(QSObject *)dObject toContact:(QSObject *)iObject {
    NSString *username = [self twitterUsernameForContact:iObject];
    NSString *message = [NSString stringWithFormat:@"@%@ %@",username,[dObject stringValue]];
    if ([self messageIsTooLong:message]) {
        return [QSObject textProxyObjectWithDefaultValue:[dObject stringValue]];
    }
    return [[QSTwitterUtil sharedInstance] tweet:message toUser:nil];
}

@end
