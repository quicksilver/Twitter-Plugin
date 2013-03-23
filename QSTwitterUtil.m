//
//  QSTwitterUtil.m
//  QSTwitter
//
//  Created by Patrick Robertson on 23/03/2013.
//
//

#import "QSTwitterUtil.h"
#import "ConsumerKey.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthWindowController.h"
#import "QSTwitterDefines.h"

@implementation QSTwitterUtil

@synthesize authentication;

+ (QSTwitterUtil *) sharedInstance {
    static QSTwitterUtil *tu = nil;
    if (tu == nil) {
        tu = [[QSTwitterUtil alloc] init];
    }
    return tu;
}

-(void)twitterNotify:(NSString *)message {
    QSShowNotifierWithAttributes(
                                 [NSDictionary dictionaryWithObjectsAndKeys:@"QSTwit",
                                  QSNotifierTitle, message, QSNotifierText,
                                  [QSResourceManager imageNamed:@"QSTwit"],QSNotifierIcon,nil]);
}

- (GTMOAuthAuthentication *)auth {
    
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:CONSUMER_KEY
                                                         privateKey:CONSUMER_KEY_SECRET] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"Twitter Auth Service";
    
    return auth;
}

- (void)signInToCustomService {
    NSString *scope = @"http://api.twitter.com/";    
    GTMOAuthAuthentication *auth = [self auth];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:kQSTwitterCallbackURL];
    
    // Display the autentication view
    GTMOAuthWindowController *windowController;
    windowController = [[[GTMOAuthWindowController alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:kTwitterRequestTokenURL
                                                       authorizeTokenURL:kTwitterAuthorizeURL
                                                          accessTokenURL:kTwitterAccessTokenURL
                                                          authentication:auth
                                                          appServiceName:@"Quicksilver Twitter Service"
                                                          resourceBundle:[NSBundle bundleForClass:[self class]]] autorelease];
    [windowController signInSheetModalForWindow:nil
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)windowController:(GTMOAuthWindowController *)windowController
        finishedWithAuth:(GTMOAuthAuthentication *)auth
                   error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        
        [self setAuthentication:nil];
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //   [auth authorizeRequest:myNSURLMutableRequest]
        //
        // or store the authentication object into a GTMHTTPFetcher object like
        //
        //   [fetcher setAuthorizer:auth];
        
        // save the authentication object
        [self setAuthentication:auth];
    }
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = [authentication canAuthorize];
    return isSignedIn;
}

@end