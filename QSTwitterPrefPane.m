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

-(NSView *)loadMainView {
    NSView *view = [super loadMainView];
    [[QSTwitterUtil sharedInstance] setPrefPane:self];
    [ind setHidden:NO];
    [ind startAnimation:self];
    [self updateUI];
    return view;
}

-(IBAction)authenticate:(id)sender {
    QSTwitterUtil *tu = [QSTwitterUtil sharedInstance];
    if ([tu isSignedIn]) {
        [tu signOut];
        [self updateUI];
    } else {
        [ind setHidden:NO];
        [ind startAnimation:sender];
        [tu signInToCustomService];
    }
}

-(void)updateCredentials:(NSDictionary *)credentials {
    NSString *name = nil;
    if (credentials) {
        name = [NSString stringWithFormat:@"%@ (%@)",[credentials objectForKey:@"name"],[credentials objectForKey:@"screen_name"]];
    }
    
    [usr setStringValue:(name != nil ? name : @"")];
    [signInOutButton setTitle:@"Sign Out"];
    [ind setHidden:YES];
}
-(void)updateUI {
    QSTwitterUtil *tu = [QSTwitterUtil sharedInstance];
    if ([tu isSignedIn]) {
        [usr setStringValue:@"Loading..."];
        [tu getCredentials];
    } else {
        // signed out
        [usr setStringValue:@"-Not signed in-"];
        [signInOutButton setTitle:@"Sign In"];
        [ind setHidden:YES];
    }
}

@end
