/*-----------------------------
 * SpikeCount
 * 
 * inputs
 *    SpikeCount -in <infile> -sun -nt -tt -st -se
 *    -in input files name
 *    -sun / - nt
 *    -tt / -st / -se
 * 
 * prints number of spikes in file
 * 
 * ADR 1999 
 * version 1.0
 *
 * RELEASED as part of MClust 2.0
 * See standard disclaimer in Contents.m
--------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

const char *USAGE_STRING = "SpikeCount -in <infile> -sun -nt -tt -st -se\n";

enum {Tetrode, Stereotrode, SingleElectrode, NoTrode} input_type = NoTrode;
enum {NT, SUN, NoMachine} machine_type = NoMachine;

/* --------------- SunOS ------------------ */

typedef struct _sun_spike_t {
  unsigned long tt;
  short waveform[128];
} sun_spike_t;

void SkipHeader(FILE *fp)
{
  long curpos = ftell(fp);
  char headerline[81];
  
  fgets(headerline, 80, fp);
  if (strncmp(headerline, "%%BEGINHEADER", 13) == 0)
    while (strncmp(headerline, "%%ENDHEADER",11) != 0)
      fgets(headerline, 80, fp);
  else
    fseek(fp, curpos, SEEK_SET);
}

int SpikeCount_TT_sun(char *fnin)
{
  FILE *fpin;
  
  /* open file */
  fpin = fopen(fnin, "rb");
  if (!fpin) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};
  
  /* skip header */
  SkipHeader(fpin);
  long postHeaderPos = ftell(fpin);
  
  /* nSpikes? */
  fseek(fpin, 0, SEEK_END);
  long endPos = ftell(fpin);
  int nSpikes = int(floor((endPos - postHeaderPos) / sizeof(sun_spike_t)));

  /* close file */
  fclose(fpin);
  return nSpikes;
}

/* ------------------------ NT TT -------------------- */
int SpikeCount_TT_NT(char *fnin)
	{
	  FILE *fp;
 
	 /* open file */
	 fp = fopen(fnin, "rb");
	 if (!fp) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};

	/* skip header and determine file record size */
	int recSize = 304; 
        
	/* get filesize */
	int postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
	fseek(fp,0,2);                     // goto end of file
	int nbytes = ftell(fp) - postHeaderPos;

	int nSpikes = nbytes/recSize; // no need to skip last record for NT_cheetah files
	
	/* cleanup */
	fclose(fp);	

	return nSpikes;
}

/* ------------------------ NT ST -------------------- */
int SpikeCount_ST_NT(char *fnin)
	{
	  FILE *fp;
  
	 /* open file */
	 fp = fopen(fnin, "rb");
	 if (!fp) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};

	/* skip header and determine file record size */
	int recSize = 176; 
        
	/* get filesize */
	int postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
	fseek(fp,0,2);                     // goto end of file
	int nbytes = ftell(fp) - postHeaderPos;

	int nSpikes = nbytes/recSize; // no need to skip last record for NT_cheetah files
	
	/* cleanup */
	fclose(fp);	

	return nSpikes;
}

/* ------------------------ NT SE -------------------- */
int SpikeCount_SE_NT(char *fnin)
	{
	  FILE *fp;
  
	 /* open file */
	 fp = fopen(fnin, "rb");
	 if (!fp) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};

	/* skip header and determine file record size */
	int recSize = 112; 
        
	/* get filesize */
	int postHeaderPos = ftell(fp);     // beginnig of file after header (if any)
	fseek(fp,0,2);                     // goto end of file
	int nbytes = ftell(fp) - postHeaderPos;

	int nSpikes = nbytes/recSize; // no need to skip last record for NT_cheetah files
	
	/* cleanup */
	fclose(fp);	

	return nSpikes;
};

/* -------------------------- main ----------------------- */

void main(int argc, char **argv)
{
  char *fnin = NULL, *fnout = NULL;
  int nSpikes = 0;

  if (argc == 1)
    {fprintf(stderr, "%s\n", USAGE_STRING); exit(1);};
  
  // read cmd line
  while (*++argv)
    {
      if (strcmp(*argv, "-in") == 0)
		fnin = *++argv;	
	  else if (strcmp(*argv, "-sun") == 0)
		machine_type = SUN;
	  else if (strcmp(*argv, "-nt") == 0)
		machine_type = NT;
	  else if (strcmp(*argv, "-tt") == 0)
		input_type = Tetrode;
	  else if (strcmp(*argv, "-st") == 0)
	    input_type = Stereotrode;
	  else if (strcmp(*argv, "-se") == 0)
	    input_type = SingleElectrode;
      else if (strcmp(*argv, "-usage") == 0)
	{fprintf(stderr, USAGE_STRING); exit(1);}
    }

	if (!fnin)
		{fprintf(stderr, "Must supply -in flag.\n"); exit(1);}

	switch (machine_type) {
		case SUN: 
			nSpikes = SpikeCount_TT_sun(fnin);
			break;
		case NT: 
			switch (input_type) {
				case Tetrode:
					nSpikes = SpikeCount_TT_NT(fnin);
					break;
				case Stereotrode:
					nSpikes = SpikeCount_ST_NT(fnin);
					break;
				case SingleElectrode:
					nSpikes = SpikeCount_SE_NT(fnin);
					break;
				default:
					fprintf(stderr, "Must supply -tt/-st/-se flag.\n"); 
					exit(1);
			};
			break;
		default:
			fprintf(stderr, "Must supply -sun/-nt flag.\n");
			exit(1);
		};


  printf("File %s has %d spikes.\n", fnin, nSpikes);
}

  
