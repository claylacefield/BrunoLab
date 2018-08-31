/*
*******************************************************************
PROGRAM:
    iolib.o

DESCRIPTION:
    Library routines for performing standard io functions on data files

AUTHOR:
    Written by Matthew Wilson
    ARL Division of Neural Systems, Memory, and Aging
    University of Arizona
    Tucson, AZ 85724
    wilson@nsma.arizona.edu

DATES:
    original 9/91
    program update 9/91
*******************************************************************
*/

#include <math.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "iolib.h"

#define VERSION "2.0"
#define REVISION "2.12"

/*
** the version number should be updated any time changes are made to
** the library routines including addition of new routines.
** The revision level should be changed only when existing routines
** are modified. Changes which result in incompatibilities with
** previous versions of a library routine should be reflected in a
** change in the major revision level.
*/

char iolibver[2][20] = {"iolib.a Version",VERSION};
char iolibrev[2][20] = {"iolib.a Revision",REVISION};

/*
** ReadHeader
** reads the standard file header and returns the header size.
** Also returns the header contents in the argument list header_contents.
** The file should be rewound before calling this routine.
** The file position is left at the first byte past the header
** if no header is found then the file is rewound to the position
** it started in.
*/
#define MAXLINE 1000

char *CopyString(s)
char	*s;
{
char	*newstr;

    if(s == NULL) return(NULL);
    if((newstr = (char *)malloc(sizeof(char)*(strlen(s)+1))) == NULL){
	fprintf(stderr,"ERROR: unable to allocate new string\n");
	return(NULL);
    }
    strcpy(newstr,s);
    return(newstr);
}

char **ReadHeader(fp,headersize)
FILE	*fp;
int	*headersize;
{
int	hasheader;
char	line[MAXLINE];
long	start;
char	**header_contents;
char	**new_header_contents;
int	nheaderlines;
int	done;
int	status;
int	eol;

    if(fp == NULL) return(NULL);
    if(headersize == NULL) return(NULL);
    hasheader = 1;
    nheaderlines = 0;
    header_contents = NULL;
    done = 0;
    /*
    ** determine the starting file position
    */
    start = ftell(fp);
    /*
    ** look for the magic start-of-header string
    */
    if(fread(line,sizeof(char),MAGIC_SOH_STRSIZE,fp) != MAGIC_SOH_STRSIZE){
	/*
	** unable to read the header
	*/
	hasheader = 0;
    } else {
	/*
	** null terminate the string
	*/
	line[MAGIC_SOH_STRSIZE-1] = '\0';
	/*
	** is it the magic start of header string?
	*/
	if((status = strcmp(line,MAGIC_SOH_STR)) != 0){
	    /*
	    ** not the magic string
	    */
	    hasheader = 0;
	} 
    }
    if(!hasheader){
	/*
	** no header was found so reset the file position to its starting
	** location
	*/
	fseek(fp,start,0L);
    } else
    /*
    ** read the header
    */
    while(!done && !feof(fp)){	
	/*
	** read in a line from the header
	*/
	if(fgets(line,MAXLINE,fp) == NULL){
	    /*
	    ** unable to read the header
	    */
	    fprintf(stderr,"ERROR in file header. Abnormal termination\n");
	    exit(-1);
	}
	/*
	** zap the CR
	*/
	if((eol = strlen(line)-1) >= 0){
	    line[eol] = '\0';
	}
	/*
	** look for the magic end-of-header string
	*/
	if(strcmp(line,MAGIC_EOH_STR) == 0){
	    /*
	    ** done
	    */
	    done = 1;
	} else {
	    /*
	    ** add the string to the list of header contents
	    ** by reallocating space for the header list
	    ** (dont forget the NULL entry at the end of
	    ** the list)
	    */
	    if(header_contents == NULL){
		if((header_contents = (char **)malloc(sizeof(char *)*2)) ==
		NULL){
		    fprintf(stderr,"initial malloc failed. Out of memory\n");
		    break;
		}
	    } else {
		if((new_header_contents = (char **)calloc(
		nheaderlines+2,sizeof(char *))) == NULL){
		    fprintf(stderr,"realloc failed. Out of memory\n");
		    break;
		}
		/*
		** copy the previous contents
		*/
		bcopy(header_contents,new_header_contents,(sizeof(char*)*(nheaderlines +1)));
		/*
		** and free the old stuff
		*/
		free(header_contents);
		/*
		** and reassign to the new stuff
		*/
		header_contents = new_header_contents;
#ifdef OLD
		if((header_contents = (char **)realloc(header_contents,
		sizeof(char *)*(nheaderlines+2))) == NULL){
		    fprintf(stderr,"realloc failed. Out of memory\n");
		    break;
		}
#endif
	    }
	    if((header_contents[nheaderlines] = 
	    (char *)malloc((strlen(line)+1)*sizeof(char))) == NULL){
		    fprintf(stderr,"malloc failed. Out of memory\n");
		    break;
	    }
	    strcpy(header_contents[nheaderlines],line);
	    header_contents[nheaderlines+1] = NULL;
	    nheaderlines++;
	}
    }
    /*
    ** report the headersize by comparing the current position with
    ** the starting position
    */
    *headersize = ftell(fp) - start;
    return(header_contents);
}

/*
** sgetargs 
** parses a string for numeric data and returns the results
** in the vector array. The function must be passed an allocated array
** and must be given the maximum number of entries in the array.
** The function returns the actual number of arguments read.
** Data is assumed to be white space separated (space, tab, newline)
** where the amount of white space between arguments is irrelevant.
*/

int sgetargs(line,nmax,vector)
char	*line;
int	nmax;
double	*vector;
{
int	n;
char	*ptr;
char	*eptr;
int	done;

    if(line == NULL) return(0);
    ptr = line;
    done = 0;
    n = 0;
    while(!done){
	/*
	** skip any white space
	*/
	while((*ptr==' ') || (*ptr=='\t') || (*ptr=='\n')) 
	    ptr++;
	if(*ptr == '\0'){
	    /*
	    ** end of the line
	    */
	    break;
	}
	/*
	** find the end of the parameter string
	*/
	for(eptr = ptr;
	    (*eptr != '\0') && (*eptr != ' ') 
	    && (*eptr != '\t') && (*eptr != '\n'); 
	    eptr++);
	if(*eptr == '\0'){
	    /*
	    ** end of the line
	    */
	    done = 1;
	}
	/*
	** terminate it
	*/
	*eptr = '\0';
	/*
	** read the value
	*/
	vector[n] = atof(ptr);
	n++;
	if(n >= nmax) break;
	/*
	** advance to the next parameter
	*/
	ptr = eptr+1;
    }
    return(n);
}

void DisplayHeader(fp,header,headersize)
FILE	*fp;
char	**header;
long	headersize;
{
int	i;

    if(fp == NULL) return;
    if(header != NULL){
	fprintf(fp,"Header size: \t%d bytes\n",headersize);
	fprintf(fp,"Header contents:\n");
	i = 0;
	while(header[i] != NULL){
	    fprintf(fp,"\t%s\n",header[i++]);
	}
    } else {
	fprintf(fp,"No header\n");
    }
}

/*
** returns the string value of a parameter imbedded in the header
*/
char *GetHeaderParameter(header,parm)
char	**header;
char	*parm;
{
int	i;
char	*value;
char	*ptr;
char	*strchr();

    value = NULL;
    if(header != NULL){
	/*
	** go through each line of the header
	*/
	for(i=0;header[i] != NULL;i++){
	    /*
	    ** search for the parameter string which must start on the
	    ** third character of the line
	    */
	    if(strlen(header[i]) < 3) continue;
	    /*
	    ** does it match
	    */
	    if(strncmp(header[i]+2,parm,strlen(parm)) == 0){
		/*
		** now return the value which begins following
		** the whitespace at the end of the parameter name
		*/
		for(value=header[i]+2+strlen(parm)+1;value,*value!='\0';value++){
		    /*
		    ** skip white space
		    */
		    if(*value != ' ' && *value != '\t' && 
		    *value != '\n'){
			/*
			** found the value and return it
			*/
			return(value);
		    }
		}
	    }
	}
    } 
    return(value);
}

char *TFstr(val)
int	val;
{
    if(val == 0){
	return("FALSE");
    } else {
	return("TRUE");
    }
}

void BeginStandardHeader(fpout,argc,argv)
FILE	*fpout;
int	argc;
char	**argv;
{
char	*progname;
long	clock;
char	*username;
char	*realname;
char	*getenv();
int	i;

    if(fpout == NULL) return;
    fprintf(fpout,"%s\n",MAGIC_SOH_STR);
    if(argc > 0){
	fprintf(fpout,"%% Program: \t%s\n",argv[0]);
	fprintf(fpout,"%% Argc: \t%d\n",argc);
	/*
	** write out the command line arguments
	*/
	for(i=1;i<argc;i++){
	    fprintf(fpout,"%% Argv[%d] :\t%s\n",i,argv[i]);
	}
    }
    time(&clock);
    fprintf(fpout,"%% Date: \t%s",ctime(&clock));

    if((realname = getenv("NAME")) == NULL){
	realname = "";
    }
    if((username = getenv("USER")) == NULL){
	username = "unknown";
    }
    fprintf(fpout,"%% User: \t%s (%s)\n",username,realname);
}

void EndStandardHeader(fpout)
FILE	*fpout;
{
    if(fpout == NULL) return;
    fprintf(fpout,"%s\n",MAGIC_EOH_STR);
}

char *iolibversion()
{
    return(VERSION);
}

char *iolibrevision()
{
    return(REVISION);
}

#define VERIFYBLOCKSIZE	1024

int VerifyIdentical(fname1,fname2)
char	*fname1;
char	*fname2;
{
FILE	*fp1;
FILE	*fp2;
char	buffer1[VERIFYBLOCKSIZE];
char	buffer2[VERIFYBLOCKSIZE];
long	headersize1;
long	headersize2;
int	nread1;
int	nread2;

    /*
    ** open the files
    */
    if((fp1 = fopen(fname1,"r")) == NULL){
	fprintf(stderr,"unable to open file '%s'\n",fname1);
	return(1);
    }
    if((fp2 = fopen(fname2,"r")) == NULL){
	fprintf(stderr,"unable to open file '%s'\n",fname2);
	fclose(fp1);
	return(1);
    }
    /*
    ** skip the headers
    */
    rewind(fp1);
    rewind(fp2);
    ReadHeader(fp1,&headersize1);
    ReadHeader(fp2,&headersize2);
    fseek(fp1,headersize1,0L);
    fseek(fp2,headersize2,0L);
    while(!feof(fp1) || !feof(fp2)){
	/*
	** read
	*/
	nread1 = fread(buffer1,sizeof(char),VERIFYBLOCKSIZE,fp1);
	nread2 = fread(buffer2,sizeof(char),VERIFYBLOCKSIZE,fp2);
	/*
	** check for identical read buffer size
	*/
	if(nread1 != nread2){
	    /*
	    ** not identical
	    */
	    fclose(fp1);
	    fclose(fp2);
	    return(1);
	}
	/*
	** check for empty read buffers (eof)
	*/
	if((nread1 == 0) || (nread2 == 0)){
	    break;
	}
	/*
	** compare read buffers
	*/

/*	if(bcmp(buffer1,buffer2,nread1) != 0){
	    fclose(fp1);
	    fclose(fp2);
	    return(1);
	}
*/	
    }
    /*
    ** check for identical eof
    */
    if(!feof(fp1) || !feof(fp2)){
	/*
	** not identical
	*/
	fclose(fp1);
	fclose(fp2);
	return(1);
    }
    return(0);
}

#define BLOCKSIZE 1024

int AppendToHeader(fname,newline)
char	*fname;
char	*newline;
{
FILE	*fpout;
FILE	*fpin;
int	i;
int	done;
char	*tmpfile;
char	*tempnam();
char	**header;
long	headersize;
char	comstr[200];
int	nread;
int	nwrite;
char	buffer[BLOCKSIZE];
char	*getenv();
int	status;

    /*
    ** open the file
    */
    if((fpin = fopen(fname,"r")) == NULL){
	fprintf(stderr,"unable to open file %s\n",fname);
	return(0);
    }
    /*
    ** read in the header 
    */
    header = ReadHeader(fpin,&headersize);
    /*
    ** create a temporary file
    */
    if((tmpfile = tempnam(NULL,"eh")) == NULL){
	fprintf(stderr,"unable to create temporary data file name\n");
	exit(-1);
    }
    if((fpout = fopen(tmpfile,"w")) == NULL){
	fprintf(stderr,"unable to create temporary data file\n");
	exit(-1);
    }
    /*
    ** start the new header
    */
    fprintf(fpout,"%s\n",MAGIC_SOH_STR);
    /*
    ** copy the old header to the temporary data file
    */
    if(header){
	for(i=0;;i++){
	    if(header[i] == NULL) break;
	    fprintf(fpout,"%s\n",header[i]);
	}
    }
    /*
    ** append the new data to the temporary header
    */
    fprintf(fpout,"%s",newline);
    /*
    ** end of new header
    */
    fprintf(fpout,"%s\n",MAGIC_EOH_STR);
    /*
    ** write out the data to the temporary data file
    */
    fseek(fpin,headersize,0L);
    done = 0;
    while(!done){
	if((nread = fread(buffer,sizeof(char),BLOCKSIZE,fpin)) != BLOCKSIZE){
	    done = 1;
	}
	if((nwrite = fwrite(buffer,sizeof(char),nread,fpout)) != nread){
	    fprintf(stderr,"error writing data file. Append aborted\n");
	    return(0);
	}
    }
    fclose(fpout);
    fclose(fpin);

    /*
    ** verify the new data file against the original data file
    */
    if(VerifyIdentical(fname,tmpfile) != 0){
	fprintf(stderr,"Data files not identical. Append aborted.\n");
	unlink(tmpfile);
	return(0);
    }
    /*
    ** move the new file to its destination
    */
    sprintf(comstr,"/bin/mv %s %s",tmpfile,fname);
    if((status = system(comstr)) != 0){
	perror("unable to replace old file");
	return(status);
    }
    return(1);
}

int strcount(s,c)
char	*s;
char	c;
{
int	count;

    if(s == NULL) return(0);
    count = 0;
    while(*s != '\0'){
	if(*s == c) count++;
	s++;
    }
    return(count);
}

unsigned long ParseTimestamp(s)
char	*s;
{
char	*ptr;
char	*ptr2;
unsigned long	time;
unsigned long hour;
unsigned long min;
unsigned long sec;
float fracsec;
char	*strchr();
int	ncolons;
char	*fracptr;
char	timestr[100];	

    if(s == NULL){
	return(0);
    }
    /*
    ** copy the passed argument to the timestring for
    ** manipulation
    */
    strcpy(timestr,s);
    /*
    ** check for hr:min:sec.fracsec format vs min:sec
    */
    ncolons = strcount(timestr,':');
    fracsec = 0;
    if((fracptr = strchr(timestr,'.')) != NULL){
	sscanf(fracptr,"%f",&fracsec);
	*fracptr = '\0';
    };
    switch(ncolons){
    case 0:
	if(fracptr){
	    sscanf(timestr,"%ld",&sec);
	    time = sec*1e4 + (fracsec*1e4 + 0.5); 
	} else {
	    /*
	    ** straight timestamp
	    */
	    sscanf(timestr,"%ld",&time);
	}
	break;
    case 1:
	/*
	** find the colon
	*/
	ptr = strchr(timestr,':');
	/*
	** separate the minutes and the seconds into two strings
	*/
	*ptr = '\0';
	/*
	** read the minutes before the colon
	*/
	sscanf(timestr,"%ld",&min);
	/*
	** read the seconds after the colon
	*/
	sscanf(ptr+1,"%ld",&sec);
	/*
	** compute the timestamp
	*/
	time = min*6e5 + sec*1e4 + (fracsec*1e4 + 0.5); 
	break;
    case 2:
	/*
	** find the first colon
	*/
	ptr = strchr(timestr,':');
	/*
	** find the second colon
	*/
	ptr2 = strchr(ptr+1,':');
	/*
	** separate the hours, minutes and the seconds into strings
	*/
	*ptr = '\0';
	*ptr2 = '\0';
	/*
	** read the hours before the first colon
	*/
	sscanf(timestr,"%ld",&hour);
	/*
	** read the minutes before the second colon
	*/
	sscanf(ptr+1,"%ld",&min);
	/*
	** read the seconds after the colon
	*/
	sscanf(ptr2+1,"%ld",&sec);
	/*
	** compute the timestamp
	*/
	time = hour*36e6 + min*6e5 + sec*1e4 + (fracsec*1e4 + 0.5); 
	break;
    default:
	fprintf(stderr,"unable to parse timestamp '%s'\n",timestr);
	return(0);
    }
    return(time);
}

int IsStringEmpty(str)
char	*str;
{
    if(str == NULL) return(1);
    /*
    ** scan the string to see if there are any non-white space
    ** characters in it
    */
    while(str && (*str != '\0')){
	if((*str != ' ') && (*str != '\t') && (*str != '\n')){
	    /*
	    ** found a non-white space character
	    */
	    return(0);
	}
	str++;
    }
    /*
    ** all white space
    */
    return(1);
}

char *TimestampToString(timestamp)
unsigned long timestamp;
{
int	hour;
int	min;
int	sec;
static char string[20];
double	fracsec;

    hour = (int)((timestamp/1e4)/3600);
    min = (int)((timestamp/1e4)/60 - 60*hour);
    sec = (int)(timestamp/1e4 - 60*min - 3600*hour);
    fracsec = ((double)timestamp/1.0e4 - (int)(timestamp/1e4))*1e4 + 0.5;
    if(hour > 0){
	sprintf(string,"%d:%02d:%02d.%04d",hour,min,sec,(int)fracsec);
    } else {
	sprintf(string,"%02d:%02d.%04d",min,sec,(int)fracsec);
    }
    return(string);
}

FormatTime(timestamp,min,sec)
unsigned long timestamp;
int	*min;
int	*sec;
{
    *min = (int)((timestamp/1e4)/60);
    *sec = (int)(timestamp/1e4 - 60*(int)((timestamp/1e4)/60));
}

int *ReadBinaryFormatInfo(fp,vectorsize)
FILE	*fp;
int	*vectorsize;
{
int	*vectorformat;

    if(vectorsize == NULL){
	return(NULL);
    }
    if(fread(vectorsize,sizeof(int),1,fp) != 1){
	fprintf(stderr,
	"ERROR: unable to read binary vector size information\n");
	return(NULL);
    }
    if((vectorformat = (int *)malloc((*vectorsize)*sizeof(int))) == NULL){
	fprintf(stderr,
	"MEMORY ERROR: unable to allocate binary format vector\n");
	return(NULL);
    }
    if(fread(vectorformat,sizeof(int),(*vectorsize),fp) != *vectorsize){
	fprintf(stderr,
	"ERROR: unable to read binary vector format information\n");
	return(NULL);
    }
    return(vectorformat);
}

int	*ReadXviewFormatInfo(fp,xsize,ysize)
FILE	*fp;
int	*xsize;
int	*ysize;
{
int	*vectorformat;
float	dt;

    if(fread(xsize,sizeof(int),1,fp) != 1){
	fprintf(stderr,
	"ERROR: unable to read xview xsize information\n");
	return(NULL);
    }
    if(fread(ysize,sizeof(int),1,fp) != 1){
	fprintf(stderr,
	"ERROR: unable to read xview ysize information\n");
	return(NULL);
    }
    if(fread(&dt,sizeof(float),1,fp) != 1){
	fprintf(stderr,
	"ERROR: unable to read xview dt information\n");
	return(NULL);
    }
    if((vectorformat = (int *)malloc(1*sizeof(int))) == NULL){
	fprintf(stderr,
	"MEMORY ERROR: unable to allocate binary format vector\n");
	return(NULL);
    }
    if(fread(vectorformat,sizeof(int),1,fp) != 1){
	fprintf(stderr,
	"ERROR: unable to read xview datatype information\n");
	return(NULL);
    }
    return(vectorformat);
}

BgSystemProcess(s)
char	*s;
{
int pid;
char	*argv[200];
char	tmpstr[200];
char	*sptr;
int		cnt;
short	string_on;

    strcpy(tmpstr,s);
    sptr = tmpstr;
    cnt = 0;
    /*
    * construct the damned argument list myself!
    */
    while(*sptr != '\0'){
	    /*
	    * skip leading blanks
	    */
	    string_on = 0;
	    while((*sptr == ' ') || (*sptr == '\'')){
		    if(*sptr = '\'') string_on = 1;
		    sptr++;
	    }
	    /*
	    * point to the beginning of the arg
	    */
	    argv[cnt++] = sptr;
	    /*
	    * find the end of the arg
	    */
	    while(((*sptr != ' ') || string_on) && (*sptr != '\0') && (*sptr != '\'')){
		    sptr++;
	    }
	    /*
	    * replace the space with a null
	    */
	    if(*sptr != '\0') *sptr++ = '\0';
    }
    argv[cnt] = NULL;

/*deleted fork stuff -- RMB*/
}

/*
** implements the 'system' routine using vfork rather than fork
*/
System(s)
char	*s;
{
/* deleted more system fork stuff */
}


Usleep(usec)
int usec;
{
/* deleted - RMB */
}

int GetFileType(header)
char	**header;
{
char	*filetype;
int	type;

    if(header == NULL) return(NULL);
    /*
    ** look for the file type in the header
    */
    /*
    ** default to ascii
    */
    type = ASCII;
    if((filetype = GetHeaderParameter(header,"File type:")) != NULL){
	/*
	** look for the Binary value
	*/
	if(strncmp(filetype,"Binary",strlen("Binary")) == 0){
	    type = BINARY;
	}
    }
    return(type);
}


char *GetFieldString(header)
char	**header;
{
char	*str;

    if(header == NULL) return(NULL);
    if((str = GetHeaderParameter(header,"PARAMETERS:")) == NULL){
       /*
	** try the other identifier
	*/
	str = GetHeaderParameter(header,"Fields:");
    }
    return(str);
}


int GetFieldCount(fieldstr)
char	*fieldstr;
{
int	count;
char	*sptr;

    if(fieldstr == NULL){
	return(0);
    }
    /*
    ** parse individual names and assign them to 
    ** projections 
    */
    count = 0;
    while(*fieldstr != '\0'){
	/*
	** strip off leading white space
	*/
	while((fieldstr != NULL) && (*fieldstr != '\0')){
	    if((*fieldstr != ' ') && (*fieldstr != '\t')){
		break;
	    }
	    fieldstr++;
	}
	if(*fieldstr == '\0') return(count);
	/*
	** find the trailing white space marking the end
	** of the field descriptor
	*/
	while((fieldstr != NULL) && (*fieldstr != '\0')){
	    if((*fieldstr == ' ') || (*fieldstr == '\t')){
		break;
	    }
	    fieldstr++;
	}
	/*
	** increment the field counter
	*/
	count++;
    }
    return(count);
}

int ParseSingleFieldDescriptor(fieldstr,fieldinfo)
char	*fieldstr;
FieldInfo	*fieldinfo;
{
char	*sptr;
char	*eptr;
int	len;
char	line[100];

    if(fieldstr == NULL || fieldinfo == NULL) return(0);
    sptr = fieldstr;
    /*
    ** strip off leading white space
    */
    while((sptr != NULL) && (*sptr != '\0')){
	if((*sptr != ' ') && (*sptr != '\t')){
	    break;
	}
	sptr++;
    }
    if(*sptr == '\0') return(0);
    /*
    ** the first comma separated string is the field name
    */
    if((eptr = strchr(sptr,',')) == NULL){
	/*
	** no comma so just take the whole thing
	** and leave the field descriptor info unknown
	*/
	fieldinfo->name = (char *)malloc(strlen(sptr)+1);
	strcpy(fieldinfo->name,sptr);
	fieldinfo->type = -1;
	fieldinfo->size = -1;
	fieldinfo->count = -1;
	return(1);
    } else {
	/*
	** just take the string up to the comma
	*/
	len = (int)(eptr - sptr);
	fieldinfo->name = (char *)malloc(len+1);
	strncpy(fieldinfo->name,sptr,len);
	fieldinfo->name[len] = '\0';
    }
    sptr = eptr + 1;
    /*
    ** the next comma separated field is the type
    */
    if((eptr = strchr(sptr,',')) == NULL){
	/*
	** no comma so just take the whole thing
	** and leave the field descriptor info unknown
	*/
	fieldinfo->type = atoi(sptr);
	fieldinfo->size = -1;
	fieldinfo->count = -1;
	return(1);
    } else {
	/*
	** just take the string up to the comma
	*/
	len = (int)(eptr - sptr);
	strncpy(line,sptr,len);
	line[len] = '\0';
	fieldinfo->type = atoi(line);
    }
    sptr = eptr + 1;
    /*
    ** the next comma separated field is the size
    */
    if((eptr = strchr(sptr,',')) == NULL){
	/*
	** no comma so just take the whole thing
	** and leave the field descriptor info unknown
	*/
	fieldinfo->size = atoi(sptr);
	fieldinfo->count = -1;
	return(1);
    } else {
	/*
	** just take the string up to the comma
	*/
	len = (int)(eptr - sptr);
	strncpy(line,sptr,len);
	line[len] = '\0';
	fieldinfo->size = atoi(line);
    }
    sptr = eptr + 1;
    /*
    ** the last field is the count
    */
    /*
    ** no comma so just take the whole thing
    ** and leave the field descriptor info unknown
    */
    fieldinfo->count = atoi(sptr);
    return(1);
}

#define MAXLINE 1000
int GetFieldInfoByNumber(fieldstr,index,fieldinfo)
char	*fieldstr;
int	index;
FieldInfo	*fieldinfo;
{
char	*eptr;
char	*sptr;
char	line[MAXLINE];
int	len;
int	count;

    if(fieldstr == NULL || fieldinfo == NULL){
	return(0);
    }
    /*
    ** parse individual names and assign them to 
    ** projections 
    */
    count = 0;
    sptr = fieldstr;
    while(*sptr != '\0'){
	/*
	** strip off leading white space
	*/
	while((sptr != NULL) && (*sptr != '\0')){
	    if((*sptr != ' ') && (*sptr != '\t')){
		break;
	    }
	    sptr++;
	}
	if(*sptr == '\0') break;
	/*
	** find the trailing white space marking the end
	** of the field descriptor
	*/
	eptr = sptr;
	while((eptr != NULL) && (*eptr != '\0')){
	    if((*eptr == ' ') || (*eptr == '\t')){
		break;
	    }
	    eptr++;
	}
	/*
	** is this the field to process?
	*/
	if(count == index){
	    /*
	    ** copy the field descriptor into temporary storage
	    */
	    if((len = (int)(eptr - sptr)) >= MAXLINE){
		fprintf(stderr,"field descriptor too long\n");
		return(0);
	    }
	    strncpy(line,sptr,len);
	    line[len] = '\0';
	    /*
	    ** parse the field descriptor
	    */
	    if(ParseSingleFieldDescriptor(line,fieldinfo)){
		fieldinfo->column = count;
		return(1);
	    } else {
		return(0);
	    }
	}
	/*
	** move to the next descriptor field
	*/
	if(*eptr == '\0'){
	    sptr = eptr;
	} else {
	    sptr = eptr+1;
	}
	/*
	** increment the field counter
	*/
	count++;
    }
    return(0);
}
#undef MAXLINE

#define MAXLINE 1000
int GetFieldInfoByName(fieldstr,name,fieldinfo)
char	*fieldstr;
char	*name;
FieldInfo	*fieldinfo;
{
char	*eptr;
char	*sptr;
char	line[MAXLINE];
int	len;
int	count;

    if(fieldstr == NULL || fieldinfo == NULL){
	return(0);
    }
    /*
    ** parse individual names and assign them to 
    ** projections 
    */
    count = 0;
    sptr = fieldstr;
    while(*sptr != '\0'){
	/*
	** strip off leading white space
	*/
	while((sptr != NULL) && (*sptr != '\0')){
	    if((*sptr != ' ') && (*sptr != '\t')){
		break;
	    }
	    sptr++;
	}
	if(*sptr == '\0') break;
	/*
	** find the trailing white space marking the end
	** of the field descriptor
	*/
	eptr = sptr;
	while((eptr != NULL) && (*eptr != '\0')){
	    if((*eptr == ' ') || (*eptr == '\t')){
		break;
	    }
	    eptr++;
	}
	/*
	** copy the field descriptor into temporary storage
	*/
	if((len = (int)(eptr - sptr)) >= MAXLINE){
	    fprintf(stderr,"field descriptor too long\n");
	    return(0);
	}
	strncpy(line,sptr,len);
	line[len] = '\0';
	/*
	** parse the field descriptor
	*/
	if(ParseSingleFieldDescriptor(line,fieldinfo)){
	    /*
	    ** check the name
	    */
	    if(strcmp(fieldinfo->name,name) == 0){
		fieldinfo->column = count;
		return(1);
	    }
	} else {
	    return(0);
	}
	/*
	** move to the next descriptor field
	*/
	if(*eptr == '\0'){
	    sptr = eptr;
	} else {
	    sptr = eptr+1;
	}
	/*
	** increment the field counter
	*/
	count++;
    }
    return(0);
}
#undef MAXLINE

