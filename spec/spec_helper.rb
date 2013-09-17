require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'

require 'webmock'
include WebMock::API

require File.dirname(__FILE__) + '/../lib/gabba/gabba'
