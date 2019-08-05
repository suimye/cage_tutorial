CAGE解析チュートリアル
====

プロモータ発現テーブルを得るためのCAGE解析パイプラインを用意しています。ゲノムへのアライメント後の解析になりますので、CAGEデータを各種アライメントソフトウェアでアライメントしたデータをご用意ください。

- 解析済みデータ  




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


2. 解析に利用するリファレンスデータ（hg19）

```  

#FANTOM5 CAGE cluster reference

wget http://fantom.gsc.riken.jp/5/datafiles/latest/extra/CAGE_peaks/hg19.cage_peak_phase1and2combined_coord.bed.gz
gzcat hg19.cage_peak_phase1and2combined_coord.bed.gz | awk '{OFS="\t"}{print $1,$2,$3,$4,$5,$6}' >hg19.cage.promoter.robust.peak.bed


```  

  
3. フォルダの作成  


% mkdir cage_practice     #cage_practiceフォルダを作成
% cd cage_practice/         #フォルダへ移動
% pwd          　　　　　　#現在のディレクトリを確認
/Users/suimye/cage_practice  


```


### Getting started-CAGEpipeline- 
---   

パイプラインのshellスクリプトをダウンロードして、解析を実行する。
	
	
```
	git clone https://github.com/suimye/cage.counting.pipeline.sh  
	~/cage.counting.pipeline.b0.01.sh -f 
```

### Output files




Licenses
--------
The programs are licensed under the modified BSD Licenses. 
