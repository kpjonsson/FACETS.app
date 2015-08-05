#!/opt/common/CentOS_6/R/R-3.1.2/bin/Rscript
# Originally Will Lee Aug 2015

library(argparse)
parser = ArgumentParser()
parser$add_argument("-c","--chromosome",type="character",default=12,help="Chromosome name")
parser$add_argument("-s","--start",type="integer",default=69201971,help="Chromosomal start coordinate")
parser$add_argument("-e","--end",type="integer",default=69239320,help="Chromosomal end coordinate")
args = parser$parse_args()

chrom=args$chromosome
start=args$start
end=args$end

plotSampleRegion = function(out, fit, chrom, chromStart, chromEnd) {
  orig = out
  mat = out$jointseg
  mat = mat[mat$chrom==chrom,]
  out = out$out
  out = out[out$chr==chrom,]
  cncf = fit$cncf
  cncf = cncf[cncf$chr==chrom,]
  dipLogR = fit$dipLogR

  layout(matrix(c(1,1,2,2), ncol=1), heights = c(2, 1))
  par(mar=c(5,3,1,1), mgp=c(2, 0.7, 0))

  highlight.marks = mat$maploc >= chromStart & mat$maploc <= chromEnd
  pt.cols = rep("grey", times=nrow(mat))
  pt.cols[highlight.marks] = "red"

  plot(mat$cnlr,pch=".",axes=F,cex=1.5,ylim=c(-3,3),col=pt.cols,ylab="log-ratio",main=unique(orig$IGV$ID), xlab=paste("chr",chrom,sep=""))
  abline(h=dipLogR, col="gray")
  points(rep(cncf$cnlr.median, cncf$num.mark), pch = ".", cex = 3, col = "darkblue")
  axis(side=2)
  box()

  labeled=paste(
          "Purity = ",sprintf("%.3f",fit$purity),
          ", Ploidy = ",sprintf("%.3f",fit$ploidy),
          ", WGD = ",ifelse(fit$dipt>2,"Yes","No"),sep=""
  )

  plot(mat$valor,axes=F,pch=".",cex=1.5,col=pt.cols,ylab="log-odds-ratio",xlab="",ylim=c(-4,4),main=labeled)
  points(rep(sqrt(abs(cncf$mafR)), cncf$num.mark), pch=".", cex=2, col="darkblue")
  points(-rep(sqrt(abs(cncf$mafR)), cncf$num.mark), pch=".", cex=2, col="darkblue")
  axis(side=1,at=cumsum(cncf$num.mark),mat[cumsum(cncf$num.mark),"maploc"],las=2)
  axis(side=2)
  box()
}

ddir="."
files=dir(ddir,pattern=".R[Dd]ata")

pdf(file=paste('chr', chrom, "_", start, "-", end, ".facets.pdf",sep=""))

for(file in files) {
  print(file)
  load(file.path(ddir,file))
  plotSampleRegion(out, fit, chrom, start, end)
}

dev.off()
