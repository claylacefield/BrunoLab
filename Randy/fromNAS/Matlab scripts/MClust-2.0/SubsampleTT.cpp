/*-----------------------------
 * Subsample TT
 * 
 * inputs
 *    .tt filename
 *    subsample rate
 *    -sun / -nt
 *    -tt / -st / -se
 * 
 * ouputs
 *    new .tt filename
 *
 * writes out every nth timestamp and waveform
 * 
 * ADR 2000 with additional code from PL 1999
 * version 1.0 
 * RELEASED as part of MClust 2.0
 * See standard disclaimer in Contents.m
--------------------------------*/



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

const char *USAGE_STRING = "SubsampleTT -in <infile> -out <outfile> -skip <n> -sun -nt -tt -st -se\n";

enum {Tetrode, Stereotrode, SingleElectrode, NoTrode} input_type = NoTrode;
enum {NT, SUN, NoMachine} machine_type = NoMachine;


typedef struct _sun_spike_t {
  unsigned long tt;
  short waveform[128];
} sun_spike_t;

typedef struct _nt_tt_spike_t {
	char x[304];
} nt_tt_spike_t;

typedef struct _nt_st_spike_t {
	char x[176];
} nt_st_spike_t;

typedef struct _nt_se_spike_t {
	char x[112];
} nt_se_spike_t;

void CopyHeader(FILE *fpin, FILE *fpout)
{
  long curpos = ftell(fpin);
  char headerline[256];
  
  fgets(headerline, 255, fpin);
  if (strncmp(headerline, "%%BEGINHEADER", 13) == 0)
    {
	 /* saw begin header, print it out */
	 fprintf(fpout, "%s", headerline);

	 while (strncmp(headerline, "%%ENDHEADER",11) != 0)
	  {
       fgets(headerline, 255, fpin);
	   fprintf(fpout, "%s", headerline);
	  }
	}
  else
    fseek(fpin, curpos, SEEK_SET);
}

void Subsample_TT_sun(char *fnin, char *fnout, int skip)
{
  FILE *fpin, *fpout;
  sun_spike_t tmp;
  
  /* open file */
  fpin = fopen(fnin, "rb");
  if (!fpin) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};
  fpout = fopen(fnout, "wb");
  if (!fpout) {fprintf(stderr, "Unable to open file '%s'.\n", fnout); exit(1);};
  
  /* skip header */
  CopyHeader(fpin,fpout);
  long postHeaderPos = ftell(fpin);
  
  /* nSpikes? */
  fseek(fpin, 0, SEEK_END);
  long endPos = ftell(fpin);
  int nSpikes = int(floor((endPos - postHeaderPos) / sizeof(sun_spike_t)));
  fseek(fpin, postHeaderPos, SEEK_SET);
    
  /* read it */
  for (int iS = 0, iSkip = 0; iS < nSpikes; iS++, iSkip++)
    {
      fread(&tmp, sizeof(sun_spike_t), 1, fpin);
      if (iSkip % skip == 0)
	fwrite(&tmp, sizeof(sun_spike_t), 1, fpout);      
    }

  /* close file */
  fclose(fpin);
  fclose(fpout);
}

void Subsample_TT_nt(char *fnin, char *fnout, int skip)
{
  FILE *fpin, *fpout;
  nt_tt_spike_t tmp;
  
  /* open file */
  fpin = fopen(fnin, "rb");
  if (!fpin) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};
  fpout = fopen(fnout, "wb");
  if (!fpout) {fprintf(stderr, "Unable to open file '%s'.\n", fnout); exit(1);};
  
  /* no header */
  long postHeaderPos = ftell(fpin);

  /* nSpikes? */
  fseek(fpin, 0, SEEK_END);
  long endPos = ftell(fpin);
  int nSpikes = int(floor((endPos - postHeaderPos) / sizeof(nt_tt_spike_t)));
  fseek(fpin, postHeaderPos, SEEK_SET);
    
  /* read it */
  for (int iS = 0, iSkip = 0; iS < nSpikes; iS++, iSkip++)
    {
      fread(&tmp, sizeof(nt_tt_spike_t), 1, fpin);
      if (iSkip % skip == 0)
	fwrite(&tmp, sizeof(nt_tt_spike_t), 1, fpout);      
    }

  /* close file */
  fclose(fpin);
  fclose(fpout);
}

void Subsample_ST_nt(char *fnin, char *fnout, int skip)
{
  FILE *fpin, *fpout;
  nt_st_spike_t tmp;
  
  /* open file */
  fpin = fopen(fnin, "rb");
  if (!fpin) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};
  fpout = fopen(fnout, "wb");
  if (!fpout) {fprintf(stderr, "Unable to open file '%s'.\n", fnout); exit(1);};
  
  /* no header */
  long postHeaderPos = ftell(fpin);
  
  /* nSpikes? */
  fseek(fpin, 0, SEEK_END);
  long endPos = ftell(fpin);
  int nSpikes = int(floor((endPos - postHeaderPos) / sizeof(nt_st_spike_t)));
  fseek(fpin, postHeaderPos, SEEK_SET);
    
  /* read it */
  for (int iS = 0, iSkip = 0; iS < nSpikes; iS++, iSkip++)
    {
      fread(&tmp, sizeof(nt_st_spike_t), 1, fpin);
      if (iSkip % skip == 0)
	fwrite(&tmp, sizeof(nt_st_spike_t), 1, fpout);      
    }

  /* close file */
  fclose(fpin);
  fclose(fpout);
}

void Subsample_SE_nt(char *fnin, char *fnout, int skip)
{
  FILE *fpin, *fpout;
  nt_se_spike_t tmp;
  
  /* open file */
  fpin = fopen(fnin, "rb");
  if (!fpin) {fprintf(stderr, "Unable to open file '%s'.\n", fnin); exit(1);};
  fpout = fopen(fnout, "wb");
  if (!fpout) {fprintf(stderr, "Unable to open file '%s'.\n", fnout); exit(1);};
  
  /* skip header */
  long postHeaderPos = ftell(fpin);
  
  /* nSpikes? */
  fseek(fpin, 0, SEEK_END);
  long endPos = ftell(fpin);
  int nSpikes = int(floor((endPos - postHeaderPos) / sizeof(nt_se_spike_t)));
  fseek(fpin, postHeaderPos, SEEK_SET);
    
  /* read it */
  for (int iS = 0, iSkip = 0; iS < nSpikes; iS++, iSkip++)
    {
      fread(&tmp, sizeof(nt_se_spike_t), 1, fpin);
      if (iSkip % skip == 0)
	fwrite(&tmp, sizeof(nt_se_spike_t), 1, fpout);      
    }

  /* close file */
  fclose(fpin);
  fclose(fpout);
}


void main(int argc, char **argv)
{
  char *fnin = NULL, *fnout = NULL;
  int skip = 1;

  if (argc == 1)
    {fprintf(stderr, "%s\n", USAGE_STRING); exit(1);};
  
  // read cmd line
  while (*++argv)
    {
      if (strcmp(*argv, "-in") == 0)
		fnin = *++argv;
	  else if (strcmp(*argv, "-out") == 0)
	    fnout = *++argv;			
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
      else if (strcmp(*argv, "-skip") == 0)
		skip = atoi(*++argv);
      else if (strcmp(*argv, "-usage") == 0)
		{fprintf(stderr, USAGE_STRING); exit(1);}
    }

	if (!fnin)
		{fprintf(stderr, "Must supply -in flag.\n"); exit(1);}
	if (!fnout)
		{fprintf(stderr, "Must supply -out flag.\n"); exit(1);}

	switch (machine_type) {
		case SUN: 
			Subsample_TT_sun(fnin, fnout, skip);
			break;
		case NT: 
			switch (input_type) {
				case Tetrode:
					Subsample_TT_nt(fnin, fnout, skip);
					break;
				case Stereotrode:
					Subsample_ST_nt(fnin, fnout, skip);
					break;
				case SingleElectrode:
					Subsample_SE_nt(fnin, fnout, skip);
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
}

  
