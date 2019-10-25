docker build -f Dockerfile -t korabo/phpdev:centos6 ./
: docker run --rm -it phpdev:centos6 bash
: docker run -d -p 9080:80 phpdev:centos6
: docker save phpdev:centos6 > phpdev-centos6.tar
: docker load <  phpdev-centos6.tar
