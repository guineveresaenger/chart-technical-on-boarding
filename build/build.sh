#!/usr/bin/env bash
#
# Our helm charts have the version format 'x.y.z-a', where a is the number 
# of commits since the last tagged version. A tagged version's 'a' will be 0.
# CHART_VER is the 'x.y.z' part of the version. Helm charts may not have a v 
# in their versioning tag. CHART_REL is the 'a' part of the version.
#
# The version and release is statically set if you cannot calculate it via git.
# Additionally if CHART_VER or CHART_REL are set explicitly, those values will
# have precendence over all.

export CHART_NAME=${CHART_NAME:-technical-on-boarding}
export CHART_VER=${CHART_VER:-0.0.0}
export CHART_REL=${CHART_REL:-0}

# strip leading 'v' if present in version
[[ ${CHART_VER} =~ ^v ]] && CHART_VER=${CHART_VER#v}

# use git calculated version if you can AND if defaults are being used
GIT_VER=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [[ -n ${GIT_VER} && ${CHART_VER} = 0.0.0 && ${CHART_REL} = 0 ]]; then
  CHART_VER=${GIT_VER}
  CHART_REL=$(git rev-list --count v${CHART_VER}..HEAD 2>/dev/null)
fi

# generate chart.yaml
echo Using chart version: ${CHART_VER}-${CHART_REL}
envsubst < build/Chart.yaml.in > ${CHART_NAME}/Chart.yaml
