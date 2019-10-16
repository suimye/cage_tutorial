#!/bin/sh




for _bgname in `ls |grep fw.bg`
do
	echo ${_bgname}	
	_filename=`echo $_bgname | sed -e 's/.fw.bg//'`
	awk 'count=0; OFS="\t"{print $1,$2,$3,"position",$4,"+"}' ${_bgname} >${_filename}.bed
done


for _bgname in `ls |grep rev.bg`
do      
	echo ${_bgname}
	_filename=`echo $_bgname | sed -e 's/.rev.bg//'`
        awk 'count=0; OFS="\t"{count++; print $1,$2,$3,"position",$4,"-"}' ${_bgname} >>${_filename}.bed
done 


