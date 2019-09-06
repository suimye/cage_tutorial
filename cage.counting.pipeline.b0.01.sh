#!/bin/sh

#  cage.counting.pipeline.b0.01.sh
#  
#
#  Created by suimye on 2019/07/24.
#  
#
# Requirement
# BEDtools（v2.28.0を利用）
# Kent Utility tools（http://hgdownload.soe.ucsc.edu/admin/exe/）
# リファレンス用のFANTOM5のCAGEクラスタ情報


#bamfile=/Users/suimye/cage_practice/PAX6_4/pax6.rep1.bam
bamfile=$1
qval=$2

chromoinfo=hg19.genome
cage_ref=hg19.cage.promoter.robust.peak.bed

timestamp=`date +'%y%m%d'`
fwbg=`mktemp`
revbg=`mktemp`

original_name=`basename ${bamfile} |sed -e 's/.bam//'`
echo ${original_name}


samtools view -F 4 -u -q ${qval} ${bamfile} | genomeCoverageBed -ibam /dev/stdin \
        -5 -bg -strand + | sort -k1,1 -k2,2n \
        > ${fwbg}
samtools view -F 4 -u -q ${qval} ${bamfile} | genomeCoverageBed -ibam /dev/stdin \
        -5 -bg -strand - | sort -k1,1 -k2,2n \
        > ${revbg}


bedGraphToBigWig ${fwbg} ${chromoinfo} ${original_name}.ctss.fwd.bw
bedGraphToBigWig ${revbg} ${chromoinfo} ${original_name}.ctss.rev.bw


fwd=`awk '{ sum = sum + $4 * ($3 - $2) }END{print sum}' ${fwbg}`
rev=`awk '{ sum = sum + $4 * ($3 - $2) }END{print sum}' ${revbg}`
total_sum=`echo | awk -v fw=${fwd} -v rev=${rev} '{sum=fw + rev; print sum}'`

printf "001CAGE:MAPPED\t${total_sum}\n" > ${original_name}.${timestamp}.ctss.txt

cat ${cage_ref} \
   | awk '{if($6 == "+"){print}}' \
   | bigWigAverageOverBed ${original_name}.ctss.fwd.bw /dev/stdin /dev/stdout \
   | cut -f 1,4 >> ${original_name}.${timestamp}.ctss.txt

cat ${cage_ref} \
   | awk '{if($6 == "-"){print}}' \
   | bigWigAverageOverBed ${original_name}.ctss.rev.bw /dev/stdin /dev/stdout \
   | cut -f 1,4 >> ${original_name}.${timestamp}.ctss.txt
