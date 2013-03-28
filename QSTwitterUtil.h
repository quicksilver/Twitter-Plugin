//
//  QSTwitterUtil.h
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import <Foundation/Foundation.h>

@class GTMOAuthAuthentication;
@class QSTwitterPrefPane;

@interface QSTwitterUtil : NSObject {
    GTMOAuthAuthentication *authentication;
    QSTwitterPrefPane *prefPane;
}

@property (retain) QSTwitterPrefPane *prefPane;
@property (retain) GTMOAuthAuthentication *authentication;

+ (id)sharedInstance;
- (void)twitterNotify:(NSString *)message;
- (void)signInToCustomService;
- (BOOL)isSignedIn;
- (void)getCredentials;
- (void)signOut;
- (QSObject *)tweet:(NSString*)message toUser:(NSString*)user;

@end
