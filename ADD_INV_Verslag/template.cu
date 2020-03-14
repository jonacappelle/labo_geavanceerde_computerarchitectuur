////////////////////////////////////////////////////////////////////////////////
// ADD / INVERT -- Jona Cappelle -- Jonas Bolle
////////////////////////////////////////////////////////////////////////////////

// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// includes CUDA
#include <cuda_runtime.h>

// includes, project
#include <helper_cuda.h>
#include <helper_functions.h> // helper functions for SDK examples

// own includes
#include "iostream"
#include "cstdlib"
#include "time.h"	// timing on cpu

extern "C"
#define ARRAYSIZE 100000000 // Is also the number of threads that will be used

////////////////////////////////////////////////////////////////////////////////
// SELECT GPU - CPU TIMING
// #define GPU
// #define CPU
////////////////////////////////////////////////////////////////////////////////
// RUN ADD - INV
// #define ADD
// #define INV
////////////////////////////////////////////////////////////////////////////////

// Helper function
void init_array(int *a)
{
	for (int i = 0; i < ARRAYSIZE; i++)
	{
		a[i] = i;
	}
}

////////////////////////////////////////////////////////////////////////////////
// KERNEL ADD
////////////////////////////////////////////////////////////////////////////////
int BLOCKSIZE;

// GPU
__global__ void add(int *a, int *b, int *out)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < ARRAYSIZE)
	{
		out[idx] = a[idx] + b[idx];
	}
}

// CPU
void cpu_add(int *a, int *b, int *out)
{
	for (int i = 0; i < ARRAYSIZE; i++)
	{
		out[i] = a[i] + b[i];
	}
}

////////////////////////////////////////////////////////////////////////////////
// KERNEL INVERT
////////////////////////////////////////////////////////////////////////////////

// GPU
__global__ void invert(int *a, int *out)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < ARRAYSIZE)
	{
		out[idx] = a[ARRAYSIZE - 1 - idx];
	}
}

// CPU
void cpu_invert(int *a, int *out)
{
	for (int i = 0; i < ARRAYSIZE; i++)
	{
		out[i] = a[ARRAYSIZE - 1 - i];
	}
}

////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main()
{
	// declare variables
	int *a_host, *b_host, *out_host;
	int *a_dev, *b_dev, *out_dev;

	// allocate arrays on host
	a_host = (int *)malloc(ARRAYSIZE * sizeof(int));
	b_host = (int *)malloc(ARRAYSIZE * sizeof(int));
	out_host = (int *)malloc(ARRAYSIZE * sizeof(int));

	// initialize arrays with zeros
	init_array(a_host);
	init_array(b_host);

	// allocate arrays on device
	cudaMalloc((void **)&a_dev, ARRAYSIZE * sizeof(int));
	cudaMalloc((void **)&b_dev, ARRAYSIZE * sizeof(int));
	cudaMalloc((void **)&out_dev, ARRAYSIZE * sizeof(int));

	// Record time on GPU with cuda events 
#ifdef GPU
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
#endif

	// Timer on CPU
#ifdef CPU
	clock_t start, end;
	double cpu_time_used;
#endif

	// Initialize data file where the timing results will be stored
	FILE *f = fopen("data.csv", "w");

#ifdef GPU
	for (int BLOCKSIZE = 1; BLOCKSIZE < 300; BLOCKSIZE++)
	{
#endif

#ifdef CPU
		float millis = 0;
#endif

		// Calculate amount of blocks needed
		int nBlocks = ARRAYSIZE / BLOCKSIZE + (ARRAYSIZE % BLOCKSIZE == 0 ? 0 : 1);
		printf("Nblocks: %i", nBlocks);

		// Start timer
#ifdef CPU
		StopWatchInterface *timer = 0;
		sdkCreateTimer(&timer);
		sdkStartTimer(&timer);
#endif

#ifdef GPU // Start cuda event on GPU
		cudaEventRecord(start);
#endif

		//Step 1: Copy data to GPU memory
		cudaMemcpy(a_dev, a_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(b_dev, b_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(out_dev, out_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);

		////////////////////////////////////////////////////////////////////////////////
		// GPU -- define ADD - INV to run
		////////////////////////////////////////////////////////////////////////////////
#ifdef ADD && GPU
		add<<<nBlocks, BLOCKSIZE>>>(a_dev, b_dev, out_dev);
#endif
#ifdef INV && GPU
		invert <<< nBlocks, BLOCKSIZE >>> ( a_dev, out_dev );
#endif

#ifdef GPU // Stop GPU event timer
		cudaEventRecord(stop);
#endif

		////////////////////////////////////////////////////////////////////////////////
		// CPU -- define ADD - INV to run
		////////////////////////////////////////////////////////////////////////////////
#ifdef CPU // CPU timer
		start = clock();
#endif

#ifdef ADD && CPU
		cpu_add( a_host, b_host, out_host);
#endif
#ifdef INV && CPU
		cpu_invert ( a_host, out_host );
#endif

#ifdef CPU
		end = clock();
		cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
		printf("%f", cpu_time_used);
#endif

		//Step 4: Retrieve result
		cudaMemcpy(a_host, a_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(b_host, b_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(out_host, out_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);

#ifdef GPU
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&millis, start, stop);
#endif

#ifdef CPU	// Stop timer
		sdkStopTimer(&timer);
#endif

		// Print time to console
#ifdef CPU
		printf("Processing time: %f (ms)\n", sdkGetTimerValue(&timer));
#endif
#ifdef GPU
		printf("Processing time: %f (ms)\n", millis);
#endif

		// Write timing results to file
#ifdef CPU
		fprintf(f, "%f\n", sdkGetTimerValue(&timer));
#endif
#ifdef GPU
		fprintf(f, "%d,%f\n", BLOCKSIZE, millis);
#endif

#ifdef CPU	// Verwijder timer
		sdkDeleteTimer(&timer);
#endif

#ifdef GPU
	} //End for
#endif

	// Close the file
	fclose(f);

	// Free up the used memory
	free(a_host);
	free(b_host);
	free(out_host);

#ifdef GPU // Free up the cuda memory
	cudaFree(a_dev);
	cudaFree(b_dev);
	cudaFree(out_dev);
#endif

	return 0;
}
