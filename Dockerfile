FROM smallstep/step-ca
LABEL maintainer="Ryan Oertel <ryan.oertel@gmail.com>"
EXPOSE 9000/tcp

COPY scripts /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["step-ca", "${CONFIGPATH}", "--password-file=${PWDPATH}"]
