// Author: 0716085賴品樺, 0716316洪珩均
#include <iostream>
#include <vector>
#include <cstdio>

using namespace std;

struct TestData{
	int ADDR0, ADDR1, ADDR2, m, n, p;
	vector<vector<int> > A, B;
};
void ReadFile(const char *filename, TestData & td);
int matmul(vector<vector<int> > & A, vector<vector<int> > & B, vector<vector<int> > & C, int baseA, int baseB, int baseC);
vector<int> MEMAccess;
int main(int argc, char const *argv[]){
	if(argc != 3){
		printf("Usage: ./simulate_caches [input_filename] [output_filename]");
		exit(0);
	}
	TestData td;
	ReadFile(argv[1], td);
	/*
	printf("%x %x %x ", td.ADDR0, td.ADDR1, td.ADDR2);
	printf("%d %d %d\n", td.m, td.n, td.p);
	for(int i = 0;i < td.m;i++){
		for(int j = 0;j < td.n;j++)
			printf("%d ", td.A[i][j]);
		printf("\n");
	}
	for(int i = 0;i < td.n;i++){
		for(int j = 0;j < td.p;j++)
			printf("%d ", td.B[i][j]);
		printf("\n");
	}
	*/
	vector<vector<int> > C(td.m, vector<int>(td.p, 0));
	int ProgExeCycle = matmul(td.A, td.B, C, td.ADDR0, td.ADDR1, td.ADDR2);
	for(int i = 0;i < td.m;i++){
		for(int j = 0;j < td.p;j++)
			printf("%d ", C[i][j]);
		printf("\n");
	}
	printf("%d\n",ProgExeCycle);
	return 0;
}
void ReadFile(const char *filename, TestData & td){
	FILE *fp = fopen(filename, "r");
	fscanf(fp, "%x%x%x", &td.ADDR0, &td.ADDR1, &td.ADDR2);
	fscanf(fp, "%d%d%d", &td.m, &td.n, &td.p);
	td.A = vector<vector<int> >(td.m, vector<int>(td.n));
	td.B = vector<vector<int> >(td.n, vector<int>(td.p));
	for(int i = 0;i < td.m;i++)
		for(int j = 0;j < td.n;j++)
			fscanf(fp, "%d", &td.A[i][j]);
	for(int i = 0;i < td.n;i++)
		for(int j = 0;j < td.p;j++)
			fscanf(fp, "%d", &td.B[i][j]);
	fclose(fp);
}
int matmul(vector<vector<int> > & A, vector<vector<int> > & B, vector<vector<int> > & C, int baseA, int baseB, int baseC){
	int ProgExeCycle = 0;
	vector<int> reg(32);
	//	$24 = A[]base, $25 = B[]base, $26 = C[]base
	//	$21 = m, $22 = n, $23 = p
	//	$3 = i, $4 = j, $5 = k
	reg[0] = 0; // $0 
	reg[21] = A.size(); // m
	reg[22] = B.size(); // n
	reg[23] = B[0].size(); // p
	reg[24] = baseA; 
	reg[25] = baseB;
	reg[26] = baseC;
	
	// matmul:
	reg[1] = reg[0] + 4; ProgExeCycle++; // addi $1, $0, 4
	reg[3] = reg[0] + 0; ProgExeCycle++; // addi $3, $0, 0
	while(true){ // loop_i:
		reg[6] = reg[3] < reg[21]; ProgExeCycle++; // slt $6, $3, $21
		// beq $6, $0, exit
		ProgExeCycle++;
		if(reg[6] == reg[0])
			break;

		reg[4] = reg[0] + 0; ProgExeCycle++; // addi $4, $0, 0
		while(true){ // loop_j:
			reg[6] = reg[4] < reg[23]; ProgExeCycle++; // slt $6, $4, $23
			// beq $6, $0, end_j
			ProgExeCycle++;
			if(reg[6] == reg[0])
				break;

			reg[5] = reg[0] + 0; ProgExeCycle++; // addi $5, $0, 0
			while(true){ // loop_k:
				reg[6] = reg[5] < reg[22]; ProgExeCycle++; // slt $6, $5, $22
				// beq $6, $0, end_k
				ProgExeCycle++;
				if(reg[6] == reg[0])
					break;
				reg[7] = reg[3] * reg[23]; ProgExeCycle++; // mul $7, $3, $23 // i * p
				reg[8] = reg[7] + reg[4]; ProgExeCycle++; // addu $8, $7, $4 // i * p + j
				reg[8] = reg[8] * reg[1]; ProgExeCycle++; // mul $8, $8, $1 // 4 * (i * p + j)
				reg[9] = reg[8] + reg[26]; ProgExeCycle++; // addu $9, $8, $26 // 4 * (i * p + j) + baseC
				reg[10] = C[reg[3]][reg[4]]; ProgExeCycle++; // lw $10, 0($9) !!!!! load C[i][j] !!!!!

				reg[11] = reg[3] * reg[22]; ProgExeCycle++; // mul $11, $3, $22 // i * n
				reg[12] = reg[11] + reg[5]; ProgExeCycle++; // addu $12, $11, $5 // i * n + k
				reg[12] = reg[12] * reg[1]; ProgExeCycle++; // mul $12, $12, $1 // 4 * (i * n + k)
				reg[13] = reg[12] + reg[24]; ProgExeCycle++; // addu $13, $12, $24 // 4 * (i * n + k) + baseA
				reg[14] = A[reg[3]][reg[5]]; ProgExeCycle++; // lw $14, 0($13) !!!!! load A[i][k] !!!!!

				reg[15] = reg[5] * reg[23]; ProgExeCycle++; // mul $15, $5, $23 // k * p
				reg[16] = reg[15] + reg[4]; ProgExeCycle++; // addu $16, $15, $4 // k * p + j
				reg[16] = reg[16] * reg[1]; ProgExeCycle++; // mul $16, $16, $1 // 4 * (k * p + j)
				reg[17] = reg[16] + reg[25]; ProgExeCycle++; // addu $17, $16, $25 // 4 * (k * p + j) + baseB
				reg[18] = B[reg[5]][reg[4]]; ProgExeCycle++; // lw $18, 0($17) !!!!! load B[k][j] !!!!!

				reg[19] = reg[18] * reg[14]; ProgExeCycle++; // mul $19, $18, $14 // val(A[i][k]) * val(B[k][j])
				reg[20] = reg[10] + reg[19]; ProgExeCycle++; // addu $20, $10, $19 // val(C[i][j]) + val(A[i][k]) * val(B[k][j])
				C[reg[3]][reg[4]] = reg[20]; ProgExeCycle++; // sw $20, 0($9) // !!!!! store C[i][j] !!!!!
				reg[5] = reg[5] + 1; ProgExeCycle++; // addi $5, $5, 1 // k++
				ProgExeCycle++; // j loop_k
			}
			// end_k:
			reg[4] = reg[4] + 1; ProgExeCycle++; // addi $4, $4, 1 // j++
			ProgExeCycle++; // j loop_j
		}
		// end_j:
		reg[3] = reg[3] + 1; ProgExeCycle++; // addi $3, $3, 1 // i++
		ProgExeCycle++; // j loop_i
	}
	ProgExeCycle++; // exit:

	return ProgExeCycle;
}
