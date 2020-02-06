# frozen_string_literal: true

module Admin
  class Post < ActiveRecord::Base
    self.table_name = 'posts'
  end
end
