

library("edgeR")
args <- commandArgs(TRUE)
time_stamp <- Sys.Date()
fl <- list.files(pattern=".ctss.txt")

flag=0
if(length(args)==2){
    gp1 =args[1]
    gp2 =args[2]
    flag = 0
}else if (args[1] == "none"){
    flag = 1
}else{
    stop
}

#gp1
#fl

df <- NULL
cname <- NULL
rname <- rownames(read.table(fl[1],stringsAsFactors=F,header=F,row.names=1))


for(i in 1:length(fl)){
 	#cname <- c(cname,strsplit(fl[i],"\\.")[[1]][2])
	read_d <- read.table(fl[i],stringsAsFactors=F,header=F,row.names=1)
 	df <- cbind(df,read_d[rname,])
}
colnames(df) <- sub(".ctss.txt","",fl)
rownames(df) <- rname

# normalization step for CAGE tag counting.

gp <- NULL
if(flag==0){
	gp <- rep(0,length(fl))
	for(i in 1:length(unique(fl))){
		gp[grep(args[i],fl)] <- i
		#gp[grep(gp2,fl)] <- 2
	}
}else{
	# if argument none was found. each labels are independent label.
	gp <- seq(1,length(fl))

}

	
size <- df[1,]


# dgeL object construction
d <- DGEList(counts=df[-1,], group=gp, lib.size=size)
dgeL <- calcNormFactors(d, method="RLE")
dgeL <- estimateDisp(d)
log2cpm = cpm(dgeL, log=T)

# outputfiles
write.table(log2cpm,"cage.count.txt",sep="\t",quote=F)
save.image(paste("cage_count",time_stamp,".RData",sep=""))

F5_promoter_count  = colSums(dgeL[["counts"]])
other_region_count = dgeL[["samples"]][,"lib.size"] - F5_promoter_count
barplot_df <- rbind(F5_promoter_count, other_region_count)

# パーセンテージの計算

prom_per <- round(F5_promoter_count*100/dgeL[["samples"]][,"lib.size"],2)
other_per <- round(other_region_count*100/dgeL[["samples"]][,"lib.size"],2)

# レジェンド文字のラベル位置を調整
label1_pos <- F5_promoter_count / 2
label2_pos <- F5_promoter_count + other_region_count / 2


pdf("cage.qcbarplot.pdf", width=15, height=10)
	#par(mar=c(10,10,10,10))
	par(mar=c(10,10,10,10),mai = c(1, 4, 2,2))
	bp <- barplot(
		barplot_df,
		horiz=T,
		main="CAGE QC",
		xlab="The number of mapped CAGE tags",
		#legend.text=rownames(barplot_df),
		#args.legend=list(cex=0.8,y=1),
		las=1,cex.axis=0.6, cex.names=0.6
	)
	text(bp,x=label1_pos, format(paste(prom_per,"%","")), xpd = TRUE, col = "red",cex=0.5)
	text(bp,x=label2_pos, format(paste(other_per,"%","")), xpd = TRUE, col = "black",cex=0.5)
	par(xpd=T)
	legend(par()$usr[2] + 0.4,par()$usr[4] + 0.1,legend=rownames(barplot_df),pch=15,cex=0.4,col=c(colors()[183],colors()[235]))
dev.off()

q()
