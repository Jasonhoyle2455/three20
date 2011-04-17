//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTExtensionInfoController.h"

// UI
#import "Three20UI/TTSectionedDataSource.h"
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/TTTableSubtitleItem.h"
#import "Three20UI/TTTableLongTextItem.h"
#import "Three20UI/TTTableTextItem.h"

// UINavigator
#import "Three20UINavigator/UIViewController+TTNavigator.h"

// Network
#import "Three20Network/TTGlobalNetwork.h"
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/NSStringAdditions.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTLicense.h"
#import "Three20Core/TTLicenseInfo.h"
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionLoader.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionInfoController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_extension);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithExtensionID:(NSString*)identifier {
  self = [super initWithNibName:nil bundle:nil];
  if (nil != self) {
    self.title = @"Extension Info";
    self.tableViewStyle = UITableViewStyleGrouped;

    _extension = [[[TTExtensionLoader availableExtensions] objectForKey:identifier] retain];

    self.variableHeightRows = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithExtensionID:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)urlPathForGravatar:(NSString*)email size:(NSInteger)size {
  return [NSString stringWithFormat:
          @"http://gravatar.com/avatar/%@?size=%d",
          [email md5Hash],
          size];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
  NSMutableArray* titles = [[[NSMutableArray alloc] init] autorelease];

  [titles addObject:@"Description"];
  [items addObject:[NSArray arrayWithObjects:
                    [TTTableLongTextItem itemWithText:_extension.description],
                    nil]];

  [titles addObject:@"General Information"];

  NSMutableArray* generalInfo = [NSMutableArray array];

  [generalInfo addObjectsFromArray:
   [NSArray arrayWithObjects:
    [TTTableCaptionItem itemWithText:_extension.name caption:@"Name:"],
    [TTTableCaptionItem itemWithText:_extension.version caption:@"Version:"],
    nil]];

  if (TTIsStringWithAnyText(_extension.website)) {
    [generalInfo addObject:
     [TTTableCaptionItem itemWithText:_extension.website caption:@"Website:"
                                  URL:_extension.website]];
  }

  for (NSInteger ix = 0; ix < [_extension.licenses count]; ++ix) {
    TTLicenseInfo* licenseInfo = [_extension.licenses objectAtIndex:ix];

    NSString* licenseURLPath = [[self navigatorURL] stringByAppendingFormat:
                                @"/license/%d",
                                ix];

    [generalInfo addObject:
     [TTTableCaptionItem itemWithText: [NSString stringWithFormat:@"%@ %@",
                                        licenseInfo.copyrightOwner,
                                        licenseInfo.copyrightTimespan]
                              caption: @"License:"
                                  URL: licenseURLPath]];
  }

  [items addObject:generalInfo];

  if ([_extension.authors count] > 0) {
    [titles addObject:@"Authors"];
    NSMutableArray* authorItems = [[[NSMutableArray alloc] initWithCapacity:
                                    [_extension.authors count]] autorelease];

    for (NSInteger ix = 0; ix < [_extension.authors count]; ++ix) {
      TTExtensionAuthor* author = [_extension.authors objectAtIndex:ix];
      TTDASSERT([author isKindOfClass:[TTExtensionAuthor class]]);

      NSString* authorURLPath = [[self navigatorURL] stringByAppendingFormat:
                                  @"/author/%d",
                                  ix];

      NSString* subtitle = nil;
      if (TTIsStringWithAnyText(author.twitter)) {
        subtitle = [NSString stringWithFormat:@"@%@", author.twitter];

      } else if (TTIsStringWithAnyText(author.github)) {
        subtitle = [NSString stringWithFormat:@"github: %@", author.github];

      } else if (TTIsStringWithAnyText(author.email)) {
        subtitle = [NSString stringWithFormat:@"email: %@", author.email];
      }

      [authorItems addObject:
       [TTTableSubtitleItem itemWithText: author.name
                                subtitle: subtitle
                                imageURL: [self urlPathForGravatar: author.email
                                                              size: 50]
                            defaultImage:
        TTIMAGE(@"bundle://Three20.bundle/images/defaultPerson.png")
                                     URL: authorURLPath
                            accessoryURL: nil]];
    }

    [items addObject:authorItems];
  }

  self.dataSource = [TTSectionedDataSource dataSourceWithItems:items sections:titles];
}


@end

