class BugReport < ActiveRecord::Base
  attr_accessible :bug_type, :comments, :email, :is_resolved, :name, :platform
end
