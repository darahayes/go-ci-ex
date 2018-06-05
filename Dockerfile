FROM scratch
ARG BINARY=./go-ci-ex
EXPOSE 8000

COPY ${BINARY} /opt/go-ci-ex
CMD ["/opt/go-ci-ex"]