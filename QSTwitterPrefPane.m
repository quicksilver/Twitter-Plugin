//
//  QSTwitterPrefPane.m
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import "QSTwitterPrefPane.h"
#import "ConsumerKey.h"
#import "QSTwitterDefines.h"
#import "QSTwitterUtil.h"
#import "GTMOAuthAuthentication.h"

@implementation QSTwitterPrefPane

-(IBAction)authenticate:(id)sender {
    [ind setHidden:NO];
    [[QSTwitterUtil sharedInstance] signInToCustomService];
    [self updateUI];
}

-(void)updateUI {
    QSTwitterUtil *ut = [QSTwitterUtil sharedInstance];
    [ind setHidden:YES];
    GTMOAuthAuthentication *authentication = [ut authentication];
    if ([ut isSignedIn]) {
        NSString *email = [authentication userEmail];
        BOOL isVerified = [[authentication userEmailIsVerified] boolValue];
        if (!isVerified) {
            // email address is not verified
            //
            // The email address is listed with the account info on the server, but
            // has not been confirmed as belonging to the owner of this account.
            email = [email stringByAppendingString:@" (unverified)"];
        }
        
        [usr setStringValue:(email != nil ? email : @"")];
        [signInOutButton setTitle:@"Sign Out"];
    } else {
        // signed out
        [usr setStringValue:@"-Not signed in-"];
        [signInOutButton setTitle:@"Sign In"];
    }
}
@end
