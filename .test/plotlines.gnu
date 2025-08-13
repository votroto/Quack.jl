set terminal pngcairo size 400,300
set output "smoothed_curves.png"
set xlabel "Iteration"
set ylabel "Value"
unset key
set samples 1000
#set isosamples 1000

plot for [col=1:440] 'guesstransposed.txt' using 0:col  notitle with lines lw 2 lc rgb "#CC000000"
