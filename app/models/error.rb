class Error < ActiveRecord::Base
  attr_accessible :backtrace, :engine, :error_info
end
