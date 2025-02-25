@echo off
REM 运行第一条 Docker 命令
echo 正在运行 FastQC ...
docker run --rm -v D:\Work\analyse\data:/data -v D:\Work\analyse\results:/results bio_fastqc
if %errorlevel% neq 0 (
    echo bio_fastqc FastQC 运行失败！
    pause
    exit /b %errorlevel%
)

REM 运行第二条 Docker 命令
echo 正在运行 SPAdes ...
docker run --rm -v D:\Work\analyse\data:/data -v D:\Work\analyse\results:/results -v D:\Work\analyse\scripts:/scripts bio_spades /scripts/spades.sh
if %errorlevel% neq 0 (
    echo bio_spades SPAdes 运行失败！
    pause
    exit /b %errorlevel%
)

echo 脚本运行成功！
pause