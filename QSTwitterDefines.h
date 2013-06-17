// Actions

#define kDirectMessageAction @"sendDirectMessage"
#define kDirectMessageToAction @"sendDirectMessageTo"
#define kSendMessageToAction @"sendMessageTo"
#define kSendMessageAction @"sendMessage"

// Local
#define kQSTwitterCallbackURL @"http://qs.qsapp.com/twitter"
#define kQSTwitterOAToken @"QSTwitterOAToken"
#define kQSTwitterKeychainItemName @"Twitter Auth Service"
#define kQSTwitterServiceName @"Twitter"


// Twitter API
#define kTwitterRequestTokenURL [NSURL URLWithString:@"https://twitter.com/oauth/request_token"]
#define kTwitterAccessTokenURL [NSURL URLWithString:@"https://twitter.com/oauth/access_token"]
#define kTwitterAuthorizeURL [NSURL URLWithString:@"https://twitter.com/oauth/authorize"]
#define kTwitterUpdateURL [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"]
#define kTwitterUserCredURL [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"]
#define kTwitterDMURL [NSURL URLWithString:@"https://api.twitter.com/1.1/direct_messages/new.json"]

// Twitter *may* change this one day, who knows
#define kMaxTweetLength 140
