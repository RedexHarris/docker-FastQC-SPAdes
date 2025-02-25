# 通过 docker 运行 FastQC 和 SPAdes 进行简单无参测序分析的小项目

## 项目结构
```
* X:\\analyse\\
    * data\\    	\# 存放输入文件
        * XJ_S1_L001_R1.fastq.gz
        * XJ_S1_L001_R2.fastq.gz
    * result\\  	\# 存放输出文件
        * fastqc\\
        * spades\\
    * scripts\\ 	\# 存放镜像脚本文件
        * fastqc.sh
        * spades.sh
    * dockerfile_fastqc		**\# dockerfile没有扩展名**
    * dockerfile_spades
```



## dockerfile的编写
#### dockerfile_fastqc
```dockerfile
FROM staphb/fastqc:0.11.9                   # 基础镜像
WORKDIR /data                               # 设置工作目录
COPY scripts/fastqc.sh /scripts/fastqc.sh   # 将脚本文件复制到容器中
RUN chmod +x /scripts/fastqc.sh             # 添加执行权限
CMD ["/scripts/fastqc.sh"]                  # 设置默认命令
```
#### dockerfile_spades
```dockerfile
FROM staphb/spades:3.15.5
WORKDIR /data
COPY scripts/spades.sh /scripts/spades.sh
RUN chmod +x /scripts/spades.sh
CMD ["/scripts/spades.sh"]
```



## sh文件的编写
#### fastqc.sh
```sh
#!/bin/bash										# 定义主函数

DATA_DIR="/data"
RESULTS_DIR="/results/fastqc"					# 转换相对路径

echo "=== 运行FastQC质控 ==="
fastqc ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
       ${DATA_DIR}/XJ_S1_L001_R2.fastq.gz \
       -o ${RESULTS_DIR}						# 执行，参考 https://github.com/s-andrews/FastQC

echo "=== FastQC结果 ==="
ls -lh ${RESULT_DIR}							# 验证输出文件的存在
```
#### spades.sh
```sh
#!/bin/bash

DATA_DIR="/data"
RESULTS_DIR="/results/spades"

echo "=== 运行 SPAdes 拼接 ==="
spades.py --isolate \
          --pe1-1 ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
          --pe1-2 ${DATA_DIR}/XJ_S1_L001_R2.fastq.gz \
          -o ${RESULTS_DIR} \
          -t 4									# 参考 https://github.com/ablab/spades

echo "=== SPAdes 结果 ==="
ls -lh ${RESULTS_DIR}/contigs.fasta
```
***注意确保sh文件是LF编码而不是CRLF编码！！***

### 语法
#### FastQC
```
fastqc [-o output dir] [--(no)extract] [-f fastq|bam|sam] [-c containment file] seqfile1 ... seqfileN

-o(--outdir) FastQC生成的报告文件的储存路径，生成的报告的文件名是根据输入文件名而定
-f(--format) 指定输入文件的格式
--extract 默认会将报告打包成一个压缩文件，这个参数是让程序不打包
-t(--threads) 选择程序运行的线程数，每个线程数会占用250MB内存
--min_length 设置序列的最小长度，≥最长read的长度
-c(--contaminants) 污染物的选项，输入的是一个文件，格式是`Name [Tab] Sequence`，里面是可能的污染序列，如果有这个选项，FastQC会在计算时评估污染的情况，并在统计的时候进行分析
-a(--adapters) 输入一个文件，格式是`Name [Tab] Sequence`，储存的是测序的adapter信息，如果不输入，目前版本的FastQC就按照通用引物来评估序列有没有adapter的残留
-q(--quiet) 安静运行模式，一般不设置这个参数的时候，程序会实时报告运行情况
```
#### SPAdes
```
#查看帮助文档
spades.py -h

###基本选项： ###################################
-o <output_dir> 存储所有结果文件的目录（必选） 

--isolate 对于高覆盖度的孤立株和多细胞数据，强烈建议使用此标志 
--sc 对于MDA（单细胞）数据，必须使用此标志 
--meta 对于宏基因组数据，必须使用此标志 
--bio 对于生物合成SPAdes模式，必须使用此标志 
--corona 对于冠状SPAdes模式，必须使用此标志 
--rna 对于RNA测序数据，必须使用此标志 #如果数据不为单细胞,宏基因组,生物合成或者RNA数据,不使用指定参数的功能

--plasmid 运行质粒SPAdes流程以检测质粒 
--metaviral 运行元病毒SPAdes流程以检测病毒 
--metaplasmid 运行元基因组数据中的质粒SPAdes流程以检测质粒（等同于 --meta --plasmid） 
--rnaviral 此标志启用来自RNA测序数据的病毒组装模块 
--iontorrent 对于IonTorrent数据，必须使用此标志 
--test 在玩具数据集上运行SPAdes 
-h, --help 打印此用法消息 
-v, --version 打印版本

###输入数据： ###################################
  --12 <filename>             包含交错的前向和反向配对末端读取的文件
  -1 <filename>               包含前向配对末端读取的文件
  -2 <filename>               包含反向配对末端读取的文件
  -s <filename>               包含未配对读取的文件#常用的是前四个
  --merged <filename>         包含合并的前向和反向配对末端读取的文件
  --pe-12 <#> <filename>      包含配对库编号为<#>的交错读取文件。旧的不推荐使用的语法是 -pe<#>-12 <filename>
  --pe-1 <#> <filename>       包含配对库编号为<#>的前向读取文件。旧的不推荐使用的语法是 -pe<#>-1 <filename>
  --pe-2 <#> <filename>       包含配对库编号为<#>的反向读取文件。旧的不推荐使用的语法是 -pe<#>-2 <filename>
  --pe-s <#> <filename>       包含配对库编号为<#>的未配对读取文件。旧的不推荐使用的语法是 -pe<#>-s <filename>
  --pe-m <#> <filename>       包含配对库编号为<#>的合并读取文件。旧的不推荐使用的语法是 -pe<#>-m <filename>
  --pe-or <#> <or>            配对库编号为<#>的读取方向(<or> = fr, rf, ff)。旧的不推荐使用的语法是 -pe<#>-<or>
  --s <#> <filename>          单读取库编号为<#>的未配对读取文件。旧的不推荐使用的语法是 --s<#> <filename>
  --mp-12 <#> <filename>      包含mate-pair库编号为<#>的交错读取文件。旧的不推荐使用的语法是 -mp<#>-12 <filename>
  --mp-1 <#> <filename>       包含mate-pair库编号为<#>的前向读取文件。旧的不推荐使用的语法是 -mp<#>-1 <filename>
  --mp-2 <#> <filename>       包含mate-pair库编号为<#>的反向读取文件。旧的不推荐使用的语法是 -mp<#>-2 <filename>
  --mp-s <#> <filename>       包含mate-pair库编号为<#>的未配对读取文件。旧的不推荐使用的语法是 -mp<#>-s <filename>
  --mp-or <#> <or>            mate-pair库编号为<#>的读取方向(<or> = fr, rf, ff)。旧的不推荐使用的语法是 -mp<#>-<or>
  --hqmp-12 <#> <filename>    包含高质量mate-pair库编号为<#>的交错读取文件。旧的不推荐使用的语法是 -hqmp<#>-12 <filename>
  --hqmp-1 <#> <filename>     包含高质量mate-pair库编号为<#>的前向读取文件。旧的不推荐使用的语法是 -hqmp<#>-1 <filename>
  --hqmp-2 <#> <filename>     包含高质量mate-pair库编号为<#>的反向读取文件。旧的不推荐使用的语法是 -hqmp<#>-2 <filename>
  --hqmp-s <#> <filename>     包含高质量mate-pair库编号为<#>的未配对读取文件。旧的不推荐使用的语法是 -hqmp<#>-s <filename>
  --hqmp-or <#> <or>          高质量mate-pair库编号为<#>的读取方向(<or> = fr, rf, ff)。旧的不推荐使用的语法是 -hqmp<#>-<or>
  --sanger <filename>         包含Sanger读取的文件
  --pacbio <filename>         包含PacBio读取的文件
  --nanopore <filename>       包含Nanopore读取的文件
  --trusted-contigs <filename>包含可信contigs的文件
  --untrusted-contigs <filename>包含不可信contigs的文件

###流程选项： ###################################
  --only-error-correction     仅运行读取错误校正（不进行组装）
  --only-assembler            仅运行组装（不进行读取错误校正）
  --careful                   尝试减少不匹配和短插入缺失的数量
  --checkpoints <last or all> 保存中间检查点（'last'，'all'）
  --continue                  从上次可用的检查点继续运行（只应指定 -o）
  --restart-from <cp>         使用更新的选项从指定的检查点重新启动运行（'ec'，'as'，'k<int>'，'mc'，'last'）
  --disable-gzip-output       强制错误校正不压缩校正后的读取
  --disable-rr                禁用组装的重复解决阶段

###高级选项： ###################################
  --dataset <filename>        以YAML格式描述数据集的文件
  -t <int>, --threads <int>   线程数。[默认值：16]
  -m <int>, --memory <int>    SPAdes的RAM限制，单位为Gb（如果超出限制则终止）。[默认值：250]
  --tmp-dir <dirname>         临时文件目录。[默认值：<output_dir>/tmp]
  -k <int> [<int> ...]        k-mer大小的列表（必须为奇数且小于128）[默认值：'auto']
  --cov-cutoff <float>        覆盖范围截断值（正浮点数，'auto'或'off'） [默认值：'off']
  --phred-offset <33 or 64>   输入读取中的PHRED质量偏移（33或64），[默认值：自动检测]
  --custom-hmms <dirname>     包含替换默认hmms的自定义hmms的目录， [默认值：无]
```

### 如果是单端测序
#### FastQC
```sh
#!/bin/bash										

DATA_DIR="/data"
RESULTS_DIR="/results/fastqc"					

echo "=== 运行FastQC质控 ==="
fastqc ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
       -o ${RESULTS_DIR}						

echo "=== FastQC结果 ==="
ls -lh ${RESULT_DIR}							
```
#### SPAdes
```sh
#!/bin/bash

DATA_DIR="/data"
RESULTS_DIR="/results/spades"

echo "=== 运行 SPAdes 拼接 ==="
spades.py --isolate \
          -s ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
          -o ${RESULTS_DIR} \
          -t 4									

echo "=== SPAdes 结果 ==="
ls -lh ${RESULTS_DIR}/contigs.fasta
```



## 构建docker镜像
```powershell
docker build -t bio_fastqc -f dockerfile_fastqc
docker build -t bio_spades -f dockerfile_spades
```
`-t`（`--tag`）：用于命名镜像并添加标签，格式为`<name>:<tag>`，如`fastqc:latest`
`-f`（`--file`）：指定自定义dockerfile的位置，而非默认位置当前目录下的dockerfile



## 在容器中运行sh文件开始分析
```powershell
docker run --rm -v X:\analyse\data:/data -v X:\analyse\results:/results bio_fastqc
docker run --rm -v X:\analyse\data:/data -v X:\analyse\results:/results -v X:\analyse\scripts:/scripts bio_spades /scripts/spades.sh
```
`--rm`：在容器退出后自动删除该容器
`-v`（`--volume`）：挂载主机目录到容器中，格式为：`<host_directory>:<container_directory>`


#### 手动启动sh文件的方法
```powershell
docker run --rm -v X:\analyse\data:/data -v X:\analyse\results:/results -v X:\analyse\scripts:/scripts -it bio_spades sh
sh /scripts/spades.sh
```
`-it`是`-i`和`-t`的组合
`-i`（`--interactive`）：保持标准输入（STDIN）打开，允许与容器进行交互
`-t`（`--tty`）：为容器分配一个伪终端（pseudo-TTY），通常用于使容器的输出更友好，支持终端如命令行编辑
`-it`：通常是为了交互模式运行容器，允许用户像在本地终端一样与容器进行实时交互
例：`docker run -it ubuntu /bin/bash` 这条命令会启动一个Ubuntu容器，并打开一个Bash shell，用户可以在其中输入命令并查看输出

最后的`sh`：在容器内运行的命令，即启动一个Shell会话



## 批处理
```bat
@echo off
REM 运行第一条 Docker 命令
echo 正在运行 FastQC ...
docker run --rm -v X:\analyse\data:/data -v X:\analyse\results:/results bio_fastqc
if %errorlevel% neq 0 (
    echo bio_fastqc FastQC 运行失败！
    pause
    exit /b %errorlevel%
)

REM 运行第二条 Docker 命令
echo 正在运行 SPAdes ...
docker run --rm -v X:\analyse\data:/data -v X:\analyse\results:/results -v X:\analyse\scripts:/scripts bio_spades /scripts/spades.sh
if %errorlevel% neq 0 (
    echo bio_spades SPAdes 运行失败！
    pause
    exit /b %errorlevel%
)

echo 脚本运行成功！
pause
```

***保存为bat文件***

`@echo off`：关闭命令回显
`REM`：注释
`echo`：输出提示信息
`if %errorlevel% neq 0`：检查上一条命令的退出代码，如果命令失败（退出代码非0），则输出错误信息并暂停脚本执行
`exit /b %errorlevel%`：退出脚本并返回上一条命令的退出代码
`pause`：按任意键继续，方便查看输出结果



## 报告的解读

[Explain](D:\Work\analyse\EXPLAIN.md)

#### FastQC
https://www.jianshu.com/p/dacedb7f6e2f
#### SPAdes
https://blog.csdn.net/WDPLAAA/article/details/135617297