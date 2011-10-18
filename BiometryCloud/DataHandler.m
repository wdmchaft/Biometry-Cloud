//
//  DatabaseHandler.m
//  ControlApplication
//
//  Created by Maria Ignacia Hevia Salinas on 05-01-11.
//  Copyright 2011 Clockwise. All rights reserved.
//

#import "DataHandler.h"

#import "MainHeader.h"


@implementation DataHandler


- (id) init {

	if ((self = [super init])) {
        
		databaseName = @"/Clockwise.sqlite";
        propertyListName =@"/Clockwise-config.plist";
		
		// Get the path to the documents directory and append the databaseName
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [documentPaths objectAtIndex:0];
		databasePath=[documentsPath stringByAppendingString:databaseName];
        propertyListPath=[documentsPath stringByAppendingString:propertyListName];
		
		// Execute the "checkAndCreateDatabase" function
		[self checkAndCreateDatabase];
    }    
    return self;
}

- (void)dealloc {

	[databaseName release];
	[databasePath release];

    [super dealloc];
}

-(void) checkAndCreateDatabase{
	
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL dbsuccess;
    
    //Check if the plist has already been saved to the users phone, if not, then copy it over
	BOOL plistsuccess;

	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	[databasePath retain];
	
	// Check if the database has already been created in the users filesystem
	dbsuccess = [fileManager fileExistsAtPath:databasePath];
    
    [propertyListPath retain];
	
	//Check if the plist has already been created in the users filesystem
	plistsuccess=[fileManager fileExistsAtPath:propertyListPath];
	
	// If database doesn´t exist, proceed to copy the database from the application to the users filesystem
	if (!dbsuccess)
	{
        // Get the path to the database in the application package
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        
        // Copy the database from the package to the users filesystem
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	}
	
	//Plist
    if(!plistsuccess)
	{
		//Get the path to the plist in the aplication package
		NSString *plistPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:propertyListName];
		
		//Copy the plist from the package to the users filesystem
		[fileManager copyItemAtPath:plistPathFromApp toPath:propertyListPath error:nil];
        
        //NSLog(@"%@",[error description]);
    }
    
	
	[fileManager release];//must be released
}

#pragma mark - Checking Requests Handling

- (void) storeCheckingRequests:(NSArray *) array {

    writing = TRUE;
	
	[databasePath retain];
	
	// Setup the database object
	sqlite3 *database;
    
    NSData *face_data;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		const char *sqlStatement = "insert into CheckingRequests(face_data, lat, lng, time) Values(?, ?, ?, ?)";
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)  {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			
            for (CheckingRequest *request in array) {
                
                face_data = [NSData dataWithData:UIImageJPEGRepresentation(request.face, 1)];
                
                sqlite3_bind_blob(compiledStatement, 1, [face_data bytes], [face_data length], NULL);
                sqlite3_bind_double(compiledStatement, 2, request.lat);
                sqlite3_bind_double(compiledStatement, 3, request.lng);
                sqlite3_bind_text(compiledStatement, 4, [request.time UTF8String], -1, SQLITE_TRANSIENT);
                
                if(SQLITE_DONE != sqlite3_step(compiledStatement))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                
                sqlite3_reset(compiledStatement);
            }
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	else {
		NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	
	writing = FALSE;
}

- (void) storeCheckingRequest:(CheckingRequest *) request {
	
	writing = TRUE;
	
	[databasePath retain];
	
	// Setup the database object
	sqlite3 *database;
    
    NSData *face_data = [NSData dataWithData:UIImageJPEGRepresentation(request.face, 1)];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		const char *sqlStatement = "insert into CheckingRequests(face_data, lat, lng, time) Values(?, ?, ?, ?)";
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)  {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			
            sqlite3_bind_blob(compiledStatement, 1, [face_data bytes], [face_data length], NULL);
            sqlite3_bind_double(compiledStatement, 2, request.lat);
            sqlite3_bind_double(compiledStatement, 3, request.lng);
            sqlite3_bind_text(compiledStatement, 4, [request.time UTF8String], -1, SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(compiledStatement))
				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	else {
		NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	
	writing = FALSE;
}

- (BOOL) areCheckingRequestsQueued {
	
	if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		int count=0;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			const char *sqlStatement = "select count(*) from CheckingRequests";
			
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
					count = sqlite3_column_int(compiledStatement, 0);
				}
			}
			else {
				NSLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return count;
		
	}
	else {
		
		[NSThread sleepForTimeInterval:0.1];
		
		return [self areCheckingRequestsQueued];
	}
}

- (NSMutableArray *) getCheckingRequests {
	
	if (!writing) {
		[databasePath retain];
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "select * from CheckingRequests";
			sqlite3_stmt *compiledStatement;
			
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
                    NSData *face_data = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 1) length:sqlite3_column_bytes(compiledStatement, 1)];
                    double lat = sqlite3_column_double(compiledStatement, 2);
                    double lng = sqlite3_column_double(compiledStatement, 3);
					NSString *time = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
					
					// Create a new request object with the data from the database
					CheckingRequest *request = [[[CheckingRequest alloc] initWithURL:[NSURL URLWithString:[clockwiseAppDelegate checkingURL]]] autorelease];
                    
                    request.face = [UIImage imageWithData:face_data];
                    request.lat = lat;
                    request.lng = lng;
                    request.time = time;
                    
                    [array addObject:request];
                    
					[face_data release];
				}
			}
			else {
				NSLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
            
            			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return array;//no leaks here, do not autorelease!!
	}
	else {
		[NSThread sleepForTimeInterval:0.1];
		
		return [self getCheckingRequests];
	}
	
}

- (void) deleteCheckingRequest:(CheckingRequest *) request {

    if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "delete from CheckingRequests where time = ?";
			sqlite3_stmt *compiledStatement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                sqlite3_bind_text(compiledStatement, 1, [request.time UTF8String], -1, SQLITE_TRANSIENT);
                
                if(SQLITE_DONE != sqlite3_step(compiledStatement))
                    NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
            }
            
        }
    }
    else {
		[NSThread sleepForTimeInterval:0.1];
		
		[self deleteCheckingRequest:request];
	}
}

#pragma mark - Position Requests Handling

- (void) storePositionRequests:(NSArray *) array {

    writing = TRUE;
	
	[databasePath retain];
	
	// Setup the database object
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		const char *sqlStatement = "insert into PositionRequests(lat, lng, speed, time) Values(?, ?, ?, ?)";
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)  {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            
            for (PositionRequest *request in array) {
                
                sqlite3_bind_double(compiledStatement, 1, request.lat);
                sqlite3_bind_double(compiledStatement, 2, request.lng);
                sqlite3_bind_double(compiledStatement, 3, request.speed);
                sqlite3_bind_text(compiledStatement, 4, [request.time UTF8String], -1, SQLITE_TRANSIENT);
                
                if(SQLITE_DONE != sqlite3_step(compiledStatement))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                
                sqlite3_reset(compiledStatement);
            }
            
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	else {
		NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	
	writing = FALSE;
}

- (void) storePositionRequest:(PositionRequest *) request {
	
	writing = TRUE;
	
	[databasePath retain];
	
	// Setup the database object
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		const char *sqlStatement = "insert into PositionRequests(lat, lng, speed, time) Values(?, ?, ?, ?)";
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)  {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
			
            sqlite3_bind_double(compiledStatement, 1, request.lat);
            sqlite3_bind_double(compiledStatement, 2, request.lng);
            sqlite3_bind_double(compiledStatement, 3, request.speed);
            sqlite3_bind_text(compiledStatement, 4, [request.time UTF8String], -1, SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(compiledStatement))
				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	else {
		NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_close(database);
	
	writing = FALSE;
}

- (BOOL) arePositionRequestsQueued {
	
	if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		int count=0;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			const char *sqlStatement = "select count(*) from PositionRequests";
			
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
					count = sqlite3_column_int(compiledStatement, 0);
				}
			}
			else {
				NSLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return count;
		
	}
	else {
		
		[NSThread sleepForTimeInterval:0.1];
		
		return [self arePositionRequestsQueued];
	}
}

- (NSMutableArray *) getPositionRequests {
	
	if (!writing) {
		[databasePath retain];
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "select * from PositionRequests";
			sqlite3_stmt *compiledStatement;
			
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
				
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// Read the data from the result row
					
                    double lat = sqlite3_column_double(compiledStatement, 1);
                    double lng = sqlite3_column_double(compiledStatement, 2);
                    double speed = sqlite3_column_double(compiledStatement, 3);
					NSString *time = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
					
					// Create a new request object with the data from the database
					PositionRequest *request = [[[PositionRequest alloc] initWithURL:[NSURL URLWithString:[clockwiseAppDelegate positionURL]]] autorelease];
                    
                    request.lat = lat;
                    request.lng = lng;
                    request.time = time;
                    request.speed = speed;
                    
                    [array addObject:request];
				}
			}
			else {
				NSLog(@"Error while reading data. '%s'", sqlite3_errmsg(database));
			}
			
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
		}
		else {
			NSLog(@"Error while opening database. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_close(database);
		
		return array;//no leaks here, do not autorelease!!
	}
	else {
		[NSThread sleepForTimeInterval:0.1];
		
		return [self getPositionRequests];
	}
	
}

- (void) deletePositionRequest:(PositionRequest *) request {
    
    if (!writing) {
		[databasePath retain];
		
		// Setup the database object
		sqlite3 *database;
		
		// Open the database from the users filessytem
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			
			// Setup the SQL Statement and compile it for faster access
			const char *sqlStatement = "delete from PositionRequests where time = ?";
			sqlite3_stmt *compiledStatement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                sqlite3_bind_text(compiledStatement, 1, [request.time UTF8String], -1, SQLITE_TRANSIENT);
                
                if(SQLITE_DONE != sqlite3_step(compiledStatement))
                    NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
            }
            
        }
    }
    else {
		[NSThread sleepForTimeInterval:0.1];
		
		[self deletePositionRequest:request];
	}
}

#pragma mark - Config

-(void)storeConfig:(NSDictionary *)params
{
	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:propertyListPath];
    
    [plistDict setDictionary:params];
    
	[plistDict writeToFile:propertyListPath atomically: YES];
	[plistDict release];
}

-(NSDictionary*)loadConfig
{
	
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsPath = [documentPaths objectAtIndex:0];
	NSString *finalPath= [documentsPath stringByAppendingString:propertyListName];
	NSMutableDictionary* plisDict=[[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
	return [plisDict autorelease];
}

@end
