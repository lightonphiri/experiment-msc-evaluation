
Python OAI-PMH Module

 -> http://www.infrae.com/download/OAI/pyoai
 -> setup
  -> installation - sudo python setup.py install
  -> 

  
http://union.ndltd.org/OAI-PMH/?verb=ListRecords&metadataPrefix=oai_dc








for line in `grep -r "citep" .`; do echo $line; done | grep citep | awk '{print substr(index($1, "\citep"), index($1, "}"))}'