//
//  GSNSDataExtensions.m
//
//  Created by khammond on Mon Oct 29 2001.
//  Copyright (c) 2001, 2005 Kyle Hammond. All rights reserved.
//
// Original development comments by Dave Winer.
// Jan 12, 2005 - added AltiVec implementation, and greatly improved encoding speed.

/*	C source code for Base 64 

       Here's the C source code for the Base 64 encoder/decoder.

        File:
                     base64.c
        Created:
                     Saturday, April 5, 1997; 1:30:13 PM
        Modified: 
                     Tuesday, April 8, 1997; 7:52:28 AM

       Dave Winer, dwiner@well.com, UserLand Software, 4/7/97
        
       I built this project using Symantec C++ 7.0.4 on a Mac 9500.
        
       We needed a handle-based Base 64 encoder/decoder. Looked around the
       net, found a bunch of code that couldn't easily be adapted to 
       in-memory stuff. Most of them work on files to conserve memory. This
       is inelegant in scripting environments such as Frontier.
        
       Anyway, so I wrote an encoder/decoder. Docs are being maintained 
       on the web, and updates at:
        
       http://www.scripting.com/midas/base64/
        
       If you port this code to another platform please put the result up
       on a website, and send me a pointer. Also send email if you think this
       isn't a compatible implementation of Base 64 encoding.
        
       BTW, I made it easy to port -- layering out the handle access routines.
       Of course there's a small performance penalty for this, and if you don't
       like it, change it. Thanks!
       */

#import "GSNSDataExtensions.h"

// Comment this out (or change it to a zero) to disable AltiVec processing.

static unsigned long local_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData );


@implementation NSData (Base64Encoding)

static char gEncodingTable[ 64 ] = {
           'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
           'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
           'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
           'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
            };

+ (BOOL)isCharacterPartOfBase64Encoding:(char)inChar
{
    int		i;

    for ( i = 0; i < 64; i++ )
    {
        if ( gEncodingTable[ i ] == inChar )
            return YES;
    }

    return NO;
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)inBase64String
{
    NSData	*result = nil;

    result = [ [ NSData alloc ] initWithBase64EncodedString:inBase64String ];

    return [ result autorelease ];
}

- (id)initWithBase64EncodedString:(NSString *)inBase64String
{
    NSMutableData	*mutableData = nil;

    if ( inBase64String && [ inBase64String length ] > 0 )
    {
        unsigned long		ixtext;
        unsigned long		lentext;
        unsigned char		ch;
        unsigned char		inbuf [4], outbuf [3];
        short				ixinbuf;
        NSData				*base64Data;
		unsigned char		*preprocessed, *decodedBytes;
		unsigned long		preprocessedLength, decodedLength;
		short				ctcharsinbuf = 3;
		BOOL				notDone = YES;

        // Convert the string to ASCII data.
        base64Data = [ inBase64String dataUsingEncoding:NSASCIIStringEncoding ];
        lentext = [ base64Data length ];

		preprocessed = malloc( lentext );	// We may have all valid data!

		// Allocate our outbound data, and set it's length.
		// Do this so we can fill it in without allocating memory in small chunks later.
		mutableData = [ NSMutableData dataWithCapacity:( lentext * 3 ) / 4 + 3 ];
		[ mutableData setLength:( lentext * 3 ) / 4 + 3 ];
		decodedBytes = [ mutableData mutableBytes ];

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )
		if ( lentext > 15 && local_AltiVec_IsPresent( ) )
		{
			preprocessedLength = local_altiVec_preprocessForDecode( [ base64Data bytes ], lentext, preprocessed );
			ixtext = local_altiVec_decode( preprocessed, preprocessedLength, decodedBytes,
						&decodedLength );
		}
		else
#endif // end COMPILE_FOR_ALTIVEC
		{
			preprocessedLength = local_preprocessForDecode( [ base64Data bytes ], lentext, preprocessed );
			decodedLength = 0;
			ixtext = 0;
		}

        ixinbuf = 0;

        while ( notDone && ixtext < preprocessedLength )
        {
            ch = preprocessed[ ixtext++ ];

			if ( 255 == ch )	// Hit our stop signal.
			{
				if (ixinbuf == 0)
					break;		// We're done now!

				else if ((ixinbuf == 1) || (ixinbuf == 2))
				{
					ctcharsinbuf = 1;
					ixinbuf = 3;
				}
				else
					ctcharsinbuf = 2;

				notDone = NO;	// We're finished after the outbuf gets copied this time.
			}

			inbuf [ixinbuf++] = ch;

			if ( 4 == ixinbuf )
			{
				ixinbuf = 0;

				outbuf [0] = (inbuf [0] << 2) | ((inbuf [1] & 0x30) >> 4);

				outbuf [1] = ((inbuf [1] & 0x0F) << 4) | ((inbuf [2] & 0x3C) >> 2);

				outbuf [2] = ((inbuf [2] & 0x03) << 6) | inbuf [3];

				memcpy( &decodedBytes[ decodedLength  ], outbuf, ctcharsinbuf );
				decodedLength += ctcharsinbuf;
			}
        } // end while loop on remaining characters

		free( preprocessed );

		// Adjust length down to however many bytes we actually decoded.
		[ mutableData setLength:decodedLength ];
    }

    self = [ self initWithData:mutableData ];

    return self;
}

- (NSString *)base64EncodingWithLineLength:(unsigned int)inLineLength
{   /*
        Encode the NSData. Some funny stuff about linelength -- it only makes
        sense to make it a multiple of 4. If it's not a multiple of 4, we make it
        so (by only checking it every 4 characters). 

        Further, if it's 0, we don't add any line breaks at all.
    */
        
    const unsigned char	*bytes = [ self bytes ];
	unsigned char		*encodedData;
	unsigned long		encodedLength;
    unsigned long		ixtext;
    unsigned long		lengthData;
    long				ctremaining;
    unsigned char		inbuf [3], outbuf [4];
    short				i;
    short				charsonline = 0, ctcopy;
    unsigned long		ix;
    NSString			*result = nil;

    lengthData = [ self length ];

	if ( inLineLength > 0 )
		// Allocate a buffer large enough to hold everything + line endings.
		encodedData = malloc( ( ( ( lengthData + 1 ) * 4 ) / 3 ) + ( ( ( ( lengthData + 1 ) * 4 ) / 3 ) / inLineLength ) + 1 );
	else
		// Allocate a buffer large enough to hold everything.
		encodedData = malloc( ( ( lengthData + 1 ) * 4 ) / 3 );

#if defined( COMPILE_FOR_ALTIVEC ) && ( COMPILE_FOR_ALTIVEC == 1 )
	if ( lengthData > 12 && local_AltiVec_IsPresent( ) )
	{
		ixtext = local_altiVec_encode( (unsigned char *)bytes, lengthData, encodedData, &encodedLength );

		// Add line endings because the AltiVec algorithm doesn't do that.
        if ( inLineLength > 0 )
		{
			for ( ctremaining = inLineLength; ctremaining < encodedLength; ctremaining += inLineLength )
			{
				// Since dst and src overlap here, use memmove instead of memcpy.
				memmove( &encodedData[ ctremaining + 1 ], &encodedData[ ctremaining ],
							encodedLength - ctremaining );
				encodedData[ ctremaining ] = '\n';
				ctremaining++;
				encodedLength++;
			}

			// Do we need one more line ending at the very end of the string?
			if ( ctremaining == encodedLength )
			{
				encodedData[ ctremaining ] = '\n';
				encodedLength++;
			}
			else
				// If not, we have some characters on the line.
				charsonline = encodedLength - ( ctremaining - inLineLength );
		}
	}
	else
#endif // end COMPILE_FOR_ALTIVEC
	{
		// We can't do anything with AltiVec.  Do it all by standard algorithm.
		ixtext = 0;
		encodedLength = 0;
	}

	ctcopy = 4;

    while ( YES )
    {
        ctremaining = lengthData - ixtext;

		if ( ctremaining >= 4 )
			// Copy next four bytes into inbuf.
			(*(unsigned long *)inbuf) = *(unsigned long *)&bytes[ ixtext ];

        else if ( ctremaining <= 0 )
            break;

		else
		{
			// Have less than four bytes to copy.  Fill extras with zero.
			for ( i = 0; i < 3; i++ )
			{
				ix = ixtext + i;

				if (ix < lengthData)
					inbuf [i] = bytes[ix];
				else
					inbuf [i] = 0;
			} // for loop

			switch ( ctremaining )
			{
				case 1:
					ctcopy = 2; 
					break;

				case 2:
					ctcopy = 3; 
					break;
			} // switch
		}

        outbuf [0] = (inbuf [0] & 0xFC) >> 2;

        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);

        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);

        outbuf [3] = inbuf [2] & 0x3F;

		// Depending on how many characters we're supposed to copy, fill in with '=' characters.
		if ( 4 == ctcopy )
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[2] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[3] ];
		}
		else if ( 3 == ctcopy )
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[2] ];
			encodedData[ encodedLength++ ] = '=';
		}
		else
		{
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[0] ];
			encodedData[ encodedLength++ ] = gEncodingTable[ outbuf[1] ];
			encodedData[ encodedLength++ ] = '=';
			encodedData[ encodedLength++ ] = '=';
		}

        ixtext += 3;

        if ( inLineLength > 0 )
        {	// DW 4/8/97 -- 0 means no line breaks

			charsonline += 4;
            if (charsonline >= inLineLength)
            {
				charsonline = 0;

				encodedData[ encodedLength++ ] = '\n';
            }
        }
    } // end while loop

	// Make a string object out of the encoded data buffer.
	result = [ [ NSString alloc ] initWithBytes:encodedData length:encodedLength
				encoding:NSASCIIStringEncoding ];
	free( encodedData );

	return result;
}

@end



static unsigned long local_preprocessForDecode( const unsigned char *inBytes, unsigned long inBytesLength, unsigned char *outData )
{
	unsigned long		i;
	unsigned char		*outboundData = outData;
	unsigned char		ch;

	for ( i = 0; i < inBytesLength; i++ )
	{
		ch = inBytes[ i ];

		if ((ch >= 'A') && (ch <= 'Z'))
			*outboundData++ = ch - 'A';

		else if ((ch >= 'a') && (ch <= 'z'))
			*outboundData++ = ch - 'a' + 26;

		else if ((ch >= '0') && (ch <= '9'))
			*outboundData++ = ch - '0' + 52;

		else if (ch == '+')
			*outboundData++ = 62;

		else if (ch == '/')
			*outboundData++ = 63;

		else if (ch == '=')
		{	// no op -- put in our stop signal
			*outboundData++ = 255;
			break;
		}
	}

	// How much valid data did we end up with?
	return outboundData - outData;
}
