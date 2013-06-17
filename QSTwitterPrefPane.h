//
//  QSTwitterPrefPane.h
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface QSTwitterPrefPane : QSPreferencePane {
    IBOutlet NSTextField *usr;
    IBOutlet NSProgressIndicator *ind;
    IBOutlet NSButton *signInOutButton;
}

-(IBAction)authenticate:(id)sender;
-(void)updateUI;
-(void)updateCredentials:(NSDictionary *)credentials;

@end
