#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 31, 2013
#

for dataset in `seq 1 3`
   do
      for workload in `seq 1 3`
         do
            # count directories in level 1
            level1=`find /home/lphiri/datasets/ndltd/random/workload$dataset/w$workload -mindepth 1 -maxdepth 1 -type d | wc -l`
            # count directories in level 2
            level2=`find /home/lphiri/datasets/ndltd/random/workload$dataset/w$workload -mindepth 2 -maxdepth 2 -type d | wc -l`
            # count directories in level 3
            level3=`find /home/lphiri/datasets/ndltd/random/workload$dataset/w$workload -mindepth 3 -maxdepth 3 -type d | wc -l`
            echo dataset$dataset,w$workload,l1:$level1,l2:$level2,l3:$level3
         done
   done
