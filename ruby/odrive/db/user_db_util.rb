#
# == Summary
#
# UserDBUtil provides utility methods for database operations.  These methods are designed
# as mixins for the database scripts.
#

require 'base64'
require 'md5'
require 'openssl'
require 'digest/sha2'
#require 'odrive_info.rb'

#
# UserDBUtil provides utility methods for database operations.  These methods are designed
# as mixins for the database scripts.
#

module UserDBUtil
  ODRIVE_SALT = 'Who-12345-What-23456-Where-34567-When-45678'

  #
  # Encrypts arbitrary text using a salted, MD5 hash.
  #
  # Arguments:
  #   text - the text - String
  #   salt - the salt - String - optional
  #

  def encrypt_one_way(text, salt=ODRIVE_SALT)
    MD5.md5(MD5.md5(salt).hexdigest + text).hexdigest
  end

  #
  # Provides a class for persistent handling of encryption data.
  #

  class AESEncryptinator
    ODRIVE_AES_KEY = 'Mary-Had-A-Little-Lamb-And-The-Lamb-Had-A-Duck'
    ODRIVE_AES_IV = '0.917277060219686-This-Is-Arbitrary'

    #
    # Instantiates a response object.
    # Arguments:
    #   key - the key - String - Optional
    #

    def initialize(iv=ODRIVE_AES_IV, key=ODRIVE_AES_KEY)
      @aes = OpenSSL::Cipher.new("AES-256-CFB")
      @iv = iv
      @key = Digest::SHA2.new(256).digest(key)
    end

    #
    # Encrypts arbitrary text using the private AES key.
    #
    # Arguments:
    #   text - the text - String
    #

    def encrypt(text)
      @aes.encrypt
      @aes.key = @key
      @aes.iv = @iv
      @aes.update(text) + @aes.final
    end

    #
    # Decrypts arbitrary text using the private AES key.
    #
    # Arguments:
    #   text - the text - String
    #

    def decrypt(text)
      @aes.decrypt
      @aes.key = @key
      @aes.iv = @iv
      @aes.update(text) + @aes.final
    end
  end
end
