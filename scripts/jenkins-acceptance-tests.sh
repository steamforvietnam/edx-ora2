##############################################################################
#
#   Run the acceptance tests in Jenkins
#
#   This assumes that:
#       * Jenkins has Python and virtualenv installed
#       * Jenkins has the SauceConnect plugin installed.
#       * The Jenkins job provides the environment variables
#           - BASIC_AUTH_USER: The basic auth username for the sandbox.
#           - BASIC_AUTH_PASSWORD: The basic auth password for the sandbox.
#           - TEST_HOST: The hostname of the sandbox (e.g. test.example.com)
#
##############################################################################

set -x

if [ -z "$BASIC_AUTH_USER" ]; then
    echo "Need to set BASIC_AUTH_USER env variable"
    exit 1;
fi

if [ -z "$BASIC_AUTH_PASSWORD" ]; then
    echo "Need to set BASIC_AUTH_PASSWORD env variable"
    exit 1;
fi

if [ -z "$TEST_HOST" ]; then
    echo "Need to set TEST_HOST env variable"
    exit 1;
fi

export ORA_SANDBOX_URL="https://${BASIC_AUTH_USER}:${BASIC_AUTH_PASSWORD}@${TEST_HOST}"

virtualenv venv
source venv/bin/activate
pip install -r requirements/test-acceptance.txt


######### Run acceptance tests #########
make test-acceptance


######### Run accessibility tests #########

# Unset SELENIUM_HOST so that bok-choy doesn't try to use saucelabs
unset SELENIUM_HOST

# AutoAuthPage times out in PhantomJS when using https, so switch to use http
export ORA_SANDBOX_URL="http://${BASIC_AUTH_USER}:${BASIC_AUTH_PASSWORD}@${TEST_HOST}"

make test-a11y
