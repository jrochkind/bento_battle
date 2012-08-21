class Error < ActiveRecord::Base
  serialize :error_info
  serialize :backtrace
  attr_accessible :backtrace, :engine, :error_info
end
