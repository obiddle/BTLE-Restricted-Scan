//
//  Greentape
//





+ (GTBackground *)backObj {
    static GTBackground *backgroundObj = nil;
    if (backgroundObj == nil) {
        backgroundObj = [[[self class] alloc] init];
        backgroundObj.detectedSensor = DETECTED_NONE;
        backgroundObj.sensorIDArray = [NSArray arrayWithObjects:@"6a873083-6c06-4dfa-bb54-69b2240f9e9f", @"06a87308-36c0-64df-abb5-469b2240f9e9", @"fb934e79-b1eb-4d6e-94c8-1473de38781f", nil];
        [backgroundObj loadGreatArray];
    }
    return backgroundObj;
}

-(void) initBTScanner:(GTProximityPlugin*) btPlug // Let's start our app
{
    //this represents our local device, start observing defices and connect to them
    cbCentral = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //[cbCentral setDelegate:self];
    myGTProximityPlugin = btPlug;
    sensorname = nil;
}


-(void) scanBTSensors
{

    NSLog(@"Starting BACKGROUND SCANNING....");
    // Create a dictionary for passing down to the scan with service method
    NSMutableArray *sensorTransferArray = [[NSMutableArray alloc] init];
    for (NSString *sensorIDString in self.sensorIDArray) {
        [sensorTransferArray addObject:[CBUUID UUIDWithString:sensorIDString]];
    }
    //start looking for devices that are advertising this service
    [cbCentral scanForPeripheralsWithServices:sensorTransferArray options: [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey]];
}



- (void)centralManager:(CBCentralManager *)central //call back after finding peripheral
 didDiscoverPeripheral:(CBPeripheral *)peripheral // handle to talk to remote device
     advertisementData:(NSDictionary *)advertisementData // whats ervices, what power, what name
                  RSSI:(NSNumber *)RSSI // signal strenth

{

    btSensor = peripheral;
    btRSSI = RSSI;
    int rssiInt = [btRSSI intValue];

    NSLog(@"Show me the RSSI number is %i", rssiInt);
    // Get the NSArray from "advertisementData" (NSDictionary).
    NSArray *uuidArray = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];

    NSLog(@"Show me the Array %@", uuidArray);
    // Cast the object of UUIDArray to CBUUID class.
    CBUUID *uuid = (CBUUID *)[uuidArray lastObject];
    // Transfer CBUUID to NSString.
    uuidString = [self representativeString:uuid];

    NSLog(@"show me the uuid %@", uuidString);
    NSLog(@"Background Scan get delgete");
    [central connectPeripheral:peripheral options:nil];
    if(btSensor != nil) {
        NSLog(@"RSSI:%@",btRSSI);
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
            
            // Check if the UUID is what we want.
            for (NSString *oneUUIDString in self.sensorIDArray) {
                if ([uuidString isEqualToString:oneUUIDString]) {
                    
                    // Push welcome View should be after loaded storeID ~~~~~~~~~~~~
                    
                    if (pushedWelcomeView == NO) {
                        pushedWelcomeView = YES;
                        NSLog(@"change something GTProximityPlugin");
                        
                        num++;
                        NSLog(@"num is %i", num);
                        //NSString *string = [NSString stringWithFormat:@"viva%i", num];
                        //NSLog(@"string is %@", string);
                        [myGTProximityPlugin sendresult:uuidString];
                        
                        [self loadStoreInformation];
                        [self performSelector:@selector(changeBackPushWelcomeView) withObject:nil afterDelay:3600];
                    }
                    
                    if (detectedSensor == DETECTED_NONE)
                    {
                        detectedSensor = DETECTED_ACTIVE; // This means detect Sensor while active;
                        [self sendStoreID:@"112233" andUserID:@"2121" andUserStatus:@"1"];
                    }
                }
            }
            
            NSLog(@"Found Sensor during UIApplicationStateActive");         
        }
        
        else if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
            // This means detect sensor while it first enter background.
            if (detectedSensor == DETECTED_ACTIVE) {
                detectedSensor = DETECTED_INSTORE;
                savedDate = [NSDate date];
                [self sendStoreID:@"112233" andUserID:@"2121" andUserStatus:@"1"];
                [self performSelector:@selector(changeDateToZero) withObject:nil afterDelay:600.0];
            }
            
            // This means when the user didn't in the store before, but the user will enter into the store. then 
            if (savedDate == nil && detectedSensor == DETECTED_NONE) {
                savedDate = [NSDate date];
                NSLog(@"Date String is %@", [savedDate description]);
                [self sendStoreID:@"112233" andUserID:@"2121" andUserStatus:@"1"];
                //[self loadNotificationContents];
                [self performSelector:@selector(changeDateToZero) withObject:nil afterDelay:600.0];
            }
            
            NSLog(@"SCANNING");
        }
        NSLog(@"Detect Sensor is~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %i", detectedSensor);
    }
 
}


-(void) stopBTScan
{
    NSLog(@"Background Scan....");
    
    [cbCentral stopScan];  
}


@end