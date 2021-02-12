#import "Tweak.h"
#import "UIImage+UIImageAverageColorAddition.h"

// Lightmann
// Made during covid 
// SortingSwipe

%hook SBIconController
// add sort gesture to HS
-(void)viewDidLoad{
	%orig;

	UISwipeGestureRecognizer *sortGesture = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(popAlert)];
    sortGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:sortGesture];
}

%new
// respond to gesture w config alert 
-(void)popAlert{
	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"SortingSwipe"
                                 message:@"Choose a configuration:"
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *alphabetically = [UIAlertAction							
                                actionWithTitle:@"Sort Alphabetically"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
										if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration14:0];
										}
										else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration13:0];
										}
										else{
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration12:0];
										}
									});
                                }];

    UIAlertAction *hue = [UIAlertAction
                               actionWithTitle:@"Sort by Hue"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
										if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration14:1]; 
										}
										else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration13:1]; 
										}
										else{
											[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration12:1]; 
										}
									});
                               }];

    UIAlertAction *save = [UIAlertAction
                               actionWithTitle:@"Save Current Layout"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) saveLayout]; 
									});
                               }];

    UIAlertAction *load = [UIAlertAction
                               actionWithTitle:@"Load Saved Layout"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) loadLayout]; 
									});
                               }];

    UIAlertAction *cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									[self dismissViewControllerAnimated:YES completion:nil];
	                           }];

    [alert addAction:alphabetically];
    [alert addAction:hue];
	[alert addAction:save];
	[alert addAction:load];
    [alert addAction:cancel];

 	[self presentViewController:alert animated:YES completion:nil];
}

%new
//there's probably a better way of doing this, but this is what I landed on 
-(void)saveLayout{
	// NSURL *currentState = [[%c(SBDefaultIconModelStore) sharedInstance] currentIconStateURL];
	NSString *currentStatePath = @"/var/mobile/Library/SpringBoard/IconState.plist";
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *savePath = [documentsDirectory stringByAppendingPathComponent:@"SortingSwipeSaved.plist"];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// if the save file doesn't exist, make it
	if (![fileManager fileExistsAtPath:savePath]) {
		savePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SortingSwipeSaved.plist"]];
	} 

	NSMutableDictionary *data;
	if ([fileManager fileExistsAtPath:currentStatePath]) {
		// if the current state file exists, write data from it to data dict
		data = [[NSMutableDictionary alloc] initWithContentsOfFile:currentStatePath];
	}
	else {
		// if the file doesn’t exist, leave data dict blank
		data = [[NSMutableDictionary alloc] init];
	}

	// save layout to plist
	[data writeToFile:savePath atomically:YES];
}

%new
//just like above, there's probably a better way of doing this, but this is what I landed on 
-(void)loadLayout{
	// NSURL *currentState = [[%c(SBDefaultIconModelStore) sharedInstance] currentIconStateURL];
	NSString *currentStatePath = @"/var/mobile/Library/SpringBoard/IconState.plist";
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *loadPath = [documentsDirectory stringByAppendingPathComponent:@"SortingSwipeSaved.plist"];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// if the load file doesn't exist, stop
	if (![fileManager fileExistsAtPath:loadPath]) {
		return;
	} 
	
	NSMutableDictionary *data;
	// if the load file and target file both exist, grab saved layout
	if ([fileManager fileExistsAtPath:currentStatePath]) {
		data = [[NSMutableDictionary alloc] initWithContentsOfFile:loadPath];
	}

	// replace current layout with saved layout 
	[data writeToFile:currentStatePath atomically:YES];

	// refresh list views
	[self.model layout];
}

%new
// where the iOS 12 magic happens ...
-(void)sortAppsWithConfiguration12:(int)configuration{		
	NSMutableArray *sortedAppIcons = [NSMutableArray new];
	switch(configuration){
		// sort alphabetically
		case 0: {
			// grab app names and SBIcons
			NSMutableArray* appNames = [NSMutableArray new];
			NSMutableArray* appIcons = [NSMutableArray new];
			for(SBIcon *temp in [self.model leafIcons]){
				// we don't want to grab this hidden app
				if(![[temp applicationBundleID] isEqualToString:@"com.apple.appleseed.FeedbackAssistant"]){ 
					[appNames addObject:temp.displayName];
					[appIcons addObject:temp];
				}
			}

			// add app names and SBIcons as key-value pairs 
			NSMutableDictionary *hsApps = [NSMutableDictionary new];
			for (int i = 0; i < appIcons.count; i++) {
				[hsApps setObject:appIcons[i] forKey:appNames[i]];
			}

			// sort app names alphabetically
			NSArray *sortedAppNames = [appNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

			// add now sorted SBIcons into finalized array
			for(NSString *key in sortedAppNames){
				[sortedAppIcons addObject:[hsApps objectForKey:key]];
			}   
			break; 
		}
		// sort by hue
		case 1: { 
			// grab app icons, app names, and app icon images 
			NSMutableArray *visibleAppNames = [NSMutableArray new];
			NSMutableArray *visibleAppIcons = [NSMutableArray new];
			NSMutableArray *visibleAppIconImages = [NSMutableArray new];
			// No readily available image cache like 13/14, so have to grab em manually
			for(SBIcon *icon in [self.model leafIcons]){ 						 
				// we don't want this hidden app to show
				if(![[icon applicationBundleID] isEqualToString:@"com.apple.appleseed.FeedbackAssistant"]){
					[visibleAppNames addObject:icon.displayName];
					[visibleAppIcons addObject:icon];
					[visibleAppIconImages addObject:[icon getIconImage:2]];
				}
			}

			// add names & icons and names & images as key-value pairs in two dicts
			NSMutableDictionary *hsIcons = [NSMutableDictionary new];
			NSMutableDictionary *hsImages = [NSMutableDictionary new]; 
			for (int i = 0; i < visibleAppNames.count; i++) {
				[hsIcons setObject:visibleAppIcons[i] forKey:visibleAppNames[i]];
				[hsImages setObject:visibleAppIconImages[i] forKey:visibleAppNames[i]];
			}

			// sort hsimages and put into sortedIcons array -- (https://stackoverflow.com/a/8585285)
			NSArray *sortedIcons = [[hsImages allValues] sortedArrayUsingComparator:^NSComparisonResult(UIImage* obj1, UIImage* obj2) {
				UIColor *color1 = [obj1 mergedColor]; //avg color
				UIColor *color2 = [obj2 mergedColor]; //avg color
				CGFloat hue, saturation, brightness, alpha;
				[color1 getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
				CGFloat hue2, saturation2, brightness2, alpha2;
				[color2 getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
				if (hue < hue2)
					return NSOrderedAscending;
				else if (hue > hue2)
					return NSOrderedDescending;

				if (saturation < saturation2)
					return NSOrderedAscending;
				else if (saturation > saturation2)
					return NSOrderedDescending;

				if (brightness < brightness2)
					return NSOrderedAscending;
				else if (brightness > brightness2)
					return NSOrderedDescending;

				return NSOrderedSame;
			}];

			// grab key (name) for sorted icon images, then grab SBIcon with that key, and place orderly into sortedappicons array 
			for(UIImage *object in sortedIcons){ 
				NSArray *temp = [hsImages allKeysForObject:object];
				NSString *key = [temp objectAtIndex:0];
				[sortedAppIcons addObject:[hsIcons objectForKey:key]]; 
			} 
			break;
		} 
	}

	// modified from Broha22's AppSort (https://github.com/broha22/appsort/blob/master/Tweak.x)	
	// remove and then add back now-sorted icons 
	int index = 0;
	NSMutableArray *addedIcons = [NSMutableArray array];
	for(SBIconListView *listview in [self _currentFolderController].iconListViews) {
		for(SBIcon *icon in [listview icons]) {
			[listview removeIcon:icon]; 
		}
	    for(SBIcon *icon in sortedAppIcons){
			if([listview isFull]) break;
			[listview insertIcon:icon atIndex:index options:0];
			[addedIcons addObject:icon];
			index++;
		}
		index = 0;
		[sortedAppIcons removeObjectsInArray:addedIcons];
		[listview layoutIconsNow];
  	}

	//clear dock
	SBIconListView *dockListView = [self _currentFolderController].dockIconListView;
	for(SBIcon *icon in [dockListView icons]) {
		[dockListView removeIcon:icon]; 
	}
	[dockListView layoutIconsNow];
}

%new
//where the iOS 13 magic happens ...
-(void)sortAppsWithConfiguration13:(int)configuration{		
	NSMutableArray *sortedAppIcons = [NSMutableArray new];
	switch(configuration){
		// sort alphabetically
		case 0: {
			// grab app names and SBIcons
			NSMutableArray* appNames = [NSMutableArray new];
			NSMutableArray* appIcons = [NSMutableArray new];
			for(SBIcon *temp in self.model.leafIcons){
				//we don't want to grab these hidden apps
				if(![[temp applicationBundleID] isEqualToString:@"com.apple.appleseed.FeedbackAssistant"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.dt.XcodePreviews"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.sidecar"]){
					[appNames addObject:temp.displayName];
					[appIcons addObject:temp];
				}
			}

			// add app names and SBIcons as key-value pairs in a dict
			NSMutableDictionary *hsApps = [NSMutableDictionary new];
			for (int i = 0; i < appIcons.count; i++) {
				[hsApps setObject:appIcons[i] forKey:appNames[i]];
			}

			// sort app names alphabetically
			NSArray *sortedAppNames = [appNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

			// grab SBIcon for sorted names and place orderly into finalized array
			for(NSString *key in sortedAppNames){
				[sortedAppIcons addObject:[hsApps objectForKey:key]];
			}  
			break;
		}
		// sort by hue
		case 1: { 
			// grab SBIcons 
			NSMutableArray *visibleAppIcons = [NSMutableArray new];
			for(SBIcon *temp in self.model.leafIcons){
				//we don't want to grab these hidden apps
				if(![[temp applicationBundleID] isEqualToString:@"com.apple.appleseed.FeedbackAssistant"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.dt.XcodePreviews"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.sidecar"]){
					[visibleAppIcons addObject:temp];
				}
			}

			// get UIImages for the application icons
			SBHIconImageCache *iconCache = self.appSwitcherUnmaskedIconImageCache;
			[iconCache cacheImagesForIcons:visibleAppIcons];
		
			// easier access to the icon images
			NSMutableDictionary *hsIcons = MSHookIvar<NSMutableDictionary *>(iconCache, "_images");
			
			// sort hsicon images and put into sortedIcons array -- (https://stackoverflow.com/a/8585285)
			NSArray *sortedIcons = [[hsIcons allValues] sortedArrayUsingComparator:^NSComparisonResult(UIImage* obj1, UIImage* obj2) {
				UIColor *color1 = [obj1 mergedColor]; //avg color
				UIColor *color2 = [obj2 mergedColor]; //avg color
				CGFloat hue, saturation, brightness, alpha;
				[color1 getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
				CGFloat hue2, saturation2, brightness2, alpha2;
				[color2 getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
				if (hue < hue2)
					return NSOrderedAscending;
				else if (hue > hue2)
					return NSOrderedDescending;

				if (saturation < saturation2)
					return NSOrderedAscending;
				else if (saturation > saturation2)
					return NSOrderedDescending;

				if (brightness < brightness2)
					return NSOrderedAscending;
				else if (brightness > brightness2)
					return NSOrderedDescending;

				return NSOrderedSame;
			}];

			// grab key (bundleId) for sorted images, grab SBIcon for said bundleID, then place orderly into finalized array 
			for(UIImage *object in sortedIcons){
				NSArray *temp = [hsIcons allKeysForObject:object];
				NSString *key = [temp objectAtIndex:0];
				[sortedAppIcons addObject:[self.model expectedIconForDisplayIdentifier:key]];
			}
			break;
		}
	}

	// remove icons 	
	[self.model removeAllIcons];
	[self.model layout]; 

	// re-add icons in now-sorted order
	[self.rootFolder addIcons:sortedAppIcons];
}

%new
//where the iOS 14 magic happens ...
-(void)sortAppsWithConfiguration14:(int)configuration{		
	NSMutableArray *sortedAppIcons = [NSMutableArray new];
	switch(configuration){
		// sort alphabetically
		case 0: {
			// grab app names and SBIcons
			NSMutableArray* appNames = [NSMutableArray new];
			NSMutableArray* appIcons = [NSMutableArray new];
			for(SBIcon *temp in self.model.leafIcons){
				//we don't want to grab widgets or these hidden apps 
				if(![temp isMemberOfClass:%c(SBWidgetIcon)] && ![[temp applicationBundleID] isEqualToString:@"com.apple.Magnifier"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.appleseed.FeedbackAssistant"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.dt.XcodePreviews"] && ![[temp applicationBundleID] isEqualToString:@"com.apple.sidecar"]){
					[appNames addObject:temp.displayName];
					[appIcons addObject:temp];
				}
			}

			// add app names and SBIcons as key-value pairs in a dict
			NSMutableDictionary *hsApps = [NSMutableDictionary new];
			for (int i = 0; i < appIcons.count; i++) {
				[hsApps setObject:appIcons[i] forKey:appNames[i]];
			}

			// sort app names alphabetically
			NSArray *sortedAppNames = [appNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

			// grab SBIcon for sorted names and place orderly into finalized array
			for(NSString *key in sortedAppNames){
				[sortedAppIcons addObject:[hsApps objectForKey:key]];
			}  
			break;
		}
		// sort by hue
		case 1: { 
			// grab SBIcons 
			NSMutableArray *visibleAppIcons = [NSMutableArray new];
			for(SBIcon *temp in self.model.leafIcons){
				//we don't want to grab widgets
				if(![temp isMemberOfClass:%c(SBWidgetIcon)]){ 
					[visibleAppIcons addObject:temp];
				}
			}

			// get UIImages for the application icons
			SBHIconImageCache *iconCache = self.appSwitcherUnmaskedIconImageCache;
			[iconCache cacheImagesForIcons:visibleAppIcons];
		
			// easier access to icon images
			NSMutableDictionary *hsIcons = MSHookIvar<NSMutableDictionary *>(iconCache, "_images");
			
			// sort hsicon images and put into sortedIcons array -- (https://stackoverflow.com/a/8585285)
			NSArray *sortedIcons = [[hsIcons allValues] sortedArrayUsingComparator:^NSComparisonResult(UIImage* obj1, UIImage* obj2) {
				UIColor *color1 = [obj1 mergedColor]; //avg color
				UIColor *color2 = [obj2 mergedColor]; //avg color
				CGFloat hue, saturation, brightness, alpha;
				[color1 getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
				CGFloat hue2, saturation2, brightness2, alpha2;
				[color2 getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
				if (hue < hue2)
					return NSOrderedAscending;
				else if (hue > hue2)
					return NSOrderedDescending;

				if (saturation < saturation2)
					return NSOrderedAscending;
				else if (saturation > saturation2)
					return NSOrderedDescending;

				if (brightness < brightness2)
					return NSOrderedAscending;
				else if (brightness > brightness2)
					return NSOrderedDescending;

				return NSOrderedSame;
			}];

			// grab key (bundleId) for sorted images, grab SBIcon for said bundleID, then place orderly into finalized array 
			for(UIImage *object in sortedIcons){
				NSArray *temp = [hsIcons allKeysForObject:object];
				NSString *key = [temp objectAtIndex:0];
				// we don't want to grab these hidden apps 
				// would put this check in the leafIcons for loop, like I do elsewhere, but they're present again in the image cache, for some reason, so this saves us doing it twice
				if(![key isEqualToString:@"com.apple.Magnifier"] && ![key isEqualToString:@"com.apple.appleseed.FeedbackAssistant"] && ![key isEqualToString:@"com.apple.dt.XcodePreviews"] && ![key isEqualToString:@"com.apple.sidecar"]){
					[sortedAppIcons addObject:[self.model expectedIconForDisplayIdentifier:key]];
				}
			}
			break;
		}
	}

	// remove icons 	
	[self.model removeAllIcons];
	[self.model layout]; 

	// re-add icons in now-sorted order
	[self.rootFolder addIcons:sortedAppIcons];
}
%end
