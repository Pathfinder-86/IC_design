#include "bits/stdc++.h"
using namespace std;
int main(int argc,char *agrv[])
{
    srand(time(NULL));
    string s1(agrv[1]);
    int pattern_num = stoi(s1);    
    vector<vector<int>> cost(8,vector<int> (8,0));
    vector<int> cur_job = {0,1,2,3,4,5,6,7},best_job;
    int cur_cost,best_cost = 1023;
    ofstream out_file("input.txt"),out_file2("output.txt");
    out_file<<pattern_num<<endl;
    while(pattern_num--)
    {
        for(int i=0;i<8;i++)
        {
            for(int j=0;j<8;j++)
            {
                int num = rand()%128;
                out_file<<num<<" ";
                cost[i][j] = num;
            }
            out_file<<endl;
        }
        do
        {
            cur_cost = 0;
            for(int i=0;i<8;i++)
                cur_cost += cost[i][cur_job[i]];
            if(cur_cost<best_cost)
            {
                best_job = cur_job;
                best_cost = cur_cost;
            }            
        } while (next_permutation(cur_job.begin(),cur_job.end()));        
        out_file2<<best_cost<<" ";
        for(auto i : best_job)
            out_file2<<(i+1)<<" ";                
        out_file2<<endl;
        best_cost = 1023;
        cur_job = {0,1,2,3,4,5,6,7};
    }    
    out_file.close();
    out_file2.close();
    return 0;
}