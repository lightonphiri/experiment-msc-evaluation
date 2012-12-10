"""This module provides workload-related functions for performing
performance evaluation experiments.

"""

__name__ = "simplyctperformance"
__version__ = "1.0.0"
__author__ = "Lighton Phiri"
__email__ = "lighton.phiri@gmail.com"

import os
import shutil

def spawnworkload(dataset, destination):
    workloads = (('w1',100), ('w2',200), ('w3',400), ('w4',800), ('w5',1600), ('w6',3200), ('w7',6400), ('w8',12800), ('w9',25600), ('w10',51200), ('w11',102400), ('w12',204800), ('w13',409600), ('w14',819200))
    for workload in workloads:
        workloadname = workload[0]
        workloadlimit = workload[1]
        workloadvalue = 1
        for root, dirs, files in os.walk(dataset):
            for filename in files:
                if filename.endswith('.metadata'):
                    #directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, file)), dataset))
                    #directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename))))
                    directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename))))
                    #directory = directory[directory.index('/')+1:] # remove contextual directory
                    directory = directory[directory.index('/')+1:]
                    #directory = os.path.join(destination, workloadname, directory)
                    directory = os.path.join(destination, workloadname, directory)
                    #workloadfile = os.path.relpath(os.path.abspath(os.path.join(root, file)), dataset)
                    workloadfile = os.path.abspath(os.path.join(root, filename))
                    if not os.path.exists(directory):
                        os.makedirs(directory)
                    shutil.copy2(workloadfile, destination)
                    workloadvalue += 1
                    if workloadvalue > workloadlimit:
                        break
            if workloadvalue > workloadlimit:
                break
        if workloadvalue > workloadlimit:
            continue
