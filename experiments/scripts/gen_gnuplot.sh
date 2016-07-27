#!/bin/bash
usage="$0 <fichier logs.dat> <prefixe_fic> <chemin sortie> <titre> <ylabel> <col_metric> <actions_label> <ymax> <xmax>"
argc=$#

if [ 9 -ne $argc ]
then
	echo $usage
	exit 1
fi



fichier_dat=$1
prefixe=$2
chemin_sortie=$3
titre=$4
ylabel=$5
col_metric=$6
actions_label=$7
ymax=$8
xmax=$9

nb_col=`cat $fichier_dat|head -1|tr -s " "|tr " " "\n"|wc -l`
nb_algo=`expr $nb_col - 1`
nb_ligne='*'
abscisse_max=`cat $fichier_dat| cut -d' ' -f1|sort -nr|head -1`


cat >$chemin_sortie/$prefixe.gnuplot<<FIN
# Sortie
set terminal postscript landscape "Times-Roman" 17
set output "$chemin_sortie/$prefixe.ps"
set encoding iso_8859_1
# Paramètres
set key bmargin
set xrange [0:$xmax]
set yrange [0:$ymax]
set y2range [0:*]
set style fill solid border 3





$actions_label

#set xtics $xtics
#set xtic rotate by -45 scale 0
set xlabel "time (s)"
set ylabel "$ylabel"
set y2label "Load (number of request per sec)"
set y2tics
set nolabel
set ytics nomirror
set title "$titre"
 
# Dessin de la courbe
plot [] "$fichier_dat" using 1:$col_metric title "$ylabel" with lines linewidth 3 linetype 1 linecolor rgb '#FF0000',\
"" using 1:2 title "Load" with lines linewidth 3 linetype 2 axes x1y2
#"" using 1:3 title "pem_token" with linespoint linewidth 3 linetype 1 linecolor 2 pt 1


FIN

