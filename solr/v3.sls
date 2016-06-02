# Make sure we've got java
java-1.6.0-openjdk:
  pkg.installed

# Get solr
apache-solr-3.6.2:
  file.managed:
    - name: /opt/apache-solr-3.6.2.tgz
    - source: https://archive.apache.org/dist/lucene/solr/3.6.2/apache-solr-3.6.2.tgz
    - source_hash: md5=e9c51f51265b070062a9d8ed50b84647

# Extract it
extract-solr:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf apache-solr-3.6.2.tgz
    - run
    - require:
      - file: apache-solr-3.6.2
    - unless: test -d /opt/apache-solr-3.6.2

# link it
/opt/solr:
  file.symlink:
    - target: /opt/apache-solr-3.6.2

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
    - unless: test -d /opt/apachesolr-7.x-1.x-dev

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
    - require:
      - file: /etc/init.d/jetty
    - name: jetty
    - enable: True
    - sig: Dsolr
    - running
    - require:
      - file: /etc/init.d/jetty

# logrotate
/etc/logrotate.d/jetty:
  file.managed:
    - source: salt://solr/files/jetty-logrotate
    - mode: 744

# Set ownership 
/opt/solr/example/multicore:
  file.directory:
    - user: {{ salt['pillar.get']('project', 'root') }}
    - group: {{ salt['pillar.get']('project', 'root') }}
    - dir_mode: 2755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

# Sudo file to allow restarting jetty
/etc/sudoers.d/jetty:
  file.managed:
    - source: salt://solr/files/sudoers
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - context:
        user: {{ salt['pillar.get']('project', 'root') }}

