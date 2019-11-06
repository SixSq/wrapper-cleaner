FROM docker

COPY watcher.sh /watcher.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/watcher.sh"]
