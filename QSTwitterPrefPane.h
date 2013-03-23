//
//  QSTwitterPrefPane.h
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import <Cocoa/Cocoa.h>
#import <OAuthConsumer/OAuthConsumer.h>

@interface QSTwitterPrefPane : QSPreferencePane {
    IBOutlet NSTextField *usr;
    IBOutlet NSProgressIndicator *ind;
    IBOutlet NSButton *signInOutButton;
}

-(IBAction)authenticate:(id)sender;

@end
