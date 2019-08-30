CAGE解析チュートリアル
====

プロモータ発現テーブルを得るためのCAGE解析パイプラインを用意しています。CAGEデータを各種アライメントソフトウェアでリファレンスゲノムにアライメントしたデータ（BAMファイル）をご用意ください。　　

解析結果のデータやテストデータは、下記からダウンロードすることができます。

- [テストデータおよび解析済みデータ](https://drive.google.com/open?id=1UVryalUW7gGuNLC-rsnVR1ayZCkOqhI1)




### Software Requirement   
---    
This pipeline requires following tools:  

- wget  
	
- bigWigAverageOverBed, bedGraphToBigWig in Kent Utility tools  
	http://genome-test.cse.ucsc.edu/~kent/exe/
- R  
	https://www.r-project.org/
- BEDtools  
	http://code.google.com/p/bedtools/ 
	
### Data download and preparation

解析テスト用のデータとリファレンスデータをダウンロード    


1. テストデータ  

```  
 vdb-dump  -I -f fastq DRR021905 >pax4_rep1.fq
 vdb-dump  -I -f fastq DRR021903 >pax4_rep2.fq
 vdb-dump  -I -f fastq DRR021904 >pax4_rep3.fq
 vdb-dump  -I -f fastq DRR021908 >pax6_rep1.fq
 vdb-dump  -I -f fastq DRR021909 >pax6_rep2.fq
 vdb-dump  -I -f fastq DRR021910 >pax6_rep3.fq

```  

ダウンロードしたデータは、各種マッピングソフトウェアでマッピングを実行してください（マッピング過程は割愛）。


2. 解析に利用するプロモーターのリファレンスデータのダウンロード
FANTOM5のサイトから、CAGEのプロモーター情報についてダウンロードします。ダウンロードしたファイルのゲノム座標はhg19に基づいています。

```  

#FANTOM5 CAGE cluster reference

wget http://fantom.gsc.riken.jp/5/datafiles/latest/extra/CAGE_peaks/hg19.cage_peak_phase1and2combined_coord.bed.gz
gzcat hg19.cage_peak_phase1and2combined_coord.bed.gz | awk '{OFS="\t"}{print $1,$2,$3,$4,$5,$6}' >hg19.cage.promoter.robust.peak.bed


```  

  
3. 解析用フォルダの作成  

```

mkdir cage_practice     #cage_practiceフォルダを作成
cd cage_practice/         #フォルダへ移動
pwd          　　　　　　#現在のディレクトリを確認

```


## パイプラインの実行  

### 1. パイプラインのshellスクリプトをダウンロードして、解析を実行する。
２つめの引数は、MAPQ（品質評価値）の閾値を入力する。
```
git clone https://github.com/suimye/cage.counting.pipeline.sh   
sh cage.counting.pipeline.b0.01.sh sample.bam 20
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



Licenses
--------
The programs are licensed under the modified BSD Licenses. 
