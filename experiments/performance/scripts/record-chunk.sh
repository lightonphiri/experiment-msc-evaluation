#!/bin/sh

for file in /home/lphiri/datasets/ndltd/oaipmh-responses/page-*; do
   echo 'Chunking response... '$file;
   python -c "import oaipmh2simplyct; oaipmh2simplyct.oaipmh2simplyctparser('$file')";
done
