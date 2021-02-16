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
									if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:0 forVersion:14];
									}
									else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:0 forVersion:13];
									}
									else{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:0 forVersion:12];
									}
                                }];

    UIAlertAction *badges = [UIAlertAction
                               actionWithTitle:@"Sort by Badge Value"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:1 forVersion:14];
									}
									else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:1 forVersion:13];
									}
									else{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:1 forVersion:12];
									}
                               }];

    UIAlertAction *hue = [UIAlertAction
                               actionWithTitle:@"Sort by Hue"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:2 forVersion:14];
									}
									else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:2 forVersion:13];
									}
									else{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:2 forVersion:12];
									}
                               }];

    UIAlertAction *random = [UIAlertAction
                               actionWithTitle:@"Sort Randomly"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:3 forVersion:14];
									}
									else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:3 forVersion:13];
									}
									else{
										[((SBIconController *)[%c(SBIconController) sharedInstance]) sortAppsWithConfiguration:3 forVersion:12];
									}
                               }];

    UIAlertAction *save = [UIAlertAction
                               actionWithTitle:@"Save Current Layout"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									[((SBIconController *)[%c(SBIconController) sharedInstance]) saveLayout]; 
                               }];

    UIAlertAction *load = [UIAlertAction
                               actionWithTitle:@"Load Saved Layout"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									[((SBIconController *)[%c(SBIconController) sharedInstance]) loadLayout]; 
                               }];

    UIAlertAction *cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									[self dismissViewControllerAnimated:YES completion:nil];
	                           }];

    [alert addAction:alphabetically];
	[alert addAction:badges];
    [alert addAction:hue];
	[alert addAction:random];
	[alert addAction:save];
	[alert addAction:load];
    [alert addAction:cancel];

 	[self presentViewController:alert animated:YES completion:nil];
}

%new
-(void)saveLayout{
	// grab current layout (dict) and put into NSUserDefaults for safe keeping
	[[NSUserDefaults standardUserDefaults] setObject:[self.model iconState] forKey:@"SortingSwipeSave"];

	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"SortingSwipe"
                                 message:@"Current Layout Saved!"
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
									[self dismissViewControllerAnimated:YES completion:nil];
	                           }];

    [alert addAction:ok];

 	[self presentViewController:alert animated:YES completion:nil];
}

%new
-(void)loadLayout{
	// retrieve saved layout from NSUserDefaults
	NSDictionary *savedState = [[NSUserDefaults standardUserDefaults] objectForKey:@"SortingSwipeSave"];

	// set saved layout as desired layout
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13")){
		[self.model setDesiredIconState:savedState];
	}
	else{
		[self.model importDesiredIconState:savedState];
	}

	// refresh icon model
	[UIView animateWithDuration:0.5 animations:^{
		[self.model layout];
	}];
}

%new 
// where all the magic happens . . .
-(void)sortAppsWithConfiguration:(int)configuration forVersion:(int)version{
	NSMutableArray *sortedAppIcons = [NSMutableArray new];
	switch(version){
	/* --------- iOS 12 --------- */ 
		case 12: {
			switch(configuration){
			/*  case 0 = sort alphabetically | case 1 = sort by badge value | case 2 = sort by hue | case 3 = sort randomly  */
				case 0: {
					// grab app names and SBIcons
					NSMutableArray* appNames = [NSMutableArray new];
					NSMutableArray* appIcons = [NSMutableArray new];
					for(SBIcon *icon in [self.model leafIcons]){
						// we don't want to grab hidden apps
						if(![MSHookIvar<NSSet *>(self.model, "_hiddenIconTags") containsObject:[icon applicationBundleID]]){
							[appNames addObject:icon.displayName];
							[appIcons addObject:icon];
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

				case 1: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						// we don't want to grab hidden apps
						if(![MSHookIvar<NSSet *>(self.model, "_hiddenIconTags") containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// get icons with badges
					NSMutableArray *badgedAppIcons = [NSMutableArray new];
					for(SBIcon *icon in visibleAppIcons){
						if(icon.badgeValue > 0){
							[badgedAppIcons addObject:icon];
						}
					}

					// remove duplicate icons
					[visibleAppIcons removeObjectsInArray:badgedAppIcons];
					
					// sort badged icons in descending order 
					NSSortDescriptor *badgeValue = [NSSortDescriptor sortDescriptorWithKey:@"badgeValue" ascending:NO];
					[badgedAppIcons sortUsingDescriptors:@[badgeValue]];

					// add now-sorted badged icons, re-add non-badged icons, and put into sortedIcons array
					NSMutableArray *sortedIcons = [NSMutableArray new];
					[sortedIcons addObjectsFromArray:badgedAppIcons];
					[sortedIcons addObjectsFromArray:visibleAppIcons];

					// place sorted SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
					}
					break;
				}

				case 2: {
					// grab app icons, app names, and app icon images 
					NSMutableArray *visibleAppNames = [NSMutableArray new];
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					NSMutableArray *visibleAppIconImages = [NSMutableArray new];
					// No readily available image cache like 13/14, so have to grab em manually
					for(SBIcon *icon in [self.model leafIcons]){ 						 
						// we don't want to grab hidden apps
						if(![MSHookIvar<NSSet *>(self.model, "_hiddenIconTags") containsObject:[icon applicationBundleID]]){
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
						NSArray *icon = [hsImages allKeysForObject:object];
						NSString *key = [icon objectAtIndex:0];
						[sortedAppIcons addObject:[hsIcons objectForKey:key]]; 
					} 
					break;
				}
			
				case 3: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						// we don't want to grab hidden apps
						if(![MSHookIvar<NSSet *>(self.model, "_hiddenIconTags") containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// 'sort' icons randomly
					NSArray *sortedIcons = [[visibleAppIcons copy] shuffledArray]; // (NSArray *)shuffledArray requires importing GameplayKit framework

					// place 'sorted' SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
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
				[UIView animateWithDuration:0.5 animations:^{
					[listview layoutIconsNow];
				}];
			}

			//clear dock
			SBIconListView *dockListView = [self _currentFolderController].dockIconListView;
			for(SBIcon *icon in [dockListView icons]) {
				[dockListView removeIcon:icon]; 
			}
			[dockListView layoutIconsNow];
			break;
		}

	/* --------- iOS 13 --------- */ 
		case 13: {
			switch(configuration){
				case 0: {
					// grab app names and SBIcons
					NSMutableArray* appNames = [NSMutableArray new];
					NSMutableArray* appIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab hidden apps
						if(![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[appNames addObject:icon.displayName];
							[appIcons addObject:icon];
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

				case 1: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab hidden apps
						if(![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// get icons with badges
					NSMutableArray *badgedAppIcons = [NSMutableArray new];
					for(SBIcon *icon in visibleAppIcons){
						if(icon.badgeValue > 0){
							[badgedAppIcons addObject:icon];
						}
					}

					// remove duplicate icons
					[visibleAppIcons removeObjectsInArray:badgedAppIcons];
					
					// sort badged icons in descending order 
					NSSortDescriptor *badgeValue = [NSSortDescriptor sortDescriptorWithKey:@"badgeValue" ascending:NO];
					[badgedAppIcons sortUsingDescriptors:@[badgeValue]];

					// add now-sorted badged icons, re-add non-badged icons, and put into sortedIcons array
					NSMutableArray *sortedIcons = [NSMutableArray new];
					[sortedIcons addObjectsFromArray:badgedAppIcons];
					[sortedIcons addObjectsFromArray:visibleAppIcons];

					// place sorted SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
					}
					break;
				}

				case 2: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab hidden apps
						if(![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
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
						NSArray *icon = [hsIcons allKeysForObject:object];
						NSString *key = [icon objectAtIndex:0];
						[sortedAppIcons addObject:[self.model expectedIconForDisplayIdentifier:key]];
					}
					break;
				}

				case 3: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab hidden apps
						if(![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// 'sort' icons randomly
					NSArray *sortedIcons = [[visibleAppIcons copy] shuffledArray]; // (NSArray *)shuffledArray requires importing GameplayKit framework

					// place 'sorted' SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
					}
					break;
				}
			}
			
			// remove icons 	
			[self.model removeAllIcons];
			[self.model layout]; 

			// re-add icons in now-sorted order
			[UIView animateWithDuration:0.5 animations:^{
				[self.rootFolder addIcons:sortedAppIcons];
			}];
			break;
		}

	/* --------- iOS 14 --------- */ 
		case 14: {
			switch(configuration){
				case 0: {
					// grab app names and SBIcons
					NSMutableArray* appNames = [NSMutableArray new];
					NSMutableArray* appIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab widgets or hidden apps 
						if(![icon isMemberOfClass:%c(SBWidgetIcon)] && ![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[appNames addObject:icon.displayName];
							[appIcons addObject:icon];
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

				case 1: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab widgets or hidden apps
						if(![icon isMemberOfClass:%c(SBWidgetIcon)] && ![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// get icons with badges
					NSMutableArray *badgedAppIcons = [NSMutableArray new];
					for(SBIcon *icon in visibleAppIcons){
						if(icon.badgeValue > 0){
							[badgedAppIcons addObject:icon];
						}
					}

					// remove duplicate icons
					[visibleAppIcons removeObjectsInArray:badgedAppIcons];
					
					// sort badged icons in descending order 
					NSSortDescriptor *badgeValue = [NSSortDescriptor sortDescriptorWithKey:@"badgeValue" ascending:NO];
					[badgedAppIcons sortUsingDescriptors:@[badgeValue]];

					// add now-sorted badged icons, re-add non-badged icons, and put into sortedIcons array
					NSMutableArray *sortedIcons = [NSMutableArray new];
					[sortedIcons addObjectsFromArray:badgedAppIcons];
					[sortedIcons addObjectsFromArray:visibleAppIcons];

					// place sorted SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
					}
					break;
				}

				case 2: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab widgets
						if(![icon isMemberOfClass:%c(SBWidgetIcon)]){ 
							[visibleAppIcons addObject:icon];
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
						NSArray *icon = [hsIcons allKeysForObject:object];
						NSString *key = [icon objectAtIndex:0];
						// we don't want to grab these hidden apps 
						// would put this check in the leafIcons for loop, like I do elsewhere, but they're present again in the image cache, for some reason, so this saves us doing it twice
						if(![self.model.hiddenIconTags containsObject:key]){
							[sortedAppIcons addObject:[self.model expectedIconForDisplayIdentifier:key]];
						}
					}
					break;
				}
				
				case 3: {
					// grab SBIcons 
					NSMutableArray *visibleAppIcons = [NSMutableArray new];
					for(SBIcon *icon in self.model.leafIcons){
						//we don't want to grab widgets or hidden apps
						if(![icon isMemberOfClass:%c(SBWidgetIcon)] && ![self.model.hiddenIconTags containsObject:[icon applicationBundleID]]){
							[visibleAppIcons addObject:icon];
						}
					}

					// 'sort' icons randomly
					NSArray *sortedIcons = [[visibleAppIcons copy] shuffledArray]; // (NSArray *)shuffledArray requires importing GameplayKit framework

					// place 'sorted' SBIcons orderly into finalized array 
					for(SBIcon *object in sortedIcons){
						[sortedAppIcons addObject:object];
					}
					break;
				}
			}
			
			// remove icons 	
			[self.model removeAllIcons];
			[self.model layout]; 

			// re-add icons in now-sorted order
			[UIView animateWithDuration:0.5 animations:^{
				[self.rootFolder addIcons:sortedAppIcons];
			}];
			break;
		}
	}
}		
%end
