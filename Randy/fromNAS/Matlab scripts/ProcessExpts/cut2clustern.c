/* cut2clustern.c	(Randy Bruno, June 2000)
 *
 * This .MEX program is intended to be called from MATLAB.
 *
 * MClust outputs an ASCII file of type .cut, which lists the clusters
 * to which spikes were assigned. This conversion utility reads a .cut
 * file and the corresponding .lv file (a binary containing all of the
 * information about the spikes) and generates a detailed ASCII file for
 * each cluster.
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "iolib.h"
#include "mex.h"
#include <time.h>

#define MAXLINE 1000

/* Pauses for a specified number of milliseconds. */
void sleep( clock_t wait ){
   clock_t goal;
   goal = wait + clock();
   while( goal > clock() )      ;}

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

char *GetString(void *ptr)
{
	int buflen, status;
	char *buffer;

	buflen = (mxGetM(ptr) * mxGetN(ptr)) + 1;
	buffer = mxCalloc(buflen, sizeof(char));
	status = mxGetString(ptr, buffer, buflen);
	if (status) mexWarnMsgTxt("mxGetString error");
	return(buffer);
}

int CountClustersInCutFile(char *cutfile_name)
{
	FILE *cutfile;
	int count = 0, cluster = 0, header_size;

	/* open .cut file and skip header portion */
	cutfile = fopen(cutfile_name, "rt");
	if(!cutfile)
	    {
	      printf("Cannot open .cut file '%s'.\n", cutfile_name);
	      return(-1);
	    }
	ReadHeader(cutfile, &header_size);

	while(fscanf(cutfile, "%d", &cluster) != EOF)
		if (cluster > count) count = cluster;
		
	fclose(cutfile);
	return(count);
}


void Convert( char *cutfile_name, char *lvfile_name )
{
	int header_size, nspikes[12], i, cluster, recno=0, nclusters=0, maxCluster;
	FILE *cutfile, *lvfile;
	FILE *clusterfile[12]; /* an array of file pointers */
	unsigned long timestamp;
	signed long trial;
	float stim;
	short amp[128];
	char outfile_name[240], tmp[240];
	int count = 0;

	maxCluster = CountClustersInCutFile(cutfile_name);
	printf("cut2clustern.c: maxCluster = %d\n", maxCluster);

	for (i=0; i<12; i++) nspikes[i] = 0;

	/* open .cut file and skip header portion */
	cutfile = fopen(cutfile_name, "rt");
	if(!cutfile)
	    {
	      printf("Cannot open .cut file '%s'.\n", cutfile_name);
	      return;
	    }
	ReadHeader(cutfile, &header_size);

	/* open .lv file, skip header portion, get position of first record,
	   and calculate the record size */
	lvfile = fopen(lvfile_name, "rb");
	if(!lvfile)
	    {
	      printf("Cannot open .lv file '%s'.\n", lvfile_name);
	      return;
	    }
	ReadHeader(lvfile, &header_size);

	/* loop through .cut file reading each spike assignment */
	while(fscanf(cutfile, "%d", &cluster) != EOF)
	{
		if (cluster>12)
		{
			printf("cut2clustern.c: Cannot process more than 12 clusters.\n");
			return;
		}
	
		count = fread(&timestamp, sizeof(unsigned long), 1, lvfile);
		count += fread(&trial, sizeof(signed long), 1, lvfile);
		count += fread(&stim, sizeof(float), 1, lvfile);
		count += fread(&amp, sizeof(short), 128, lvfile);

		if ((cluster == 0) & (count == 131) & (timestamp == 0))
		{
			/* if null spike, write trial info to all cluster files */
			for (i=0; i < maxCluster; i++)
			{
				if (nspikes[i] == 0)
				{
					/* before writing the first spike of each cluster,
					   set up an output file */
					_strset(outfile_name, NULL);
					strncat(outfile_name, lvfile_name, strlen(lvfile_name)-3);
					strcat(outfile_name, ".cluster");
					_itoa(i+1, tmp, 10);
					strcat(outfile_name, tmp);
					clusterfile[i] = fopen(outfile_name, "wt");

					if (!clusterfile[i])
					{
						printf("Cannot open output file '%s'.\n", outfile_name);
						return;
					}
				}
				fprintf(clusterfile[i], "%d\t%d\t%g\t%lu\n", recno, trial, stim, timestamp);
				nspikes[i]++;
			}
		}

		if (cluster > 0 & count == 131)
		{
				if (nspikes[cluster-1] == 0)
				{
					/* before writing the first spike of each cluster,
					   set up an output file */
					_strset(outfile_name, NULL);
					strncat(outfile_name, lvfile_name, strlen(lvfile_name)-3);
					strcat(outfile_name, ".cluster");
					_itoa(cluster, tmp, 10);
					strcat(outfile_name, tmp);
					clusterfile[cluster-1] = fopen(outfile_name, "wt");
					if (!clusterfile[cluster-1])
					{
						printf("Cannot open output file '%s'.\n", outfile_name);
						return;
					}
				}
				fprintf(clusterfile[cluster-1], "%d\t%d\t%g\t%lu\n", recno, trial, stim, timestamp);
				nspikes[cluster-1]++;
		}

		recno++;
	}

	for (i=0; i<maxCluster; i++) {
		printf("cluster%d: %d spikes\n", i+1, nspikes[i]);
		fclose(clusterfile[i]);
	}
	fclose(cutfile);
	fclose(lvfile);

	return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
{ 
	char *cutfile_name, *lvfile_name;
    
    /* Check for proper number of arguments */
    
    if (nrhs != 2) { 
	mexErrMsgTxt("2 input arguments required."); 
    } else if (nlhs != 0) {
	mexErrMsgTxt("0 output arguments required."); 
    } 
    
    /* Assign values/pointers to the various parameters */ 
	cutfile_name = GetString(prhs[0]);
	lvfile_name = GetString(prhs[1]);

	/* Do the actual computations in a subroutine */
	Convert(cutfile_name, lvfile_name);

    return;
}
