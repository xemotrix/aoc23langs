#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define NPAIRS 4
#define TIME 0
#define DIST 1

FILE *f;

int get_num(char* line, int* len) {
    int off = 0;
    int num = 0;
    for (int i = 0; i < strlen(line); i++) {
        if (line[i] < '0' || line[i] > '9') {
            break;
        } 
        num = num * 10 + (line[i] - '0');
        off++;
    }
    *len = off;
    return num;
}

void parse_line(char* line, int nums[NPAIRS]) {
    int idx = 0;
    for (int i = 0; i < strlen(line); i++) {
        if (line[i] < '0' || line[i] > '9') {
            continue;
        }
        int len;
        int num = get_num(&line[i], &len);
        nums[idx] = num;
        idx++;
        i += len;
    }
}

double calc(int64_t dist, int64_t time) {
    double factor = sqrt(time*time - 4*dist);
    double delta = 0.0001;
    double r1 = ceil((time - factor) / 2.0 + delta);
    double r2 = floor((time + factor) / 2.0 - delta);
    double diff = r2 - r1 + 1;
    return diff;
}

void concat_nums(int nums[2][NPAIRS], int64_t out[2]) {
    out[TIME] = 0;
    out[DIST] = 0;
    int thres = 1;
    char time_str[32] = "";
    char dist_str[32] = "";

    for (int i = 0; i < NPAIRS; i++) {
        char auxt[32] = "";
        sprintf(auxt, "%d", nums[TIME][i]);
        strcat(time_str, auxt);
        char auxd[32] = "";
        sprintf(auxd, "%d", nums[DIST][i]);
        strcat(dist_str, auxd);
    }
    out[TIME] = atol(time_str);
    out[DIST] = atol(dist_str);
}

int main(void) {
    f = fopen("input.txt", "r");
    if (f == NULL) {
        printf("error opening file\n");
        return 1;
    }

    int races[2][NPAIRS];
    int idx = 0;
    char line[50];

    while(fgets(line, 50, f)) {
        parse_line(line, races[idx]);
        idx++;
    }
    fclose(f);

    int part1f = 1;
    for (int i = 0; i < NPAIRS; i++) {
        part1f *= calc(races[DIST][i], races[TIME][i]);
    }
    printf("Part 1: %d\n", part1f);

    int64_t part2_input[2];
    concat_nums(races, part2_input);
    double part2 = calc(part2_input[DIST], part2_input[TIME]);
    printf("Part 2: %lld\n", (int64_t)part2);

}
