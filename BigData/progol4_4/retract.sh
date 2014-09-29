rm source/*.o source/progol source/qsample
tar cvf progol4_4.tar examples4.2 examples4.4 source man
gzip progol4_4.tar
rm -r examples4.2 examples4.4 source man
