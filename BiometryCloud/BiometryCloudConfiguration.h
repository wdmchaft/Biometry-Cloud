//
//  BiometryCloudConfiguration.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 4/4/11.
//  Copyright 2011 Clockwise. All rights reserved.
//

//Change to 0 to disable debugginf
#ifndef SHOW_DEBUG_LOG
    #define SHOW_DEBUG_LOG 1
#endif


//definition debugLog function
#if DEBUG && SHOW_DEBUG_LOG
    #define debugLog(...) NSLog(__VA_ARGS__)
#else
    #define debugLog(...)		// Nothing
#endif