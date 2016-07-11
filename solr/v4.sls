# Make sure we've got java
java-1.6.0-openjdk:
  pkg.installed

# Get solr
solr-4.10.4:
  file.managed:
    - name: /opt/solr-4.10.4.tgz
    - source: http://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz
    - source_hash: md5=8ae107a760b3fc1ec7358a303886ca06
    - unless: test -f /opt/solr-4.10.4.tgz

# Extract it
extract-solr:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf solr-4.10.4.tgz
    - run
    - require:
      - file: solr-4.10.4
    - unless: test -d /opt/solr-4.10.4

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-4.10.4

/opt/solr/example/multicore/vagrant:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v4') }}
    - user: root

/opt/solr/example/multicore/solr.xml:
  file.managed:
    - source: salt://solr/files/solr.xml
    - mode: 644
    - watch_in:
      - service: jetty-service

# init
/etc/init.d/jetty:
  file.managed:
    - source: salt://solr/files/jetty-init
    - mode: 744

/sbin/chkconfig --add jetty:
  cmd.run:
    - unless: /sbin/chkconfig | grep -q jetty
    - require:
      - file: /etc/init.d/jetty

jetty-service:
  service:
    - name: jetty
    - enable: True
    - sig: Dsolr
    - running

# logrotate
/etc/logrotate.d/jetty:
  file.managed:
    - source: salt://solr/files/jetty-logrotate
    - mode: 744

