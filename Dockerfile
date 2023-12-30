FROM node:21-alpine as base

#STAGE 1: Depedency Phase
FROM base as deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn

#STAGE 2: Runner Phase

FROM base as builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .

RUN yarn run build

#STAGE 3: Push Build Folder To S3

FROM mesosphere/aws-cli

WORKDIR /app

COPY --from=builder  /app/build .

CMD ["s3", "sync", "./", "s3://aws-react-app-1"]