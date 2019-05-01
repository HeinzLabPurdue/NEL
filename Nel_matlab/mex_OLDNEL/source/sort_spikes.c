#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////
// DONT FORGET TO ADD MAX_INT TO THE END OF trg !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////
void normalize_spikes(double *trg,int trg_len, double *spk, int spk_len, int base_trig_count, 
					  double *seq,double *times)
{
	int trg_pos = 0;
	int spk_pos = 0;

	for (spk_pos = 0; spk_pos < spk_len; spk_pos++) {
	   while (spk[spk_pos] >= trg[trg_pos])
		  trg_pos++;
	   
	   trg_pos--;
	   times[spk_pos] = spk[spk_pos] - trg[trg_pos];
	   seq[spk_pos] = base_trig_count + trg_pos;  // -1 +1;
	}
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

	int trg_len = mxGetN(prhs[0])*mxGetM(prhs[0]);
	int spk_len = mxGetN(prhs[1])*mxGetM(prhs[1]);
	int base_trig_count  = (int) floor(mxGetScalar(prhs[2])+0.5);
	double *trg = mxGetPr(prhs[0]);	
	double *spk = mxGetPr(prhs[1]);
	double *seq, *times;
	
	plhs[0] = mxCreateDoubleMatrix(spk_len,1, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(spk_len,1, mxREAL);

	/*  create a C pointer to a copy of the output matrix */
	seq = mxGetPr(plhs[0]);
 	times = mxGetPr(plhs[1]);

	normalize_spikes(trg,trg_len, spk,spk_len, base_trig_count, seq,times);
}
