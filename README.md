# docker-smallstep-ca
docker image template for a one-shot smallstep step-ca instance

Arguments are the same as smallstep/step-ca, but allows for auto-initialization with configuration files
or environment variables. Create a configuration file `/step-config` with any of the `step ca init` arguments
(except they're all caps and `-` is replaced with `_`. Alternatively, you can specify these arguments as
environment variables:

* `STEP_ROOT`
* `STEP_KEY`
* `STEP_PKI`
* `STEP_SSH`
* `STEP_NAME`\* (default: `$hostname`)
* `STEP_DNS`\* (default: `hostname`)
* `STEP_ADDRESS`\* (default: localhost:9000)
* `STEP_PROVISIONER`\* (default: admin)
* `STEP_PASSWORD_FILE` (default: autogenerate, placed in /home/step/secrets/password)
* `STEP_PROVISIONER_PASSWORD_FILE`
* `STEP_WITH-CA-URL`
* `STEP_RA`
* `STEP_ISSUER`
* `STEP_CREDENTIALS_FILE`
* `STEP_NO_DB`

\* marked variables should be specified at a minimum. Reasonable defaults will be chosen if they are not provided.

Additionally, the following environment variables will be interpreted:
* `STEP_INIT_CONFIGFILE` - Alternate configuration file for the initialization script.
* `STEP_GENPASS` - Generate a random password and place it in the `STEP_PASSWORD_FILE`

Sample execution:
   `docker run --port 9000:9000 roertel/smallstep-ca`
Starts a Smallstep CA on localhost:9000 with an auto-generated password, using provisioner 'admin'.

or

  ```
  docker run --name step-ca --port 9000:9000 \
     --volume step-ca:/home/step --env STEP_GENPASS \
     --env STEP_NAME=<your internal domain> \
     --env STEP_DNS=<CA server hostname or IP address> \
     roertel/step-ca
  ```

Verify:
```
curl -k https://localhost:9000/health
```
should return
   `{"status":"ok"}`
