# Runs in the alpine:3.15
FROM alpine:3.15

# Add Maintainer Info
LABEL maintainer="zealteamsix@empb.onmicrosoft.com"


# Install curl and bash dependencies
RUN apk update && apk add --no-cache curl && apk add --no-cache bash


# Copy the entrypoint file from the action repository
ADD entrypoint.sh /entrypoint.sh

# Set the file to execute when the docker container starts up
ENTRYPOINT ["/entrypoint.sh"]