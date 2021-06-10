#!/bin/bash

#
# IMPORTANT
# Must be logged into correct AWS account.
#

set -euo pipefail

RED="$(tput bold)$(tput setaf 1)"
GRN="$(tput bold)$(tput setaf 2)"
YLW="$(tput bold)$(tput setaf 3)"
RST="$(tput sgr0)"

lambdas="/tmp/lambdas_${AWS_PROFILE}.json"
echo "${YLW}[${AWS_PROFILE}]${RST}"
echo "Using tmp file: ${lambdas}"

if [[ ! -f "${lambdas}" ]]; then
  aws lambda list-functions > "${lambdas}"
fi

total="$(jq -r '.Functions | length' ${lambdas})"
echo "Total lambdas:  ${GRN}${total}${RST}"

OUT_JS='/tmp/outdated.js.json'
OUT_PY='/tmp/outdated.py.json'
jq -r '[.Functions[] | select(.Runtime | test("nodejs(4.3|6.10|8.10|10.x)"))]' "${lambdas}" > "${OUT_JS}"
jq -r '[.Functions[] | select(.Runtime | test("python2.7"))]' "${lambdas}" > "${OUT_PY}"

# number of outdated lambdas
odt_js=$(jq -r '. | length' ${OUT_JS})
odt_py=$(jq -r '. | length' ${OUT_PY})
odt_total=$(( odt_js + odt_py ))

echo "Total outdated: ${RED}${odt_total}${RST}"
echo "  Node.js: ${RED}${odt_js}${RST}"
echo "$(jq -r '[.[] | { version: .Runtime }] | group_by(.version) | map({ version: .[0].version, count: length }) | .[] | "    \(.version): \(.count)"' ${OUT_JS})"
echo "  Python:  ${RED}${odt_py}${RST}"
echo

