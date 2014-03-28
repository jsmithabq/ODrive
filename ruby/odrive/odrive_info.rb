
#
# == Summary
#
# ODriveApp implements core ODrive resource/route handling.
#
# This file defines support information, primarily for <tt>odrive.rb</tt>.
#
# == Note
#
# Currently, it's useful to map resources in URLs to table names to avoid
# hardcoded table references, but this approach only reduces _some_ of the
# database dependencies in the source code.  It will be easy enough to abandon
# this approach later with global search and replace.
#
# For the user-management database, database operations are handled with
# <tt>Sequel::Model</tt>.
#

#require 'base64'
require 'db/user_db_util.rb'

include UserDBUtil

ODRIVE_VERSION = '0.1'
ODRIVE_AES = UserDBUtil::AESEncryptinator.new()
#puts ODRIVE_AES.inspect

#ODRIVE_DEFAULT_HEADER_FOOTER = "Optional Banner"
#ODRIVE_DEFAULT_HEADER_FOOTER = "ACME CORP PROPRIETARY CONTENT"
ODRIVE_DEFAULT_HEADER_FOOTER = ""
ODRIVE_CONFIG_FILE = './conf/odrive.conf'
ODRIVE_COMPONENT_DIR = './components'
USER_STORE_LOCATION = './store/ODriveUserManagement.db' # common to multiple apps

ODRIVE_MAX_FILE_SIZE = (1073741824 * 5) - 1 # 5G
ODRIVE_GIGA = 1073741824
ODRIVE_MEGA = 1048576
ODRIVE_KILO = 1024
ODRIVE_GIGA_F = 1073741824.0
ODRIVE_MEGA_F = 1048576.0
ODRIVE_KILO_F = 1024.0
ODRIVE_GB = 1000000000
ODRIVE_MB = 1000000
ODRIVE_KB = 1000
ODRIVE_GB_F = 1000000000.0
ODRIVE_MB_F = 1000000.0
ODRIVE_KB_F = 1000.0

ODRIVE_ROOT = '^/'
ODRIVE_HOME = '/'
ODRIVE_ABOUT = '/about'
ODRIVE_UNKNOWN = '/*'
ODRIVE_PREFIX = 'rest'
ODRIVE_NAME = '([a-zA-Z0-9\-\_\.]+)'
ODRIVE_NUM = '([0-9]+)'
ODRIVE_EXT = '(|\.html|\.xml|\.yaml|\.json|\.atom|\.text|\.txt)$'
ODRIVE_JSON_PAD = '  '
ODRIVE_XML_PAD = '  '
ODRIVE_YAML_PAD = '  '
ODRIVE_PAGE_SIZE = "20"
ODRIVE_FORMAT = {
  :text => 'text/plain',
  :html => 'text/html',
  :yaml => 'text/yaml',
  :atom => 'application/atom+xml',
  :json => 'application/json',
  :xml => 'application/xml',
  :octet => 'application/octet-stream',
  :bin => 'application/octet-stream',
}

ODRIVE_PORT = 6799

ODRIVE_INITIAL_HOST = 'Choose Host'
OPENSTACK_INITIAL_HOST = '(no cloud host)'
ODRIVE_NO_HOSTS_LIST = [ODRIVE_INITIAL_HOST, OPENSTACK_INITIAL_HOST]

ODRIVE_HOSTS = [
  ODRIVE_INITIAL_HOST,
  'localhost',
]

ODRIVE_STYLE = 'Default'
ODRIVE_STYLES = [
  'Default',
  'Adobe',
  'Artic',
  'Atlantic',
  'C4CR',
  'Creamsicle',
  'Desert',
  'Foam',
  'Overcast',
  'Pacific',
]

OPENSTACK_ADMIN_PORT = '35357'
OPENSTACK_COMPUTE_PORT = '8774'
OPENSTACK_DEFAULT_TENANT = 'demo'
OPENSTACK_DEFAULT_USER = 'test'
OPENSTACK_DEFAULT_PASSWORD = 'secret'
OPENSTACK_DEFAULT_ENCRYPT_PASSWORD = ODRIVE_AES.encrypt(OPENSTACK_DEFAULT_PASSWORD)
OPENSTACK_INITIAL_TENANT = '(no cloud tenant)'
OPENSTACK_INITIAL_USER = '(no cloud user)'
OPENSTACK_INITIAL_PASSWORD = ODRIVE_AES.encrypt('(no cloud password)')

LIST_ONE_USER = :list_one_user
LIST_MULTIPLE_USERS = :list_multiple_users
