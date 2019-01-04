#!/bin/bash -eu

# Unique image tag based on commit date and commit hash:
VERSION=$(git show --quiet --format="%cd-%h" --date=short --abbrev=8)
COMMIT_HASH=$(git show --quiet --format="%h" --abbrev=8)
BUILD_DATE=$(date -u +%FT%H:%M:%SZ)

while IFS= read -r IMAGE_NAME
do
  if [ -d "$IMAGE_NAME" ]
  then
    DOCKERFILE="${DOCKERFILE:-$WORKDIR/$IMAGE_NAME/Dockerfile}"
    CONTEXT="${CONTEXT:-$WORKDIR/$IMAGE_NAME}"
    TAG=$IMAGE_PREFIX$IMAGE_NAME:$IMAGE_TAG
    COMMIT_TAG=$IMAGE_PREFIX$IMAGE_NAME:$VERSION
    DOCKERFILE_FLAG=""
    if [ -e "$DOCKERFILE" ]
    then
      DOCKERFILE_FLAG="--file $DOCKERFILE"
    fi
    COMMAND="docker build --pull --no-cache \\
      --build-arg IMAGE_PREFIX=$IMAGE_PREFIX \\
      --tag $TAG \\
      --tag $COMMIT_TAG \\
      --target $TARGET \\
      --label org.label-schema.schema-version=\"1.0\" \\
      --label org.label-schema.vendor=\"$LABEL_VENDOR\" \\
      --label org.label-schema.vcs-url=\"$LABEL_VCS_URL\" \\
      --label org.label-schema.vcs-ref=\"$COMMIT_HASH\" \\
      --label org.label-schema.build-date=\"$BUILD_DATE\" \\
      --label org.label-schema.name=\"$IMAGE_NAME\" \\
      $DOCKERFILE_FLAG \\
      $CONTEXT"
    eval "$COMMAND"
  fi
done < <(echo "$IMAGES" | tr " " "\n")
