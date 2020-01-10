CAGE解析チュートリアル
====

プロモータ発現テーブルを得るためのCAGE解析パイプラインを用意しています。CAGEデータを各種アライメントソフトウェアでリファレンスゲノムにマッピングしたデータ（BAMファイル）をご用意ください。面倒な場合は下記のグーグルドライブからダウンロードすることもできます。

#### 解析結果のデータや整形済みテストデータは、こちらからダウンロードすることができます。

- [テストデータおよび解析済みデータ](https://drive.google.com/open?id=1UVryalUW7gGuNLC-rsnVR1ayZCkOqhI1)

### Update information 


- 2020.01.10: フォルダ作成後に、FANTOMリファレンスのBEDファイルを移動させる行を追記。　　
- update情報欄を作成  


## 事前準備　　

### Software Requirement     

- wget  
	
- bigWigAverageOverBed, bedGraphToBigWig in Kent Utility tools  
	http://genome-test.cse.ucsc.edu/~kent/exe/
- R  (version 3.5.1 (2018-07-02) -- "Feather Spray")
	https://www.r-project.org/
- BEDtools  (version 2.28にて動作確認。2.29 (latest, 2019.10)についても動作確認済みですが、エラーがでるという報告もあります。現在調査中。)
	http://code.google.com/p/bedtools/
    
  
  
### Data download and preparation
解析テスト用のデータとリファレンスデータのダウンロード

1. テストデータダウンロード

```  
 vdb-dump  -I -f fastq DRR021905 >pax4_rep1.fq
 vdb-dump  -I -f fastq DRR021903 >pax4_rep2.fq
 vdb-dump  -I -f fastq DRR021904 >pax4_rep3.fq
 vdb-dump  -I -f fastq DRR021908 >pax6_rep1.fq
 vdb-dump  -I -f fastq DRR021909 >pax6_rep2.fq
 vdb-dump  -I -f fastq DRR021910 >pax6_rep3.fq

```  

ダウンロードしたデータは、各種マッピングソフトウェアでマッピングを実行してください。　マッピング過程は割愛しますが、マッピング済みのBAMファイルは、[テストデータおよび解析済みデータ](https://drive.google.com/open?id=1UVryalUW7gGuNLC-rsnVR1ayZCkOqhI1)のフォルダの中にあるので、必要に応じてご利用ください。


2. プロモーターのリファレンスデータのダウンロード  
FANTOM5のサイトから、CAGEのプロモーター情報についてダウンロードします。ダウンロードしたファイルのゲノム座標はhg19に基づいています。

```  

#FANTOM5 CAGE cluster reference

wget http://fantom.gsc.riken.jp/5/datafiles/latest/extra/CAGE_peaks/hg19.cage_peak_phase1and2combined_coord.bed.gz
gzcat hg19.cage_peak_phase1and2combined_coord.bed.gz | awk '{OFS="\t"}{print $1,$2,$3,$4,$5,$6}' >hg19.cage.promoter.robust.peak.190603.bed


```  

  
3. 解析用フォルダの作成  

```

mkdir cage_practice     #cage_practiceフォルダを作成
mv hg19.cage.promoter.robust.peak.190603.bed cage_practice/  #先ほどのファイルをcage_practiceフォルダに移動させる
cd cage_practice/         #フォルダへ移動
pwd          　　　　　　#現在のディレクトリを確認


```


## CAGEプロモーター解析パイプラインの実行

### 1. パイプラインのshellスクリプトをダウンロードして、解析を実行する。
引数は、BAMファイル、MAPQ（品質評価値）の閾値、CAGEクラスター領域のリファレンス領域（例ではプロモーター領域）を入力する。

```
git clone https://github.com/suimye/cage_tutorial.git
sh cage.counting.pipeline.b0.01.sh sample.bam 20 hg19.cage.promoter.robust.peak.190603.bed
```



### 2. CAGEの品質評価の作図と発現テーブル作成  
argsオプションの後には、比較する試験区のラベル（今回はpax4とpax6）をそれぞれ入力する。

```
R --slave --vanilla --args pax4 pax6 < promoter_mapping_rate.R
```


### 3. 出力ファイル

- cage_count.RData  
CAGEタグをプロモーター別にカウントしたテーブルを含むRオブジェクト。edgeRライブラリーで解析可能なdgeLオブジェクトが保存されている。  
- cage.count.txt  
CAGEタグをプロモーター別の発現量のデータテーブル（log2対数変換済みのCPM値）。    
- cage.qcbarplot.pdf  
CAGE解析の品質を評価するために、CAGEタグのプロモーターへの集積率を調べたもの。  


## Option: De novo enhancer解析


#### requirements

- CAGE解析パイプラインで得られたbedGraph ファイル  (ファイルの末尾がfw.bg, rev.bgのファイル)
- マスクする領域のBEDファイル（FANTOM5のプロモーターリスト）: hg19.cage.promoter.robust.peak.190603.bed
enhancer call時に、プロモーター領域のCAGEクラスターを同定しないようにマスクするためのファイルを用意しておく。ここでは、STEP１で作成したFANTOM5 phase2のプロモーター情報を用いる。


### 1. enhancer callのスクリプトをダウンロード


```
 git clone -b mywork https://github.com/suimye/enhancers.git

```
gitに登録していない場合は、gitのURLのサイトからZIP形式でダウンロードすることができるので、CAGE解析フォルダにダウンロードして、解凍してください。


### 2. enhancer callのために必要なBEDファイルを作成する
bedGraphファイル（ファイルの末尾がfw.bg, rev.bgのファイル）が存在するディレクトリ下で以下のshellスクリプトを実行すると、BED6形式のファイルが生成される。
ただし、作業フォルダ内のbedGraphのファイル名の末尾は、.fw.bg, .rev.bgである必要がある。

```
sh make.bed6.from.bg.sh

```

### 3. BEDファイルのリストを作成する
2で作成したBEDファイルについて、FULL PATHでリストを作成する。ここでリストアップしたデータを全て用いてenhancer callを実施する。この例では、pax4の繰り返し実験のデータ３つを用いて、enhancer領域の決定を行うための準備をしている。

```
printf "/Users/suimye/cage_practice/pax4.rep1.bed\n/Users/suimye/cage_practice/pax4.rep2.bed\n/Users/suimye/cage_practice/pax4.rep3.bed\n" >bedlist.pax4.txt

```


### 4. enhancer callの実行
bidir_enhancersスクリプトを用いてenhancer callを実施する。この時、-mオプションで与えた領域のCAGEクラスターはenhancer callの対象とはならない。

```
mkdir pax4_enhancer_call #call結果のファイル置き場
./enhancers/scripts/bidir_enhancers -f bedlist.pax4.txt -m hg19.cage.promoter.robust.peak.190603.bed -o ./pax4_enhancer_call #enhancer callを実行
```



Licenses
--------
The programs are licensed under the modified BSD Licenses. 
