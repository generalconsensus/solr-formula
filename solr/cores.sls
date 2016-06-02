# Manage cores and conf
/opt/solr/example/multicore/solr.xml:
  file.managed:
    - source: salt://solr/files/solr.xml
    - mode: 644
    - watch_in:
      - service: jetty-service

#/opt/solr/example/multicore/vagrant:
#  file.recurse:
#    - source: salt://solr/files/vagrant
#    - include_empty: True
#    - watch_in:
#      - service: jetty-service
