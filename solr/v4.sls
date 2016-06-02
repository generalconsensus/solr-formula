# Make sure we've got java
java-1.6.0-openjdk:
  pkg.installed

# Get solr
solr-4.10.4:
  file.managed:
    - name: /opt/solr-4.10.4.tgz
    - source: http://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz
    - source_hash: md5=8ae107a760b3fc1ec7358a303886ca06

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

# Get Drupal module
get-drupal-apachesolr-7.x.1:
  file.managed:
    - name: /opt/apachesolr-7.x-1.x-dev.tar.gz
    - source: https://ftp.drupal.org/files/projects/apachesolr-7.x-1.x-dev.tar.gz
    - source_hash: md5=b6ac413441e1793c59cec11a59b923d8

#Extract module
extract-drupal-apachesolr:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf apachesolr-7.x-1.x-dev.tar.gz
    - run
#    - require:
#      - file: apachesolr-7.x-1.x-dev.tar.gz
    - unless: test -d /opt/apachesolr

rsync-solr-configs:
  cmd.run:
    - names:
      - /usr/bin/rsync -av /opt/solr/example/multicore/core0/ /opt/solr/example/multicore/vagrant/
    - unless: test -d /opt/solr/example/multicore/vagrant

rsync-apachesolr-configs:
  cmd.run:
    - onchanges: rsync-solr-configs
    - names:
      - /usr/bin/rsync -av /opt/apachesolr/solr-conf/solr-4.x/ /opt/solr/example/multicore/vagrant/conf/
    - unless: test -d /opt/solr/example/multicore/vagrant

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
