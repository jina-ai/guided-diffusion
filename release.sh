#!/usr/bin/env bash

# Requirements
# brew install hub
# npm install -g git-release-notes
# pip install twine wheel

set -ex

INIT_FILE='discoart/__init__.py'
VER_TAG='__version__ = '
RELEASENOTE='./node_modules/.bin/git-release-notes'

function escape_slashes {
    sed 's/\//\\\//g'
}

function update_ver_line {
    local OLD_LINE_PATTERN=$1
    local NEW_LINE=$2
    local FILE=$3

    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    sed -i '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
    head -n10 ${FILE}
}


function clean_build {
    rm -rf dist
    rm -rf *.egg-info
    rm -rf build
}

function pub_pypi {
    # publish to pypi
    clean_build
    python setup.py sdist
    twine upload dist/*
    clean_build
}

function git_commit {
    git config --local user.email "dev-bot@jina.ai"
    git config --local user.name "Jina Dev Bot"
    git tag "v$RELEASE_VER" -m "$(cat ./CHANGELOG.tmp)"
    git add $INIT_FILE ./CHANGELOG.md
    git commit -m "chore(version): the next version will be $NEXT_VER" -m "build($RELEASE_ACTOR): $RELEASE_REASON"
}



function make_release_note {
    ${RELEASENOTE} ${LAST_VER}..HEAD .github/release-template.ejs > ./CHANGELOG.tmp
    head -n10 ./CHANGELOG.tmp
    printf '\n%s\n\n%s\n%s\n\n%s\n\n%s\n\n' "$(cat ./CHANGELOG.md)" "<a name="release-note-${RELEASE_VER//\./-}"></a>" "## Release Note (\`${RELEASE_VER}\`)" "> Release time: $(date +'%Y-%m-%d %H:%M:%S')" "$(cat ./CHANGELOG.tmp)" > ./CHANGELOG.md
}


# release the current version

pub_pypi
