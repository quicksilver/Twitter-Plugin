//
//  TwitterAction.m
//  Twitter
//
//  Created by Joshua Holt on 12/23/09.

#import "TwitterAction.h"
#import "JSON.h"
#import <QSCore/QSTextProxy.h>
#import <QSCore/QSNotifyMediator.h>

#import "OAuthCore.h"
#import "OAuth+Additions.h"
#import "ConsumerKey.h"

void TwitterNotify(NSString *message)
{
  QSShowNotifierWithAttributes(
        [NSDictionary dictionaryWithObjectsAndKeys:@"QSTwitter",
         QSNotifierTitle, message, QSNotifierText,
         [QSResourceManager imageNamed:@"QSTwitter2"],QSNotifierIcon,nil]);
}

@implementation TwitterAction

- (QSObject *)performActionOnObject:(QSObject *)dObject{
    
    //NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSTwitterUserName"];
    //NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSTwitterUserPassword"];
    
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/statuses/update.json"];
    NSString *message = [dObject stringValue];
    NSString *method = @"POST";
    NSData *body = [[NSString stringWithFormat:@"status=%@", message] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *header = OAuthorizationHeader(url, method, body, CONSUMER_KEY, CONSUMER_KEY_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:body];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //NSURLResponse *response = nil;
    //NSError       *error    = nil;
    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //TwitterNotify([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"data: %@", dataString);
    NSDictionary *dic = [dataString JSONValue];
    NSString *message = [dic objectForKey:@"text"];
    if (message) {
        TwitterNotify(message);
    } else {
        TwitterNotify([NSString stringWithFormat:@"ERROR: %@",[dic objectForKey:@"error"]]);
    }
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    TwitterNotify([error description]);
}

@end
