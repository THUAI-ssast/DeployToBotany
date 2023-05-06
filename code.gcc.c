#include <errno.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define DEBUG 0

/*
    Usage: ./judge <prog1> <prog2> <log1> <log2>

    裁判程序将对局的报告输出到标准输出stdout，这些内容后续将传给播放器和负责计算选手积分的赛制脚本程序。

    将裁判日志输出到标准错误stderr，这些内容可供选手和管理员看到没有包含在报告中的一些细节。

    一般而言，只需使用 printf() 和 fprintf(stderr, …) 即可。
*/

#define BUFFER_SIZE 4096

int main(int argc, char *argv[]) {
#if DEBUG
    for (int i = 0; i < argc; i++) fprintf(stderr, "argv[%d] = %s\n", i, argv[i]);
    fflush(stderr);
#endif

    // Set the working directory to the program directory
    char *prog_dir = dirname(argv[0]);
    if (chdir(prog_dir) != 0) {
        fprintf(stderr, "Error: Failed to change working directory to %s\n", prog_dir);
        exit(1);
    }
#if DEBUG
    fprintf(stderr, "Current working directory: %s\n", prog_dir);
    fflush(stderr);
#endif

    // Generate the command to run the game. Start the game with 2 teams of AI
    char *command1 = argv[1];
    char *command2 = argv[2];
    char *pwsh_command = (char *)malloc(1024);
    sprintf(pwsh_command, "pwsh -Command \"./THUAI6.x86_64 \\\"%s\\\" \\\"%s\\\" -batchmode\"", command1, command2);
#if DEBUG
    fprintf(stderr, "pwsh_command = %s\n", pwsh_command);
    fflush(stderr);
#endif

    // Delete the old record.json
    int rm_exit_status = system("rm -f record.json");
    if (rm_exit_status != 0) {
        fprintf(stderr, "Error: Failed to delete record.json\n");
        exit(1);
    }

    // Run the game
    int pwsh_exit_status = system(pwsh_command);
    if (pwsh_exit_status != 0) {
        fprintf(stderr, "Error: Failed to run THUAI6.x86_64\n");
        exit(1);
    }

    // It'll generate a JSON file named record.json

    // Write the report from record.json to stdout
    FILE *fp;
    char buffer[BUFFER_SIZE];
    size_t n;

    fp = fopen("record.json", "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: %s\n", strerror(errno));
        exit(1);
    }

    while ((n = fread(buffer, 1, BUFFER_SIZE, fp)) > 0) {
        fwrite(buffer, 1, n, stdout);
    }

    fclose(fp);

    return 0;
}
