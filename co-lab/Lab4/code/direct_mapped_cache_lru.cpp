#include <iostream>
#include <cstdio>
#include <cmath>
#include <vector>

using namespace std;

int n_ways = 8;
const int K = 1024;
struct cache_content{
	bool v;
	unsigned int tag;
	int time_stamp;

};
vector<float> miss_rates;
vector<int> blk_sizes;
vector<int> cach_sizes;
void simulate(int cache_size, int block_size, char *filename){
	printf("cache: %d, block: %d\n",cache_size,block_size);
	int block_count = cache_size / block_size;
	int line = block_count / n_ways;
	int offset_bit = (int)log2(block_size);
	int index_bit = (int)log2(line);
	printf("cache line: %d\n",line);
	vector<vector<cache_content> > cache(line,vector<cache_content>(n_ways));
	
	for(int i = 0;i < line;i++)
		for(int j = 0; j < n_ways; j++){
			cache[i][j].v = false;
			cache[i][j].time_stamp = 0;
		}

	FILE *fp = fopen(filename, "r");  // read file
	int instr_count = 0,miss_count = 0;
	unsigned int tag, index, x;
	while(fscanf(fp, "%x", &x) != EOF){
		instr_count++;
		bool hit = false;
		index = (x >> (offset_bit)) & (line - 1);
		tag = x >> (index_bit + offset_bit);
		for(int i = 0;i < n_ways;i++)
			if(cache[index][i].v && cache[index][i].tag == tag){ // hit
				hit = true;
				cache[index][i].time_stamp = instr_count;
				break;
			}
		if(!hit){ // miss
			miss_count++;
			int lru = 0, longestT = cache[index][0].time_stamp;
			for(int i = 0;i < n_ways;i++){
				if(cache[index][i].time_stamp == -1){
					lru = i;
					break;
				}
				if(cache[index][i].time_stamp < longestT){
					lru = i;
					longestT = cache[index][i].time_stamp;
				}
			}
			cache[index][lru].v = true;
			cache[index][lru].tag = tag;
			cache[index][lru].time_stamp = instr_count;
		}
	}
	fclose(fp);
	
	printf("Miss Rate = %d / %d = %f\n",miss_count,instr_count,(float)miss_count / instr_count);
	
	cach_sizes.push_back(cache_size);
	blk_sizes.push_back(block_size);
	miss_rates.push_back((float)miss_count / instr_count);
}

int main(int argc, const char *argv[]){
	// Let us simulate 4KB cache with 16B blocks
	//simulate(4 * K, 16);
	char f1[] = "LU.txt",f2[] = "RADIX.txt";
	printf("%s:\n",f1);
	printf("%d ways\n",n_ways);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1){
			if(j != 64)
				continue;
			simulate(i * K, j, f1);
		}

	printf("%s:\n",f2);
	printf("%d ways\n",n_ways);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1){
			if(j != 64)
				continue;
			simulate(i * K, j, f2);
		}	
	
	FILE *fw = fopen("ans.txt", "w");
	for(int i = 0; i < miss_rates.size(); i++)
		fprintf(fw, "%d %d %f\n", cach_sizes[i], blk_sizes[i], miss_rates[i]);
	return 0;
}
