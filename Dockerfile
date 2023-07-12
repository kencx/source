FROM alpine:3.18 AS build

RUN apk add --no-cache git hugo
RUN hugo version

COPY . /site
WORKDIR /site
RUN hugo --minify --enableGitInfo

FROM nginx:1.25.1-alpine

WORKDIR /usr/share/nginx/html
RUN rm -rf *

COPY --from=build /site/public /usr/share/nginx/html
