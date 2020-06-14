#include <iostream>
#include <cstdio>
#include <cmath>
#include <vector>
#include <climits>

using namespace std;
/*
vector<float> miss_rates;
vector<int> blk_sizes;
vector<int> cach_sizes;
*/

int n_ways = 2; // 2-ways

struct cache_content{
	bool v;
	unsigned int tag;
	int time_stamp;

};

const int K = 1024;

void simulate(int cache_size, int block_size,char *filename){
	printf("cache: %d, block: %d\n",cache_size,block_size);
	unsigned int tag, index, x;
	int offset_bit = (int)log2(block_size);
	int index_bit = (int)log2(cache_size / block_size);
	int line = cache_size >> (offset_bit);


	vector<vector<cache_content> > cache(line,vector<cache_content>(n_ways));
	
    printf("cache line: %d\n",line);

    for(int i = 0;i < line;i++)
		for(int j = 0; j < n_ways; j++){
        	cache[i][j].v = false;
        	cache[i][j].time_stamp = 0;
		}

    FILE *fp = fopen(filename, "r");  // read file
	int instr_count = 0,miss_count = 0;

	while(fscanf(fp, "%x", &x) != EOF){
        bool hit = false;
		index = (x >> offset_bit) & (line - 1);
		tag = x >> (index_bit + offset_bit);
        //printf("data = %x\tindex = %d\ttag = %d\n",x,index,tag);
		int loc = 0,diff = INT_MIN;
		for(int i = 0;i < n_ways;i++){
			if(!cache[index][i].v || (cache[index][i].v && cache[index][i].tag != tag)){
				if((instr_count - cache[index][i].time_stamp) > diff){
					diff = instr_count - cache[index][i].time_stamp;
					loc = i;
				}
            }
            else if(cache[index][i].v && cache[index][i].tag == tag){
                hit = true;
                cache[index][i].time_stamp = instr_count;
                break;
            }
		}
		if(!hit){
            cache[index][loc].v = true;  // miss
			cache[index][loc].tag = tag;
			cache[index][loc].time_stamp = instr_count;
			miss_count++;
		}
		instr_count++;
	}
	fclose(fp);
	
	printf("Miss Rate = %d / %d = %f\n",miss_count,instr_count,(float)miss_count / instr_count);
	/*
	cach_sizes.push_back(cache_size);
    blk_sizes.push_back(block_size);
    miss_rates.push_back((float)miss_count / instr_count);
    */
}

int main()
{
	// Let us simulate 4KB cache with 16B blocks
	//simulate(4 * K, 16);
	char f1[] = "LU.txt",f2[] = "RADIX.txt";
	printf("%s:\n",f1);
	printf("%d ways\n",n_ways);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1){
			if(j != 64)
				continue;
			simulate(i * K,j,f1);
		}
	printf("%s:\n",f2);
	printf("%d ways\n",n_ways);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1){
			if(j != 64)
				continue;
			simulate(i * K,j,f2);
		}	
	/*
	FILE *fw = fopen("ans.txt", "w");
	for(int i = 0; i < miss_rates.size(); i++)
        fprintf(fw, "%d %d %f\n", cach_sizes[i], blk_sizes[i], miss_rates[i]);
	*/
}
