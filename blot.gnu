set term pdfcairo size 10cm,3cm font "Times,12"
set output 'blot.pdf'

set xrange [0.1:10.9]
set yrange [-0.2:]
set format y "%3.1f"
set format y2 "%3.1f"

set xtics 2
set ytics 0.4
set tics in

set xlabel "Iteration"

set multiplot layout 2, 1


set ylabel "Instability"
set origin 0,0
set size 0.5,1
plot 'blot.txt' u 1:2 w lp title 'Player 1' lc rgb '#BA0C2F' ps 0.5 pt 5, '' u 1:3 w lp  title 'Player 2' lc rgb '#005EB8' ps 0.5 pt 5


set ylabel "Wasserstein"
set origin 0.5,0
set size 0.5,1
set offsets graph 0.1,0.1,0.1,0.1
plot 'blot.txt' u 1:4 w lp title 'Player 1' lc rgb '#BA0C2F' ps 0.5 pt 5, '' u 1:5 w lp title 'Player 2' lc rgb '#005EB8' ps 0.5 pt 5


unset multiplot

